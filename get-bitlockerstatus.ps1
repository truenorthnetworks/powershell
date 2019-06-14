# KB - 90059 - BitLocker Status
# 2019-01-21 wmassingham@truenorthnetworks.com
# Returns the BitLocker status of the OS drive, and the TPM status

try {
	$tpm = get-tpm
	$present = $tpm.TpmPresent
	$ready = $tpm.TpmReady
} catch {
	Write-Error ("Failed to check TPM: " + $_.Exception.Message)
}

try {
	$protectionstatus = (Get-BitLockerVolume | Where-Object volumetype -eq operatingsystem).protectionstatus
} catch {
	Write-Error ("Failed to get OS drive protection status: " + $_.Exception.Message)
}
