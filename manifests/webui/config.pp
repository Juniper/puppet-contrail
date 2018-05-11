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
# [*contrail_vip*]
#   (optional) VIP for the Contrail services
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
class contrail::webui::config (
  $openstack_vip             = '127.0.0.1',
  $contrail_config_vip       = '127.0.0.1',
  $contrail_analytics_vip    = '127.0.0.1',
  $neutron_vip               = '127.0.0.1',
  $cassandra_ip              = ['127.0.0.1'],
  $redis_ip                  = '127.0.0.1',
  $contrail_webui_http_port  = '8080',
  $contrail_webui_https_port = '8143',
  $admin_user                = 'admin',
  $admin_password            = 'admin',
  $admin_token               = 'admin',
  $admin_tenant_name         = 'admin',
  $auth_port                 = '5000',
  $auth_protocol             = 'http',
  $auth_version              = 2,
  $cert_file                 = '',
  $introspect_ssl_enable     = false,
  $cnfg_auth_protocol        = 'http',
  $sandesh_keyfile           = '',
  $sandesh_certfile          = '',
  $sandesh_ca_cert           = '',
) {

  $contrail_vip = $contrail_config_vip
  $identity_manager_api_version = $auth_version ? {
    2       => 'v2.0',
    default => 'v3',
  }
  file { '/etc/contrail/config.global.js' :
    ensure  => file,
    content => template('contrail/config.global.js.erb'),
  }
  file { '/etc/contrail/contrail-webui-userauth.js' :
    ensure  => file,
    content => template('contrail/contrail-webui-userauth.js.erb'),
  }

}
