# Make-TnnsupPs1.ps1
# 2018-12-18 wmassingham@truenorthnetworks.com
# Takes a tnnsup exe and creates a ps1 to deploy it

param (
	[Parameter(Position=0)][string]$infile
)

Set-StrictMode -Version 3.0

# set infile to actual object, not just string path
$infile = Get-Item $infile

Write-Output "using input file $infile"

$timestamp = Get-Date -format s | ForEach-Object { $_ -replace ":", "-" }
$outfile = Join-Path -Path (Split-Path $infile) -ChildPath "Deploy-Tnnsup_$timestamp.ps1"

try {
	#$base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($infile)) | Out-File -Encoding UTF8 -Append $outfile
	certutil -encode tnnsup.exe $outfile
} catch {
	Write-Error ("Failed to write read input file to base64: " + $_.Exception.Message)
}

try {

(Get-Content $outfile).replace('-----BEGIN CERTIFICATE-----', @'
# KB - 01005 - TNNSUP
# 2018-11-06 wmassingham@truenorthnetworks.com
# Deploys tnnsup.exe to system32 via base64 encoded script

# [Convert]::ToBase64String([IO.File]::ReadAllBytes("`$pwd\tnnsup.exe")) | Out-File -Force "tnnsup-base64.txt"

Set-StrictMode -Version 3.0

function main {
	try {
		[IO.File]::WriteAllBytes("c:\windows\system32\tnnsup.exe", [Convert]::FromBase64String($base64))
	} catch {
		Write-Error ("Failed to deploy tnnsup: " + $_.Exception.Message)
		exit 1
	}
}

$base64 = "
'@) | Set-Content $outfile

(Get-Content $outfile).replace('-----END CERTIFICATE-----', @'
"
main
'@) | Set-Content $outfile

} catch {
	Write-Error ("Failed to write output file: " + $_.Exception.Message)
}
