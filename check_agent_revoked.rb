#!/opt/puppetlabs/puppet/bin/ruby
#
# Run on Puppet primary server. 
#
require 'openssl'

certificate_directory = '/etc/puppetlabs/puppet/ssl/ca/signed/*.pem'
crl_location = '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem'

puts 'This script checks for revoked certificates on Puppet Enterprise.'
puts '-----------------------------------------------------'

crl_data = File.open crl_location
crl = OpenSSL::X509::CRL.new crl_data

puts "crl revoked is #{crl.revoked}"

# Dir.glob(certificate_directory) do | next_cert | 
#     cert_data = File.open next_cert
#     certificate = OpenSSL::X509::Certificate.new cert_data

#     expiry = certificate.not_after
#     if expiry <= desired_time
#         puts "Certificate #{certificate.subject} expires at #{certificate.not_after}"
#     end

# end