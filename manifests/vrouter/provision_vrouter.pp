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
  $api_server_use_ssl         = false,
  $host_ip                    = $::ipaddress,
  $is_tsn                     = undef,
  $is_dpdk                    = undef,
  $node_name                  = $::hostname,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $oper                       = 'add',
) {
  $uname = inline_template("<%= `uname -n |tr -d '\n'` %>")
  if $is_dpdk {
    exec { "provision_vrouter.py ${node_name}" :
      path => '/usr/bin',
      command => "python /opt/contrail/utils/provision_vrouter.py \
                   --host_name ${uname} \
                   --host_ip ${host_ip} \
                   --api_server_ip ${api_address} \
                   --api_server_port ${api_port} \
                   --api_server_use_ssl ${api_server_use_ssl} \
                   --admin_user ${keystone_admin_user} \
                   --admin_password ${keystone_admin_password} \
                   --admin_tenant ${keystone_admin_tenant_name} \
                   --dpdk_enabled \
                   --oper ${oper}",
      tries => 100,
      try_sleep => 3,
    }
  } elsif $is_tsn {
    exec { "provision_vrouter.py ${node_name}" :
      path => '/usr/bin',
      command => "python /opt/contrail/utils/provision_vrouter.py \
                   --host_name ${uname} \
                   --host_ip ${host_ip} \
                   --api_server_ip ${api_address} \
                   --api_server_port ${api_port} \
                   --api_server_use_ssl ${api_server_use_ssl} \
                   --admin_user ${keystone_admin_user} \
                   --admin_password ${keystone_admin_password} \
                   --admin_tenant ${keystone_admin_tenant_name} \
                   --router_type tor-service-node \
                   --oper ${oper}",
      tries => 100,
      try_sleep => 3,
    }
  } else {
    exec { "provision_vrouter.py ${node_name}" :
      path => '/usr/bin',
      command => "python /opt/contrail/utils/provision_vrouter.py \
                   --host_name ${uname} \
                   --host_ip ${host_ip} \
                   --api_server_ip ${api_address} \
                   --api_server_port ${api_port} \
                   --api_server_use_ssl ${api_server_use_ssl} \
                   --admin_user ${keystone_admin_user} \
                   --admin_password ${keystone_admin_password} \
                   --admin_tenant ${keystone_admin_tenant_name} \
                   --oper ${oper}",
      tries => 100,
      try_sleep => 3,
    }
  }
}
