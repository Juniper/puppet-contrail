# == Class: contrail::config
#
# Install and configure the config service
#
# === Parameters:
#
# [*container_name*]
#   (optional) Container name to run,
# [*container_url*]
#   Mandatory for container based deployment
#   URL for downloading container
# [*container_tag*]
#   (optional) Container tag to be pullled from registry,
#   'latest' will be used if it is unset
# [*package_name*]
#   (optional) Package name for config

class contrail::config (
  $container_image          = $contrail::params::controller_container_image,
  $container_name           = $contrail::params::controller_container_name,
  $container_url            = $contrail::params::container_url,
  $package_name             = $contrail::params::config_package_name,
  $api_config,
  $basicauthusers_property,
  $config_nodemgr_config,
  $device_manager_config,
  $discovery_config,
  $keystone_config,
  $schema_config,
  $svc_monitor_config,
  $vnc_api_lib_config,
) inherits contrail::params  {

  anchor {'contrail::config::start': } ->
  class {'::contrail::config::install':
    container_image          => $container_image,
    container_name           => $container_name,
    container_url            => $container_url,
   } ->
  class {'::contrail::config::config':
    api_config              => $api_config,
    basicauthusers_property => $basicauthusers_property,
    config_nodemgr_config   => $config_nodemgr_config,
    device_manager_config   => $device_manager_config,
    discovery_config        => $discovery_config,
    keystone_config         => $keystone_config,
    schema_config           => $schema_config,
    svc_monitor_config      => $svc_monitor_config,
    vnc_api_lib_config      => $vnc_api_lib_config,
  } ~>
  class {'::contrail::config::service':
    container_image          => $container_image,
  }
  anchor {'contrail::config::end': }
}

