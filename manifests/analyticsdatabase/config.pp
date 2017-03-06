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
  $cassandra_servers       = "",
  $cassandra_ip            = $::ipaddress,
  $storage_port            = '7000',
  $ssl_storage_port        = '7001',
  $client_port             = '9042',
  $client_port_thrift      = '9160',
  $kafka_hostnames         = hiera('contrail_analytics_database_short_node_names', ''),
  $vnc_api_lib_config      = {},
  $zookeeper_server_ips    = hiera('contrail_database_node_ips'),
) {
  $zk_server_ip_2181 = join([join($zookeeper_server_ips, ':2181,'),":2181"],'')
  $container_analyticsdb_config    = {
    'GLOBAL' => {
      'enable_webui_service'   => 'True',
      #'analyticsdb_list'       => "${api_config['DEFAULTS']['cassandra_server_list']}",
      'analyticsdb_list'       => "${hiera('contrail_analytics_database_node_ips')}",
      'enable_control_service' => 'True',
      'config_server_list'     => "${hiera('contrail_config_node_ips')}",
      'analytics_ip'           => "${hiera('public_virtual_ip')}",
      'controller_list'        => "${hiera('contrail_control_node_ips')}",
      'analytics_list'         => "${hiera('contrail_analytics_node_ips')}",
      'compute_list'           => "${hiera('contrail_vrouter_node_ips')}",
      'enable_config_service'  => 'True',
      'cloud_orchestrator'     => 'kubernetes',
      'controller_ip'          => "${hiera('public_virtual_ip')}",
    },
  }
  validate_hash($container_analyticsdb_config)
  validate_hash($database_nodemgr_config)
  validate_hash($vnc_api_lib_config)
  $contrail_container_analyticsdb_config = { 'path' => '/etc/contrailctl/analyticsdb.conf' }
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

  create_ini_settings($container_analyticsdb_config, $contrail_container_analyticsdb_config)
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
#    service_ensure => stopped,
#    service_enable => false,
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
}
