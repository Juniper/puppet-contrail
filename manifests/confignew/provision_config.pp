# == Class: contrail::control::provision_config
#
# Provision the config node
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
# [*config_node_address*]
#   (optional) IP address of the controller
#   Defaults to $::ipaddress
#
# [*config_node_name*]
#   (optional) Hostname of the controller
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
class contrail::confignew::provision_config (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $config_node_address        = $::ipaddress,
  $config_node_name           = $::hostname,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $oper                       = 'add',
  $openstack_vip              = '127.0.0.1',
) {
  exec { "provision_config_node.py ${config_node_name}" :
    path => '/usr/bin',
    command => "python /opt/contrail/utils/provision_config_node.py \
                 --host_name ${::fqdn} \
                 --host_ip ${config_node_address} \
                 --api_server_ip ${api_address} \
                 --api_server_port ${api_port} \
                 --admin_user ${keystone_admin_user} \
                 --admin_password ${keystone_admin_password} \
                 --admin_tenant ${keystone_admin_tenant_name} \
                 --openstack_ip ${openstack_vip} \
                 --oper ${oper}",
    tries => 100,
    try_sleep => 3,
  }
}
