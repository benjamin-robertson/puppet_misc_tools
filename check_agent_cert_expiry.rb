#!/opt/puppetlabs/puppet/bin/ruby
#
# Run on Puppet primary server. 
#
require 'openssl'

certificate_directory = '/etc/puppetlabs/puppet/ssl/ca/signed/*.pem'

puts 'This script checks for agent certificates soon to expire on Puppet Enterprise.'
puts 'Please enter how many days in the future you wish to check for expiring certs. (Default 365)'
begin
  days = gets.to_i
  if days < 1
    days = 365
  end
rescue => exception
   puts 'not valid integer'
   exit 
end

puts "Checking for certs expiring in the next #{days} days."
puts '-----------------------------------------------------'

current_time = Time.now
desired_time = current_time + ((60 * 60 * 24) * days)

Dir.glob(certificate_directory) do | next_cert | 
    cert_data = File.open next_cert
    certificate = OpenSSL::X509::Certificate.new cert_data

    expiry = certificate.not_after
    if expiry <= desired_time
        puts "Certificate #{certificate.subject} expires at #{certificate.not_after}"
    end

end