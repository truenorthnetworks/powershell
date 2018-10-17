# wmassingham@truenorthnetworks.com 2018-10-03
# Installs Windows 10 version 1803 from a pre-downloaded ISO

# location of the iso
$iso = "c:\windows\temp\Win10_1803_English_x64.iso"

# mount the iso
try {
	Write-Host "Mounting $iso"
	$mount = Mount-DiskImage "$iso" -PassThru
	$letter = ($mount | Get-Volume).DriveLetter
} catch {
	Write-Error ("Failed to mount ISO: " + $_.Exception.Message)
	exit 1
}

# run setup
try {
	if ($reboot -eq "true") {
		$params = "/auto upgrade /quiet /showoobe none"
	} else {
		$params = "/auto upgrade /quiet /showoobe none /noreboot"
	}
	Write-Host "Starting ${letter}:\setup.exe, params: $params"
	Start-Process "${letter}:\setup.exe" -ArgumentList $params
} catch {
	Write-Error ("Failed to execute installer: " + $_.Exception.Message)
	exit 1
}
