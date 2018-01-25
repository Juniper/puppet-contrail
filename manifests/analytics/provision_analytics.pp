# == Class: contrail::analytics::provision_control
#
# Provision the analytics node
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
# [*analytics_node_address*]
#   (optional) IP address of the analyticsler
#   Defaults to $::ipaddress
#
# [*analytics_node_name*]
#   (optional) Hostname of the analyticsler
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
class contrail::analytics::provision_analytics (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $api_server_use_ssl         = false,
  $analytics_node_address     = $::ipaddress,
  $analytics_node_name        = $::hostname,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $oper                       = 'add',
  $openstack_vip              = '127.0.0.1',
) {
  $uname = inline_template("<%= `uname -n |tr -d '\n'` %>")
  exec { "provision_analytics_node.py ${control_node_name}" :
    path => '/usr/bin',
    command => "python /opt/contrail/utils/provision_analytics_node.py \
                 --host_name ${uname} \
                 --host_ip ${analytics_node_address} \
                 --api_server_ip ${api_address} \
                 --api_server_port ${api_port} \
                 --api_server_use_ssl ${api_server_use_ssl} \
                 --admin_user ${keystone_admin_user} \
                 --admin_password ${keystone_admin_password} \
                 --admin_tenant ${keystone_admin_tenant_name} \
                 --openstack_ip ${openstack_vip} \
                 --oper ${oper}",
    tries => 100,
    try_sleep => 3, 
  }
}
