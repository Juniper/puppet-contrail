# == Class: contrail::config::provision_alarm
#
# Register alarms to config api server
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
class contrail::config::provision_alarm (
  $api_address                = '127.0.0.1',
  $api_port                   = 8082,
  $api_server_use_ssl         = false,
  $keystone_admin_user        = 'admin',
  $keystone_admin_password    = 'password',
  $keystone_admin_tenant_name = 'admin',
) {
  exec { "provision_alarm.py" :
    path => '/usr/bin',
    command => "python /opt/contrail/utils/provision_alarm.py \
                 --api_server_ip ${api_address} \
                 --api_server_port ${api_port} \
                 --api_server_use_ssl ${api_server_use_ssl} \
                 --admin_user ${keystone_admin_user} \
                 --admin_password ${keystone_admin_password} \
                 --admin_tenant ${keystone_admin_tenant_name}",
    tries => 100,
    try_sleep => 3,
  }
}
