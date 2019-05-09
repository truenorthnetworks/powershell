# Return code
$ret = 0

# Report to disk
$outfile = "c:\_tnn_bin\KB20021.txt"
# Create and/or clear the file
New-Item -Force -ItemType File -Path $outfile 
Write-Output "Drive`tVHD GB`tDrive capacity (GB)" | Out-File -encoding UTF8 $outfile

# Hashtable that will contain the list of lettered physical drives and their size
$disks = @{}

# List of VHDs on running VMs
$vhds = (get-vm | Where-Object { $_.state -eq "running" } | Select-Object vmid | get-vhd)

# List of drive letters attached to the above VHDs
$letters = ( $vhds | ForEach-Object { split-path -qualifier $_.path } | sort-object -Unique )

# Loop through VHDs and add unique drive letters to our array
$letters | ForEach-Object {
    # Add drive letter with zero usage
    $disks.add($_, 0)
}

# Loop through VHDs and add them to the total
$vhds | ForEach-Object {
    # Get the drive letter from the VHD path
    $letter = split-path -qualifier $_.path
    # Add this VHD size to the usage for the drive it sits on
    $disks.Set_Item($letter, $disks.Get_Item($letter) + $_.Size);
}

# Loop through usage on each lettered drive and compare to actual
# drive size, and write out a report to disk
$letters | ForEach-Object {
    $vhdtotalsize = $disks.Get_Item($_)
    $disksize = (Get-WMIObject Win32_Logicaldisk -filter "deviceid='$_'").Size

    Write-Output "$_`t$([int]($vhdtotalsize/1GB))`t$([int]($disksize/1GB))" | Out-File -encoding UTF8 -append $outfile

    if ($vhdtotalsize -ge $disksize) {
        $ret = 1
    }
}

# List VHDs with size and path
Write-Output "`n" | Out-File -encoding UTF8 -append $outfile
$vhds | Select-Object @{Name='Size (GB)';  Expression={$_.size/1GB}},path | ConvertTo-Csv -NoTypeInformation -Delimiter "`t" | Out-File -encoding UTF8 -append $outfile
