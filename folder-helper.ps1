Param(
    [Parameter(Mandatory=$true)][string]$EncodedSharingUrl,
    [switch]$DownloadSwitch
)

$url = 'https://api.onedrive.com/v1.0/shares/u!'+$EncodedSharingUrl+'/root?$expand=children'
$content = (new-object net.webclient).DownloadString($url)
$json = $content | ConvertFrom-Json
$name = $json."name"

foreach ($children in $json."children") {
    # write-host $children."@content.downloadUrl"
    if ($DownloadSwitch.IsPresent) {
        New-Item -ItemType Directory -Force -Path tempfiles/ | Out-Null
        $Response = Invoke-WebRequest -Uri $children."@content.downloadUrl"
        $filename = $Response.Headers.'Content-Disposition'.Split("=")[1].Replace("`"","")
        Invoke-WebRequest $children.'@content.downloadUrl' -OutFile "tempfiles/$($filename)"
        $FileHash = Get-FileHash "tempfiles/$($filename)"
        if ($filehash.Hash -eq $children."file"."hashes"."sha256Hash") {
            write-host "Die Datei $($filename) wude erfolgreich gecached."
        }
    }
}
if ($DownloadSwitch.IsPresent) {
    Compress-Archive -Path tempfiles -DestinationPath "$($name).zip"
}
