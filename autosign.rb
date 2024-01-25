#!/usr/bin/ruby 
#/opt/puppetlabs/puppet/bin/ruby
#
# Autosign script for Puppet Server. Follow guide on https://www.puppet.com/docs/puppet/7/ssl_autosign#ssl_policy_based_autosigning for how to setup this script
#
# I've made the decision to strip any non (A-z,0-9,/,-,_,:) characters from the output of the trusted extension. 
# Openssl has been known to return weird characters from certificate attributes. See https://github.com/GeoffWilliams/puppet-safe_roles/issues/12
#
require 'openssl'

# Set valid values for facts. Each facts must match these value for autosigning to occur.
valid_datacenters = ['dc1','dc2']
valid_role_regex = '^role::*'
valid_provisioners = ['manual','legacy']
valid_environments = ['dev','prd']
valid_departments = ['HR','ben']

# Confirm certname argument have been passed
if ARGV.length != 1
  STDERR.puts "autosign.rb MUST be run with one arguments. Certname"
  exit 1
end

certname=ARGV[0]
certificate=STDIN.read

# set all known trusted facts
trusted_facts_oid = { 'pp_uuid' => '1.3.6.1.4.1.34380.1.1.1', 'pp_instance_id' => '1.3.6.1.4.1.34380.1.1.2', 'pp_image_name' => '1.3.6.1.4.1.34380.1.1.3', 'pp_preshared_key' => '1.3.6.1.4.1.34380.1.1.4', 'pp_cost_center' => '1.3.6.1.4.1.34380.1.1.5', 'pp_product' => '1.3.6.1.4.1.34380.1.1.6', 'pp_project' => '1.3.6.1.4.1.34380.1.1.7', 'pp_application' => '1.3.6.1.4.1.34380.1.1.8', 'pp_service' => '1.3.6.1.4.1.34380.1.1.9', 'pp_employee' => '1.3.6.1.4.1.34380.1.1.10', 'pp_created_by' => '1.3.6.1.4.1.34380.1.1.11', 'pp_environment' => '1.3.6.1.4.1.34380.1.1.12', 'pp_role' => '1.3.6.1.4.1.34380.1.1.13', 'pp_software_version' => '1.3.6.1.4.1.34380.1.1.14', 'pp_department' => '1.3.6.1.4.1.34380.1.1.15', 'pp_cluster' => '1.3.6.1.4.1.34380.1.1.16', 'pp_provisioner' => '1.3.6.1.4.1.34380.1.1.17', 'pp_region' => '1.3.6.1.4.1.34380.1.1.18', 'pp_datacenter' => '1.3.6.1.4.1.34380.1.1.19', 'pp_zone' => '1.3.6.1.4.1.34380.1.1.20', 'pp_network' => '1.3.6.1.4.1.34380.1.1.21', 'pp_securitypolicy' => '1.3.6.1.4.1.34380.1.1.22', 'pp_cloudplatform' => '1.3.6.1.4.1.34380.1.1.23', 'pp_apptier' => '1.3.6.1.4.1.34380.1.1.24', 'pp_hostname' => '1.3.6.1.4.1.34380.1.1.25' }

def check_datacentre(valid_datacenters, trusted_facts, trusted_facts_oid)
  unless valid_datacenters.include?(trusted_facts[trusted_facts_oid['pp_datacenter']])
    STDERR.puts "Datacentre fact not set correctly"
    exit 1
  end
end

def check_role_regex(valid_role_regex, trusted_facts, trusted_facts_oid)
  unless trusted_facts[trusted_facts_oid['pp_role']].match(/#{valid_role_regex}/)
    STDERR.puts "Role fact not matching role regex."
    exit 1
  end
end

def check_provisioners(valid_provisioners, trusted_facts, trusted_facts_oid)
  unless valid_provisioners.include?(trusted_facts[trusted_facts_oid['pp_provisioner']])
    STDERR.puts "Provisioner fact not set correctly"
    exit 1
  end
end

def check_environments(valid_environments, trusted_facts, trusted_facts_oid)
  unless valid_environments.include?(trusted_facts[trusted_facts_oid['pp_environment']])
    STDERR.puts "Environment fact not set correctly"
    exit 1
  end
end

def check_departments(valid_departments, trusted_facts, trusted_facts_oid)
  unless valid_departments.include?(trusted_facts[trusted_facts_oid['pp_department']])
    STDERR.puts "Department fact not set correctly"
    exit 1
  end
end

def get_extension_requests(certificate)
  csr=OpenSSL::X509::Request.new certificate

  attribute = csr.attributes.find { |a| a.oid == 'extReq' }
  sequence = attribute.value
    
  trusted_facts = {}
    
  sequence.value.each do | element |
    element.value.length.times do | num |
      value = OpenSSL::ASN1.decode(element.value[num]).value
      trusted_facts[value[0].value.strip] = value[1].value.strip.gsub(/[^a-zA-Z\d\/\:_-]/, '')
    end
  end
  trusted_facts
end

trusted_facts = get_extension_requests(certificate)
check_datacentre(valid_datacenters, trusted_facts, trusted_facts_oid)
check_role_regex(valid_role_regex, trusted_facts, trusted_facts_oid)
check_provisioners(valid_provisioners, trusted_facts, trusted_facts_oid)
check_environments(valid_environments, trusted_facts, trusted_facts_oid)
check_departments(valid_departments, trusted_facts, trusted_facts_oid)

STDOUT.write "Autosign passed for #{certname}, trusted facts were #{trusted_facts}" # This can be changed to a STDOUT output. However output will not show in puppetserver.log unless its logged to stderr.
exit 0