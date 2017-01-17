# == Class: contrail::vrouter::provision_vrouter
#
# Provision the vrouter
#
# === Parameters:
#
# [*api_address*]
#   (optional) IP address of the Contrail API
#   Defaults to '127.0.0.1'
#
# [*api_port*]
#   (optional) Port of the Contrail API
#   Defaults to 8082
#
# [*node_address*]
#   (optional) IP address of the vrouter agent
#   Defaults to $::ipaddress
#
# [*node_name*]
#   (optional) Hostname of the vrouter agent
#   Defaults to $::hostname
#
# [*keystone_admin_user*]
#   (optional) Keystone admin user
#   Defaults to 'admin'
#
# [*keystone_admin_password*]
#   (optional) Password for keystone admin user
#   Defaults to 'password'
#
# [*keystone_admin_tenant_name*]
#   (optional) Keystone admin tenant name
#   Defaults to 'admin'
#
# [*oper*]
#   (optional) Operation to run (add|del)
#   Defaults to 'add'
#
class contrail::vrouter::provision_vrouter (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $host_ip                    = $::ipaddress,
  $is_tsn                     = undef,
  $node_name                  = $::hostname,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $oper                       = 'add',
) {
  #exec { "vrouter deploy wait for contrail config become available" :
  #  path => '/usr/bin',
  #  command => "/usr/bin/wget --spider --tries 150 --waitretry=2 --retry-connrefused http://${api_address}:8082",
  #} ->
  if !$is_tsn {
    exec { "provision_vrouter.py ${node_name}" :
      path => '/usr/bin',
      command => "python /opt/contrail/utils/provision_vrouter.py \
                   --host_name ${::fqdn} \
                   --host_ip ${host_ip} \
                   --api_server_ip ${api_address} \
                   --api_server_port ${api_port} \
                   --admin_user ${keystone_admin_user} \
                   --admin_password ${keystone_admin_password} \
                   --admin_tenant ${keystone_admin_tenant_name} \
                   --oper ${oper}",
      tries => 100,
      try_sleep => 3,
    }
  } else {
    exec { "provision_vrouter.py ${node_name}" :
      path => '/usr/bin',
      command => "python /opt/contrail/utils/provision_vrouter.py \
                   --host_name ${::fqdn} \
                   --host_ip ${host_ip} \
                   --api_server_ip ${api_address} \
                   --api_server_port ${api_port} \
                   --admin_user ${keystone_admin_user} \
                   --admin_password ${keystone_admin_password} \
                   --admin_tenant ${keystone_admin_tenant_name} \
                   --router_type tor-service-node \
                   --oper ${oper}",
      tries => 100,
      try_sleep => 3,
    }
  }
}
