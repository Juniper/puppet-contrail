# == Class: contrail::webui::config
#
# Configure the webui service
#
# === Parameters:
#
# [*openstack_vip*]
#   (optional) VIP for the Openstack services
#   Defaults to '127.0.0.1'
#
# [*contrail_config_vip*]
#   (optional) VIP for the Contrail Config services
#   Defaults to '127.0.0.1'
#
# [*contrail_analytics_vip*]
#   (optional) VIP for the Contrail Analytics services
#   Defaults to '127.0.0.1'
#
# [*neutron_vip*]
#   (optional) VIP for Neutron
#   Defaults to '127.0.0.1'
#
# [*cassandra_ip*]
#   (optional) Array of Cassandra IPs
#   Defaults to ['127.0.0.1']
#
# [*redis_ip*]
#   (optional) Redis IP
#   Defaults to '127.0.0.1'
#
# [*contrail_webui_http_port*]
#   (optional) Port of the Contrail WebUI when using HTTP
#   Defaults to 8080
#
# [*contrail_webui_https_port*]
#   (optional) Port of the Contrail WebUI when using HTTPS
#   Defaults to 8143
#
# [*admin_user*]
#   (optional) Keystone Admin User
#   Defaults to 'admin'
#
# [*admin_password*]
#   (optional) Keystone Admin User Password
#   Defaults to 'admin'
#
# [*admin_token*]
#   (optional) Keystone Admin Token
#   Defaults to ''
#
# [*admin_tenant_name*]
#   (optional) Keystone Admin Tenant Name
#   Defaults to ''
#
class contrail::webui::config (
  $openstack_vip             = '127.0.0.1',
  $contrail_config_vip       = '127.0.0.1',
  $contrail_analytics_vip    = '127.0.0.1',
  $neutron_vip               = '127.0.0.1',
  $cassandra_ip              = ['127.0.0.1'],
  $redis_ip                  = '127.0.0.1',
  $contrail_webui_http_port  = '8080',
  $contrail_webui_https_port = '8143',
<<<<<<< HEAD
  $admin_user                = 'admin',
  $admin_password            = 'admin',
  $admin_token               = '',
  $admin_tenant_name         = 'admin'
=======
  $admin_user,
  $admin_password,
  $admin_token,
  $admin_tenant_name
>>>>>>> 0c14d7b76eb3e383fd40f36ef2c1c3bb2a503ba4
) {

  file { '/etc/contrail/config.global.js' :
    ensure  => file,
    content => template('contrail/config.global.js.erb'),
  }
  file { '/etc/contrail/contrail-webui-userauth.js' :
    ensure  => file,
    content => template('contrail/contrail-webui-userauth.js.erb'),
  }

}
