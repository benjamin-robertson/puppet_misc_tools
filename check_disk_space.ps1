# Check disk space remaining Windows
$PT_freespace_req=$env:PT_freespace_req
$PT_disk=$env:PT_disk
 
echo "Disk space required $PT_freespace_req on disk $PT_disk"
 
$space = get-ciminstance -ClassName Win32_logicalDisk | Select-Object -Property DeviceID,FreeSpace | Where-Object {$_.DeviceID -eq "${PT_disk}:"}
$space_free = $space.FreeSpace / 1MB
 
echo "Free space avalible is $space_free"
 
if ($space_free -lt $PT_freespace_req) {
    echo "Not enough space free, expected at least $PT_freespace_req have $space_free"
    exit 1
}
 
exit 0