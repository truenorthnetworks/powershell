# KB - 40115 - BitLocker Recovery Keys
# 2018-08-10 wmassingham@truenorthnetworks.com
# Returns the BitLocker status of encryptable volumes, and if applicable, the ID and recovery key

$ret = ""
(Get-WmiObject -Namespace root/cimv2/Security/MicrosoftVolumeEncryption -Class Win32_EncryptableVolume) | Sort-Object DriveLetter | ForEach-Object {
	if ($_.protectionstatus -eq 1) {
		$protector = (Get-WmiObject -Namespace root/cimv2/Security/MicrosoftVolumeEncryption -Class Win32_EncryptableVolume -Filter ("DriveLetter = '" + $_.DriveLetter + "'")).GetKeyProtectors(3)
		$password  = (Get-WmiObject -Namespace root/cimv2/Security/MicrosoftVolumeEncryption -Class Win32_EncryptableVolume -Filter ("DriveLetter = '" + $_.DriveLetter + "'")).GetKeyProtectorNumericalPassword($protector.VolumeKeyProtectorId)
		$ret += ($_.DriveLetter + " identifier " + $protector.VolumeKeyProtectorId + ", recovery " + $password.NumericalPassword + "; ")
	} else {
		$ret += ($_.DriveLetter + " BitLocker not enabled;")
	}
}
$ret
