# == Class: contrail::analytics
#
# Install and configure the analytics service
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
# [*package_name*]
#   (optional) Package name for analytics

class contrail::analytics (
  $container_image          = $contrail::params::analytics_container_image,
  $container_name           = $contrail::params::analytics_container_name,
  $container_url            = $contrail::params::container_url,
  $package_name             = $contrail::params::analytics_package_name,
  $alarm_gen_config,
  $analytics_api_config,
  $analytics_nodemgr_config,
  $collector_config,
  $keystone_config,
  $query_engine_config,
  $snmp_collector_config,
  $redis_config,
  $topology_config,
  $vnc_api_lib_config,
) inherits contrail::params {

  anchor {'contrail::analytics::start': } ->
  class {'::contrail::analytics::install':
    container_image          => $container_image,
    container_name           => $container_name,
    container_url            => $container_url,
  } ->
  class {'::contrail::analytics::config':
    alarm_gen_config         => $alarm_gen_config,
    analytics_api_config     => $analytics_api_config,
    analytics_nodemgr_config => $analytics_nodemgr_config,
    collector_config         => $collector_config,
    keystone_config          => $keystone_config,
    query_engine_config      => $query_engine_config,
    redis_config             => $redis_config,
    snmp_collector_config    => $snmp_collector_config,
    topology_config          => $topology_config,
    vnc_api_lib_config       => $vnc_api_lib_config,
  } ~>
  class {'::contrail::analytics::service':
    container_image          => $container_image,
  }
  anchor {'contrail::analytics::end': }
}
