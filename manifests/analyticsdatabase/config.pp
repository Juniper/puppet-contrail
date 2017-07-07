# == Class: contrail::database::config
#
# Configure the database service
#
# === Parameters:
#
# [*database_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-database-nodemgr.conf
#   Defaults to {}
#

class contrail::analyticsdatabase::config (
  $database_nodemgr_config = {},
  $cassandra_servers       = [],
  $cassandra_ip            = $::ipaddress,
  $storage_port            = '7000',
  $ssl_storage_port        = '7001',
  $client_port             = '9042',
  $client_port_thrift      = '9160',
  $kafka_hostnames         = hiera('contrail_analytics_database_short_node_names', ''),
  $vnc_api_lib_config      = {},
  $zookeeper_server_ips    = hiera('contrail_database_node_ips', ''),
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment

    validate_hash($database_nodemgr_config)
    validate_hash($vnc_api_lib_config)
    $zk_server_ip_2181 = join([join($zookeeper_server_ips, ':2181,'),":2181"],'')
    $contrail_database_nodemgr_config = { 'path' => '/etc/contrail/contrail-database-nodemgr.conf' }
    $contrail_vnc_api_lib_config = { 'path' => '/etc/contrail/vnc_api_lib.ini' }
    $cassandra_seeds_list = $cassandra_servers[0,2]
    if $cassandra_seeds_list.size > 1 {
      $cassandra_seeds = join($cassandra_seeds_list,",")
      $kafka_replication = '2'
    } else {
      $cassandra_seeds = $cassandra_seeds_list[0]
      $kafka_replication = '1'
    }

    create_ini_settings($database_nodemgr_config, $contrail_database_nodemgr_config)
    create_ini_settings($vnc_api_lib_config, $contrail_vnc_api_lib_config)
    validate_ipv4_address($cassandra_ip)

    file { ['/var/lib/cassandra', ]:
      ensure => 'directory',
      owner  => 'cassandra',
      group  => 'cassandra',
      mode   => '0755',
    } ->
    class {'::cassandra':
#     service_ensure => stopped,
#     service_enable => false,
      settings => {
        'cluster_name'          => 'ContrailAnalytics',
        'listen_address'        => $cassandra_ip,
        'storage_port'          => $storage_port,
        'ssl_storage_port'      => $ssl_storage_port,
        'native_transport_port' => $client_port,
        'rpc_port'              => $client_port_thrift,
        'commitlog_directory'         => '/var/lib/cassandra/commitlog',
        'commitlog_sync'              => 'periodic',
        'commitlog_sync_period_in_ms' => 10000,
        'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
        'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
        'data_file_directories'       => ['/var/lib/cassandra/data'],
        'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
        'seed_provider'               => [
          {
            'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
            'parameters' => [
              {
                'seeds' => $cassandra_seeds,
              },
            ],
          },
        ],
        'start_native_transport'      => true,
      }
    }
    file { '/usr/share/kafka/config/server.properties':
      ensure => present,
    }->
    file_line { 'add zookeeper servers to kafka config':
      path => '/usr/share/kafka/config/server.properties',
      line => "zookeeper.connect=${zk_server_ip_2181}",
      match   => "^zookeeper.connect=.*$",
    }
    $kafka_broker_id = extract_id($kafka_hostnames, $::hostname)
    file_line { 'set kafka broker id':
      path => '/usr/share/kafka/config/server.properties',
      line => "broker.id=${kafka_broker_id}",
      match   => "^broker.id=.*$",
    }
    file_line { 'set kafka advertised.host.name':
      path => '/usr/share/kafka/config/server.properties',
      line => "advertised.host.name=${::ipaddress}",
    }
    file_line { 'set kafka num.network.threads=3':
      path => '/usr/share/kafka/config/server.properties',
      line => "num.network.threads=3",
    }
    file_line { 'set kafka num.io.threads=8':
      path => '/usr/share/kafka/config/server.properties',
      line => "num.io.threads=8",
    }
    file_line { 'set kafka socket.send.buffer.bytes=102400':
      path => '/usr/share/kafka/config/server.properties',
      line => "socket.send.buffer.bytes=102400",
    }
    file_line { 'set kafka socket.receive.buffer.bytes=102400':
      path => '/usr/share/kafka/config/server.properties',
      line => "socket.receive.buffer.bytes=102400",
    }
    file_line { 'set kafka socket.request.max.bytes=104857600':
      path => '/usr/share/kafka/config/server.properties',
      line => "socket.request.max.bytes=104857600",
    }
    file_line { 'set kafka num.partitions=1':
      path => '/usr/share/kafka/config/server.properties',
      line => "num.partitions=1",
    }
    file_line { 'set kafka num.recovery.threads.per.data.dir=1':
      path => '/usr/share/kafka/config/server.properties',
      line => "num.recovery.threads.per.data.dir=1",
    }
    file_line { 'set kafka log.retention.hours=24':
      path => '/usr/share/kafka/config/server.properties',
      line => "log.retention.hours=24",
    }
    file_line { 'set kafka log.retention.bytes=268435456':
      path => '/usr/share/kafka/config/server.properties',
      line => "log.retention.bytes=268435456",
    }
    file_line { 'set kafka log.segment.bytes=268435456':
      path => '/usr/share/kafka/config/server.properties',
      line => "log.segment.bytes=268435456",
    }
    file_line { 'set kafka log.retention.check.interval.ms=300000':
      path => '/usr/share/kafka/config/server.properties',
      line => "log.retention.check.interval.ms=300000",
    }
    file_line { 'set kafka zookeeper.connection.timeout.ms=6000':
      path => '/usr/share/kafka/config/server.properties',
      line => "zookeeper.connection.timeout.ms=6000",
    }
    file_line { 'set kafka log.cleanup.policy=delete':
      path => '/usr/share/kafka/config/server.properties',
      line => "log.cleanup.policy=delete",
    }
    file_line { 'set kafka delete.topic.enable=true':
      path => '/usr/share/kafka/config/server.properties',
      line => "delete.topic.enable=true",
    }
    file_line { 'set kafka log.cleaner.threads=2':
      path => '/usr/share/kafka/config/server.properties',
      line => "log.cleaner.threads=2",
    }
    file_line { 'set kafka log.cleaner.dedupe.buffer.size=250000000':
      path => '/usr/share/kafka/config/server.properties',
      line => "log.cleaner.dedupe.buffer.size=250000000",
    }
    file_line { 'set kafka default.replication.factor=':
      path => '/usr/share/kafka/config/server.properties',
      line => "default.replication.factor=${kafka_replication}",
    }

  } else {

    # Container based deployment


    # TODO: maybe read parameters from input paramerers aka analytics_api_config
    $analytics_list = hiera('contrail_analytics_node_ips')
    $analyticsdb_list = hiera('contrail_analytics_database_node_ips')
    $analyticsdb_cassandra_user     = hiera('contrail_analyticsdb_cassandra_user', 'contrail_analyticsdb_cassandra_user')
    # TODO: pass password from upper layer or get it from DefaultPasswords
    $analyticsdb_cassandra_password = hiera('contrail_analyticsdb_cassandra_password', 'contrail_analyticsdb_cassandra_password')
    $controller_list = hiera('contrail_config_node_ips')
    $cloud_orchestrator = hiera('contrail_cloud_orchestrator', 'openstack')
    $admin_password = hiera('contrail::admin_password', undef)
    $admin_tenant_name = hiera('contrail::admin_tenant_name', undef)
    $admin_user = hiera('contrail::admin_user', undef)
    $auth_host = hiera('contrail::auth_host', undef)
    $auth_protocol = hiera('contrail::auth_protocol', undef)
    $insecure = hiera('contrail::insecure', true)
    if $auth_protocol == 'https' {
      $auth_port_public = hiera('contrail::auth_port_ssl_public', undef)
      $ca_file = hiera('contrail::service_certificate', undef)
      $cert_file = hiera('contrail::service_certificate', undef)
    } else {
      $auth_port_public = hiera('contrail::auth_port_public', undef)
      $ca_file = undef
      $cert_file = undef
    }
    $memcached_servers = hiera('contrail::memcached_server', undef)
    # TODO: probably use another parameter, e.g. insecure
    $ssl_enabled = hiera('contrail_ssl_enabled', false)

    $container_analyticsdb_config    = {
      'GLOBAL' => {
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
      'KEYSTONE' => {
        'admin_password'                  => $admin_password,
        'admin_port'                      => 35357,
        'admin_tenant'                    => $admin_tenant_name,
        'admin_user'                      => $admin_user,
        'auth_protocol'                   => $auth_protocol,
        'cafile'                          => $ca_file,
        'certfile'                        => $cert_file,
        'insecure'                        => $insecure,
        'ip'                              => $auth_host,
        'public_port'                     => $auth_port_public,
# TODO: get it from hiera if needed
#      'version'                          => {{ keystone_api_suffix }}
      },
    }

    validate_hash($container_analyticsdb_config)
    $contrail_container_analyticsdb_config = { 'path' => '/etc/contrailctl/analyticsdb.conf' }
    create_ini_settings($container_analyticsdb_config, $contrail_container_analyticsdb_config)

  }
}
