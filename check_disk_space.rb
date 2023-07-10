#!/opt/puppetlabs/puppet/bin/ruby
# Task to check disk space on RHEL
 
require 'json'
require 'open3'
# set our variables
disk = ENV["PT_disk"]
freespace_req = ENV['PT_freespace_req']
freespace_req = freespace_req.to_i
 
def get_disk (disk_arr)
  disk_arr.length.downto(1) do | i |
    i = i - 1
    partition_to_check = disk_arr[0..i].join("/")
    if i == 0
      # Using root partition
      partition_to_check = '/'
    end
    # check partition
    std_out, std_err, status = Open3.capture3("/bin/mount | /bin/egrep ' #{partition_to_check} '")
    if status == 0 
      # identified the partition to check space on
      return partition_to_check
    end
  end
end
 
def check_space (disk, freespace_req) 
  freespace_avaliable, std_err, status = Open3.capture3("/bin/df -m | /bin/egrep ' #{disk}$' | /bin/awk '{ print $4 }'")
  if status != 0
    puts "Failed to check disk space, stutus was #{status} std_err was #{std_err}"
    return false
  end
  freespace_avaliable = freespace_avaliable.rstrip.to_i
  puts "Free space avaliable is #{freespace_avaliable} free space required is #{freespace_req}"
  if freespace_req < freespace_avaliable 
    return true
  else
    return false
  end
end
 
disk_to_check = get_disk(disk.split("/"))
 
puts "disk to check is #{disk_to_check}"
 
if check_space(disk_to_check, freespace_req)
  exit 0
else
  exit 1
end