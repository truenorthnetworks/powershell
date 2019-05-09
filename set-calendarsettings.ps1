# wmassingham@truenorthnetworks.com 2017-05-02
# Loops through all mailboxes and sets default permission to publishing editor
# 2017-10-19 added room, equipment mailboxes
# 2018-11-28 add 365 connection

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted

# Connect to 365
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,(ConvertTo-SecureString -AsPlainText $password -Force)
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

# Set calendar permissions on mailboxes
$mailboxes = get-mailbox -recipienttype usermailbox,roommailbox,equipmentmailbox
ForEach ($Mailbox in $mailboxes) { Set-MailboxFolderPermission -user default -Identity "$($Mailbox.Name):\Calendar" -accessrights publishingeditor }

# Set calendar processing settings on room & equipment mailboxes
$rooms = get-mailbox -recipienttype roommailbox,equipmentmailbox
foreach ($room in $rooms) {
	set-calendarprocessing -identity "$($room.Name)" `
		-AllowConflicts $false `
		-AutomateProcessing AutoAccept `
		-BookingWindowInDays 365 `
		-AddOrganizerToSubject $false `
		-DeleteSubject $false `
		-DeleteComments $false `
		-RemovePrivateProperty $false
}
