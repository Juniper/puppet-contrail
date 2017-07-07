# == Class: contrail::config::config
#
# Configure the config service
#
# === Parameters:
#
# [*api_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-api.conf
#   Defaults to {}
#
# [*alarm_gen_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-alarm-gen.conf
#   Defaults to {}
#
# [*config_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-config-nodemgr.conf
#   Defaults to {}
#
# [*discovery_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-discovery.conf
#   Defaults to {}
#
# [*schema_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-schema.conf
#   Defaults to {}
#
# [*device_manager_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-device-managerr.conf
#   Defaults to {}
#
# [*svc_monitor_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-svc-monitor.conf
#   Defaults to {}
#
# [*basicauthusers_property*]
#   (optional) List of pairs of ifmap users. Example: user1:password1
#   Defaults to []
#

class contrail::config::config (
  $alarm_gen_config        = {},
  $api_config              = {},
  $basicauthusers_property = [],
  $config_nodemgr_config   = {},
  $device_manager_config   = {},
  $discovery_config        = {},
  $keystone_config         = {},
  $schema_config           = {},
  $svc_monitor_config      = {},
  $vnc_api_lib_config      = {},
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment
    file { '/etc/contrail/contrail-keystone-auth.conf':
      ensure => file,
    }

    validate_hash($api_config)
    validate_hash($alarm_gen_config)
    validate_hash($config_nodemgr_config)
    validate_hash($device_manager_config)
    validate_hash($discovery_config)
    validate_hash($keystone_config)
    validate_hash($schema_config)
    validate_hash($svc_monitor_config)
    validate_hash($vnc_api_lib_config)

    validate_array($basicauthusers_property)

    $contrail_alarm_gen_config = { 'path' => '/etc/contrail/contrail-alarm-gen.conf' }
    $contrail_config_nodemgr_config = { 'path' => '/etc/contrail/contrail-config-nodemgr.conf' }
    $contrail_container_api_config = { 'path' => '/etc/contrailctl/controller.conf' }
    $contrail_device_manager_config = { 'path' => '/etc/contrail/contrail-device-manager.conf' }
    $contrail_discovery_config = { 'path' => '/etc/contrail/contrail-discovery.conf' }
    $contrail_keystone_config = { 'path' => '/etc/contrail/contrail-keystone-auth.conf' }
    $contrail_schema_config = { 'path' => '/etc/contrail/contrail-schema.conf' }
    $contrail_svc_monitor_config = { 'path' => '/etc/contrail/contrail-svc-monitor.conf' }
    $contrail_vnc_api_lib_config = { 'path' => '/etc/contrail/vnc_api_lib.ini' }

    create_ini_settings($api_config, $contrail_api_config)
    create_ini_settings($alarm_gen_config, $contrail_alarm_gen_config)
    create_ini_settings($config_nodemgr_config, $contrail_config_nodemgr_config)
    create_ini_settings($device_manager_config, $contrail_device_manager_config)
    create_ini_settings($discovery_config, $contrail_discovery_config)
    create_ini_settings($keystone_config, $contrail_keystone_config)
    create_ini_settings($schema_config, $contrail_schema_config)
    create_ini_settings($svc_monitor_config, $contrail_svc_monitor_config)
    create_ini_settings($vnc_api_lib_config, $contrail_vnc_api_lib_config)

    file { '/etc/ifmap-server/basicauthusers.properties' :
      ensure  => file,
      content => template('contrail/config/basicauthusers.properties.erb'),
    }

    file {'/etc/ifmap-server/log4j.properties' :
      ensure  => file,
      content => template('contrail/config/log4j.properties.erb'),
    }
  } else {

    # Container based deployment

    # TODO: maybe read parameters from input paramerers aka api_config
    $aaa_mode                       = hiera('contrail::aaa_mode', 'cloud-admin')
    $analytics_aaa_mode             = hiera('contrail::analytics_aaa_mode', 'cloud-admin')
    $analytics_list                 = hiera('contrail_analytics_node_ips')
    $analyticsdb_list               = hiera('contrail_analytics_database_node_ips')
    $controller_list                = hiera('contrail_config_node_ips')
    $cloud_orchestrator             = hiera('contrail_cloud_orchestrator', 'openstack')
    $configdb_cassandra_user        = hiera('contrail_configdb_cassandra_user', 'contrail_configdb_cassandra_user')
    # TODO: pass password from upper layer or get it from DefaultPasswords
    $configdb_cassandra_password    = hiera('contrail_configdb_cassandra_password', 'contrail_configdb_cassandra_password')
    # TODO: to check
    $controller_virtual_ip          = hiera('controller_virtual_ip', '127.0.0.1')
    $glance_api_ip                  = hiera('glance_api_vip', $controller_virtual_ip)
    $neutron_metadata_ip            = hiera('neutron::agents::metadata::metadata_ip',
                                          hiera('nova_metadata_vip', $controller_virtual_ip))
    $nova_api_ip                    = hiera('nova_api_vip', $controller_virtual_ip)
    $rabbitmq_user                  = hiera('contrail::rabbit_user', 'contrail_rabbitmq_user')
    $rabbitmq_password              = hiera('contrail::rabbit_password', 'contrail_rabbitmq_password')
    $rabbitmq_vhost                 = hiera('contrail_rabbitmq_vhost', 'contrail')
    # TODO: probably use another parameter, e.g. insecure
    $ssl_enabled                    = hiera('contrail_ssl_enabled', false)


    # TODO: rework
    # $cloud_admin_role = $aaa_mode ? {
    #   'cloud-admin' => 'admin',
    #   undef         => undef
    # }
    # $global_read_only_role = undef
    $keystone_cfg = $keystone_config['KEYSTONE']
    if $keystone_cfg['auth_protocol'] == 'https' {
      $auth_port_public = hiera('contrail::auth_port_ssl_public', undef)
    } else {
      $auth_port_public = hiera('contrail::auth_port_public', undef)
    }
    $container_controller_config    = {
      'GLOBAL'      => {
        'analytics_nodes'                 => join($analytics_list, ','),
        'cloud_orchestrator'              => $cloud_orchestrator,
        'controller_nodes'                => join($controller_list, ','),
        'configdb_cassandra_user'         => $configdb_cassandra_user,
        'configdb_cassandra_password'     => $configdb_cassandra_password,
        'neutron_metadata_ip'             => $neutron_metadata_ip,
        'introspect_ssl_enable'           => $ssl_enabled,
        'sandesh_ssl_enable'              => $ssl_enabled,
        'xmpp_auth_enable'                => $ssl_enabled,
        'xmpp_dns_auth_enable'            => $ssl_enabled,
      },
      'KEYSTONE'    => {
        'admin_password'                  => $keystone_cfg['admin_password'],
        'admin_port'                      => 35357,
        'admin_tenant'                    => $keystone_cfg['admin_tenant_name'],
        'admin_user'                      => $keystone_cfg['admin_user'],
        'auth_protocol'                   => $keystone_cfg['auth_protocol'],
        'cafile'                          => $keystone_cfg['cafile'],
        'certfile'                        => $keystone_cfg['certfile'],
        'insecure'                        => $keystone_cfg['insecure'],
        'ip'                              => $keystone_cfg['auth_host'],
        'public_port'                     => $auth_port_public,
# TODO: get it from hiera if needed
#      'version'                          => {{ keystone_api_suffix }}
      },
      'RABBITMQ'    => {
        'user'                            => $rabbitmq_user,
        'password'                        => $rabbitmq_password,
        'vhost'                           => $rabbitmq_vhost,
      },
      'API'         => {
        'aaa_mode'                        => $aaa_mode,
        # TODO: rework
        # 'cloud_admin_role'        => $cloud_admin_role,
        # 'global_read_only_role'   => $global_read_only_role,
      },
      'ANALYTICS_API' => {
        'aaa_mode'                        => $analytics_aaa_mode,
      },
      'WEBUI'         => {
        'nova_api_ip'                     => $nova_api_ip,
        'glance_api_ip'                   => $glance_api_ip,
      }
    }
    validate_hash($container_controller_config)
    $contrail_container_controller_config = { 'path' => '/etc/contrailctl/controller.conf' }
    create_ini_settings($container_controller_config, $contrail_container_controller_config)
  }
}
