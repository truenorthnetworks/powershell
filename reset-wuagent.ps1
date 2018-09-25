net stop wuauserv
net stop bits
net stop appidsvc
net stop cryptsvc
net stop ccmexec
net stop "Windows Agent Service"
net stop "Windows Agent Maintenance Service"

remove-item -force -recurse "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
remove-item -force -recurse $env:systemroot\SoftwareDistribution\*
remove-item -force -recurse $env:systemroot\system32\catroot2\*
remove-item -force -recurse $env:systemroot\WindowsUpdate.log 
remove-item -force -recurse "$env:ProgramFiles\N-able Technologies\PatchManagement"
remove-item -force -recurse "${env:ProgramFiles(x86)}\N-able Technologies\PatchManagement"

Set-Location $env:windir\system32
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s Actxprxy.dll
regsvr32.exe /s atl.dll
regsvr32.exe /s atl.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s Browseui.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s Initpki.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s Mshtml.dll
regsvr32.exe /s Msjava.dll
regsvr32.exe /s Mssip32.dll
regsvr32.exe /s msxml2.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s Oleaut32.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s Shdocvw.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s Softpub.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s Urlmon.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s wuwebv.dll

REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v AccountDomainSid /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v PingID /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /f

netsh winsock reset
# proxycfg does not exist on recent systems
if (test-path $env:systemroot\system32\proxycfg.exe) { proxycfg.exe -d }
netsh winhttp reset proxy

net start ccmexec
net start cryptsvc
net start appidsvc
net start bits
net start wuauserv
net start "Windows Agent Service"
net start "Windows Agent Maintenance Service"

bitsadmin.exe /reset /allusers

wuauclt /resetauthorization /detectnow
