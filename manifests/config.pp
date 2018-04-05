# == Class: contrail::config
#
# Install and configure the config service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for config
#
class contrail::config (
  $package_name = $contrail::params::config_package_name,
  $api_config,
  $basicauthusers_property = [],
  $config_nodemgr_config,
  $contrail_version,
  $device_manager_config,
  $discovery_config = {},
  $keystone_config,
  $schema_config,
  $svc_monitor_config,
  $vnc_api_lib_config,
) inherits contrail::params  {

  anchor {'contrail::config::start': } ->
  class {'::contrail::config::install': } ->
  class {'::contrail::config::config': 
    api_config              => $api_config,
    basicauthusers_property => $basicauthusers_property,
    config_nodemgr_config   => $config_nodemgr_config,
    contrail_version        => $contrail_version,
    device_manager_config   => $device_manager_config,
    discovery_config        => $discovery_config,
    keystone_config         => $keystone_config,
    schema_config           => $schema_config,
    svc_monitor_config      => $svc_monitor_config,
    vnc_api_lib_config      => $vnc_api_lib_config,
  } ->
  class {'::contrail::config::service': } ->
  anchor {'contrail::config::end': }
  
}

