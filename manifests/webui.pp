# == Class: contrail::webui
#
# Install and configure the webui service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for webui
#
class contrail::webui (
  $package_name = $contrail::params::webui_package_name,
  $openstack_vip,
  $cert_file               = '',
  $contrail_config_vip,
  $contrail_analytics_vip,
  $neutron_vip,
  $admin_password,
  $admin_tenant_name,
  $admin_token,
  $admin_user,
  $auth_port,
  $auth_protocol,
  $auth_version = 2,
  $cassandra_ip,
  $contrail_webui_http_port,
  $contrail_webui_https_port,
  $redis_ip,
  $introspect_ssl_enable = false,
  $cnfg_auth_protocol = 'http',
  $sandesh_keyfile = '',
  $sandesh_certfile = '',
  $sandesh_ca_cert = '',
) inherits contrail::params {

  anchor {'contrail::webui::start': } ->
  class {'::contrail::webui::install': } ->
  class {'::contrail::webui::config':
    openstack_vip             => $openstack_vip,
    contrail_config_vip       => $contrail_config_vip,
    contrail_analytics_vip    => $contrail_analytics_vip,
    neutron_vip               => $neutron_vip,
    cassandra_ip              => $cassandra_ip,
    cert_file                 => $cert_file,
    redis_ip                  => $redis_ip,
    contrail_webui_http_port  => $contrail_webui_http_port,
    contrail_webui_https_port => $contrail_webui_https_port,
    admin_user                => $admin_user,
    admin_password            => $admin_password,
    admin_token               => $admin_token,
    admin_tenant_name         => $admin_tenant_name,
    auth_port                 => $auth_port,
    auth_protocol             => $auth_protocol,
    auth_version              => $auth_version,
    introspect_ssl_enable     => $introspect_ssl_enable,
    cnfg_auth_protocol        => $cnfg_auth_protocol,
    sandesh_keyfile           => $sandesh_keyfile,
    sandesh_certfile          => $sandesh_certfile,
    sandesh_ca_cert           => $sandesh_ca_cert,
#  } ~>
  } ->
  class {'::contrail::webui::service': } ->
  anchor {'contrail::webui::end': }

}
