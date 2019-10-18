# Services to stop
# Restarting the agent services might be causing multiple runs, removed those
#$services = @("wuauserv", "bits", "appidsvc", "cryptsvc", "ccmexec", "Windows Agent Service", "Windows Agent Maintenance Service")
$services = @("wuauserv", "bits", "appidsvc", "cryptsvc", "ccmexec")

# Try stopping services
try{
	Stop-Services $services
} catch {
	# Try again
	try{
		Stop-Services $services
	} catch {
		# Give up, try to restart the services we stopped
		outputText += "Failed to stop services: $($_.Exception.Message)"
		Start-Services $services
		exit 1
	}
}

try{
	remove-item -force -recurse "${env:allusersprofile}\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
	remove-item -force -recurse "${env:systemroot}\SoftwareDistribution\*"
	remove-item -force -recurse "${env:systemroot}\system32\catroot2\*"
	remove-item -force -recurse "${env:systemroot}\WindowsUpdate.log"
	# clearing these folders will cause patch status v2 to incorrectly show green
	#remove-item -force -recurse "${env:ProgramFiles}\N-able Technologies\PatchManagement"
	#remove-item -force -recurse "${env:ProgramFiles(x86)}\N-able Technologies\PatchManagement"
} catch {
	outputText += "`nFailed to remove update directories: $($_.Exception.Message)"
	Start-Services $services
	exit 1
}

Set-Location $env:windir\system32
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s atl.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s msjava.dll
regsvr32.exe /s mssip32.dll
regsvr32.exe /s msxml2.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s wuwebv.dll

try{
	$regitems = @("AccountDomainSid", "PingID", "SusClientId")
	Remove-ItemProperty -Force -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name $regitems
} catch {
	outputText += "`nFailed to remove Windows Update registry items: $($_.Exception.Message)"
	Start-Services $services
	exit 1
}

netsh winsock reset
# proxycfg does not exist on recent systems
if (test-path $env:systemroot\system32\proxycfg.exe) { proxycfg.exe -d }
netsh winhttp reset proxy

try{
	Start-Services $services
} catch {
	outputText += "`nFailed to start services: $($_.Exception.Message)"
	exit 1
}

bitsadmin.exe /reset /allusers
wuauclt /resetauthorization /detectnow
wuauclt /updatenow 
usoclient scaninstallwait
