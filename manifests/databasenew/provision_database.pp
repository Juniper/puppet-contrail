# == Class: contrail::database::provision_control
#
# Provision the database node
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
# [*database_node_address*]
#   (optional) IP address of the databaseler
#   Defaults to $::ipaddress
#
# [*database_node_name*]
#   (optional) Hostname of the databaseler
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
class contrail::databasenew::provision_database (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $database_node_address       = $host_ip,
  $database_node_name          = $::hostname,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
  $oper                       = 'add',
  $openstack_vip              = '127.0.0.1',
) {

  #exec { "database deploy wait for keystone become available" :
  #  path => '/usr/bin',
  #  command => "/usr/bin/wget --spider --tries 150 --waitretry=2 --retry-connrefused http://${openstack_vip}:35357",
  #} ->
  #exec { "database deploy wait for contrail config become available" :
  #  path => '/usr/bin',
  #  command => "/usr/bin/wget --spider --tries 150 --waitretry=2 --retry-connrefused http://${api_address}:8082",
  #} ->
  exec { "provision_database_node.py ${control_node_name}" :
    path => '/usr/bin',
    command => "python /opt/contrail/utils/provision_database_node.py \
                 --host_name ${::fqdn} \
                 --host_ip ${database_node_address} \
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
