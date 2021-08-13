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
        New-Item -ItemType Directory -Force -Path onedrive-direct-url-tempfiles | Out-Null
        $Response = Invoke-WebRequest -Uri $children."@content.downloadUrl"
        $filename = $Response.Headers.'Content-Disposition'.Split("=")[1].Replace("`"","")
        Invoke-WebRequest $children.'@content.downloadUrl' -OutFile "onedrive-direct-url-tempfiles/$($filename)"
        $FileHash = Get-FileHash "onedrive-direct-url-tempfiles/$($filename)"
        if ($filehash.Hash -eq $children."file"."hashes"."sha256Hash") {
            write-host "Die Datei $($filename) wude erfolgreich gecached."
        }
    }
}
if ($DownloadSwitch.IsPresent) {
    write-host "Die Dateien werden gezippt."
    Compress-Archive -Force -Path onedrive-direct-url-tempfiles -DestinationPath "$(get-date -f yyyyMMdd-HHmmss)-$($name).zip"
    Remove-Item -Recurse onedrive-direct-url-tempfiles | Out-Null
}
