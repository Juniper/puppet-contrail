# == Class: contrail::analytics
#
# Install and configure the analytics service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for analytics
#
class contrail::analyticsnew (
  $package_name = $contrail::params::analytics_package_name,
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

  anchor {'contrail::analyticsnew::start': } ->
  class {'::contrail::analyticsnew::install': } ->
  class {'::contrail::analyticsnew::config': 
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
  class {'::contrail::analyticsnew::service': }
  anchor {'contrail::analyticsnew::end': }
  
}
