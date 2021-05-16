[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $File
)

if (Test-Path $File) {
    $fileContentBytes = get-content $File -AsByteStream 
    [System.Convert]::ToBase64String($fileContentBytes) | Out-File 'encoded-bytes.txt'
}
