# wmassingham@truenorthnetworks.com 2017-05-02
# Loops through all mailboxes and sets default permission to publishing editor
# 2017-10-19 added room, equipment mailboxes
# 2018-11-28 add 365 connection
# 2019-07-08 add flags to control each section
# 2019-12-26 change from name to userprincipalname to handle two objects with the same name

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted

# Connect to 365
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,(ConvertTo-SecureString -AsPlainText $password -Force)
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

# Set calendar permissions on mailboxes
if ($setpublishingeditor -eq "true") {
	$mailboxes = get-mailbox -recipienttype usermailbox,roommailbox,equipmentmailbox
	ForEach ($Mailbox in $mailboxes) { Set-MailboxFolderPermission -user default -Identity "$($Mailbox.userprincipalname):\Calendar" -accessrights publishingeditor }
}

# Set calendar processing settings on room & equipment mailboxes
if ($setcalendarprocessing -eq "true") {
	$rooms = get-mailbox -recipienttype roommailbox,equipmentmailbox
	foreach ($room in $rooms) {
		set-calendarprocessing -identity "$($room.userprincipalname)" `
			-AllowConflicts $false `
			-AutomateProcessing AutoAccept `
			-BookingWindowInDays 365 `
			-AddOrganizerToSubject $false `
			-DeleteSubject $false `
			-DeleteComments $false `
			-RemovePrivateProperty $false
	}
}
