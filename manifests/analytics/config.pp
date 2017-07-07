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
  $redis_config             = {},
  $topology_config          = {},
  $vnc_api_lib_config       = {},
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment

    file { '/etc/contrail/contrail-keystone-auth.conf':
      ensure => file,
    }

    validate_hash($alarm_gen_config)
    validate_hash($analytics_api_config)
    validate_hash($analytics_nodemgr_config)
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

    create_ini_settings($alarm_gen_config, $contrail_alarm_gen_config)
    create_ini_settings($analytics_api_config, $contrail_analytics_api_config)
    create_ini_settings($analytics_nodemgr_config, $contrail_analytics_nodemgr_config)
    create_ini_settings($collector_config, $contrail_collector_config)
    create_ini_settings($keystone_config, $contrail_keystone_config)
    create_ini_settings($query_engine_config, $contrail_query_engine_config)
    create_ini_settings($snmp_collector_config, $contrail_snmp_collector_config)
    create_ini_settings($topology_config, $contrail_topology_config)
    create_ini_settings($vnc_api_lib_config, $contrail_vnc_api_lib_config)

  } else {

    # Container based deployment

    # TODO: read parameters from input paramerers
    $aaa_mode                       = hiera('contrail::analytics_aaa_mode', 'cloud-admin')
    $analytics_list                 = hiera('contrail_analytics_node_ips')
    $analyticsdb_list               = hiera('contrail_analytics_database_node_ips')
    $analyticsdb_cassandra_user     = hiera('contrail_analyticsdb_cassandra_user', 'contrail_analyticsdb_cassandra_user')
    # TODO: pass password from upper layer or get it from DefaultPasswords
    $analyticsdb_cassandra_password = hiera('contrail_analyticsdb_cassandra_password', 'contrail_analyticsdb_cassandra_password')
    $controller_list                = hiera('contrail_config_node_ips')
    $cloud_orchestrator             = hiera('contrail_cloud_orchestrator', 'openstack')
    $rabbitmq_user                  = hiera('contrail::rabbit_user', 'contrail_rabbitmq_user')
    $rabbitmq_password              = hiera('contrail::rabbit_password', 'contrail_rabbitmq_password')
    $rabbitmq_vhost                 = hiera('contrail_rabbitmq_vhost', 'contrail')
    # TODO: probably use another parameter, e.g. insecure
    $ssl_enabled                    = hiera('contrail_ssl_enabled', false)
    $keystone_cfg = $keystone_config['KEYSTONE']
    $container_analytics_config    = {
      'GLOBAL'        => {
        'analytics_nodes'                 => join($analytics_list, ','),
        'analyticsdb_nodes'               => join($analyticsdb_list, ','),
        'analyticsdb_cassandra_user'      => $analyticsdb_cassandra_user,
        'analyticsdb_cassandra_password'  => $analyticsdb_cassandra_password,
        'cloud_orchestrator'              => $cloud_orchestrator,
        'controller_nodes'                => join($controller_list, ','),
        'introspect_ssl_enable'           => $ssl_enabled,
        'sandesh_ssl_enable'              => $ssl_enabled,
        'xmpp_auth_enable'                => $ssl_enabled,
        'xmpp_dns_auth_enable'            => $ssl_enabled,
       },
      'KEYSTONE'      => {
        'admin_password'                  => $keystone_cfg['admin_password'],
        'admin_port'                      => 35357,
        'admin_tenant'                    => $keystone_cfg['admin_tenant_name'],
        'admin_user'                      => $keystone_cfg['admin_user'],
        'auth_protocol'                   => $keystone_cfg['auth_protocol'],
        'cafile'                          => $keystone_cfg['cafile'],
        'certfile'                        => $keystone_cfg['certfile'],
        'insecure'                        => $keystone_cfg['insecure'],
        'ip'                              => $keystone_cfg['auth_host'],
        'public_port'                     => $keystone_cfg['auth_port'],
# TODO: get it from hiera if needed
#        'version'                         => {{ keystone_api_suffix }}
      },
      'ANALYTICS_API' => {
        'aaa_mode'                         => $aaa_mode,
      },
      'RABBITMQ'      => {
        'user'                             => $rabbitmq_user,
        'password'                         => $rabbitmq_password,
        'vhost'                            => $rabbitmq_vhost,
      },
    }

    validate_hash($container_analytics_config)
    $contrail_container_analytics_config = { 'path' => '/etc/contrailctl/analytics.conf' }
    create_ini_settings($container_analytics_config, $contrail_container_analytics_config)
  }
}
