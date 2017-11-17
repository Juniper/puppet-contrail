# == Class: contrail::analytics::config
#
# Configure the analytics service
#
# === Parameters:
#
# [*analytics_api_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-analytics-api.conf
#   Defaults to {}
#
# [*collector_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-collector.conf
#   Defaults to {}
#
# [*query_engine_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-query-engine.conf
#   Defaults to {}
#
# [*snmp_collector_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-snmp-collector.conf
#   Defaults to {}
#
# [*analytics_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-analytics-nodemgr.conf
#   Defaults to {}
#
# [*topology_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-toplogy.conf
#   Defaults to {}
#
class contrail::analytics::config (
  $alarm_gen_config         = {},
  $analytics_api_config     = {},
  $analytics_nodemgr_config = {},
  $collector_config         = {},
  $keystone_config          = {},
  $query_engine_config      = {},
  $snmp_collector_config    = {},
  $redis_config,
  $topology_config          = {},
  $vnc_api_lib_config       = {},
  $rabbitmq_server_list,
  $rabbitmq_port,
  $rabbitmq_vhost,
  $rabbitmq_user,
  $rabbitmq_password,
  $config_db_cql_server_list,
  $config_db_server_list,
) {
  file { '/etc/contrail/contrail-keystone-auth.conf':
    ensure => file,
  }
  validate_hash($alarm_gen_config)
  validate_hash($analytics_api_config)
  validate_hash($analytics_nodemgr_config)
  validate_hash($collector_config)
  validate_hash($keystone_config)
  validate_hash($query_engine_config)
  validate_hash($snmp_collector_config)
  validate_hash($topology_config)
  validate_hash($vnc_api_lib_config)


  $contrail_alarm_gen_config         = { 'path' => '/etc/contrail/contrail-alarm-gen.conf' }
  $contrail_analytics_api_config     = { 'path' => '/etc/contrail/contrail-analytics-api.conf' }
  $contrail_collector_config         = { 'path' => '/etc/contrail/contrail-collector.conf' }
  $contrail_keystone_config          = { 'path' => '/etc/contrail/contrail-keystone-auth.conf' }
  $contrail_query_engine_config      = { 'path' => '/etc/contrail/contrail-query-engine.conf' }
  $contrail_snmp_collector_config    = { 'path' => '/etc/contrail/contrail-snmp-collector.conf' }
  $contrail_analytics_nodemgr_config = { 'path' => '/etc/contrail/contrail-analytics-nodemgr.conf' }
  $contrail_topology_config          = { 'path' => '/etc/contrail/contrail-topology.conf' }
  $contrail_vnc_api_lib_config       = { 'path' => '/etc/contrail/vnc_api_lib.ini' }

  file_line { 'add bind to /etc/redis.conf':
    path => '/etc/redis.conf',
    line => $redis_config,
    match   => "^bind.*$",
  }

  $rabbit_server = split($rabbitmq_server_list, ',')
  $rabbit_server_list_port = join([join($rabbit_server, ":${rabbitmq_port} "),":${rabbitmq_port}"],'')
  $config_data_port_separately = {
    'CONFIGDB'  => {
      'rabbitmq_server_list'  => $rabbitmq_server_list,
      'rabbitmq_port'         => $rabbitmq_port,
      'rabbitmq_vhost'        => $rabbitmq_vhost,
      'rabbitmq_user'         => $rabbitmq_user,
      'rabbitmq_password'     => $rabbitmq_password,
      'config_db_server_list' => $config_db_server_list,
      }
  }
  $config_data = {
    'CONFIGDB'  => {
      'rabbitmq_server_list'  => $rabbit_server_list_port,
      'rabbitmq_vhost'        => $rabbitmq_vhost,
      'rabbitmq_user'         => $rabbitmq_user,
      'rabbitmq_password'     => $rabbitmq_password,
      'config_db_server_list' => $config_db_server_list,
      }
  $config_data_cql_port = {
    'CONFIGDB'  => {
      'rabbitmq_server_list'  => $rabbit_server_list_port,
      'rabbitmq_vhost'        => $rabbitmq_vhost,
      'rabbitmq_user'         => $rabbitmq_user,
      'rabbitmq_password'     => $rabbitmq_password,
      'config_db_server_list' => $config_db_cql_server_list,
      }
  }
  $merged_alarm_gen_config      = merge($alarm_gen_config, $config_data_port_separately)
  $merged_collector_config      = merge($collector_config, $config_data_cql_port)
  $merged_snmp_collector_config = merge($snmp_collector_config, $config_data)
  $merged_topology_config       = merge($topology_config, $config_data)

  create_ini_settings($merged_alarm_gen_config, $contrail_alarm_gen_config)
  create_ini_settings($analytics_api_config, $contrail_analytics_api_config)
  create_ini_settings($analytics_nodemgr_config, $contrail_analytics_nodemgr_config)
  create_ini_settings($merged_collector_config, $contrail_collector_config)
  create_ini_settings($keystone_config, $contrail_keystone_config)
  create_ini_settings($query_engine_config, $contrail_query_engine_config)
  create_ini_settings($merged_snmp_collector_config, $contrail_snmp_collector_config)
  create_ini_settings($merged_topology_config, $contrail_topology_config)
  create_ini_settings($vnc_api_lib_config, $contrail_vnc_api_lib_config)

}
