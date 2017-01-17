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
  validate_hash($database_nodemgr_config)
  validate_hash($vnc_api_lib_config)
  $contrail_database_nodemgr_config = { 'path' => '/etc/contrail/contrail-database-nodemgr.conf' }
  $contrail_vnc_api_lib_config = { 'path' => '/etc/contrail/vnc_api_lib.ini' }
  $cassandra_seeds_list = $cassandra_servers[0,2]
  if $cassandra_seeds_list.size > 1 {
    $cassandra_seeds = join($cassandra_seeds_list,",")
  } else {
    $cassandra_seeds = $cassandra_seeds_list[0]
  }

  create_ini_settings($database_nodemgr_config, $contrail_database_nodemgr_config)
  create_ini_settings($vnc_api_lib_config, $contrail_vnc_api_lib_config)
  validate_ipv4_address($cassandra_ip)

  file { ['/var/lib/cassandra', ]:
#          '/var/lib/cassandra/data',
#          '/var/lib/cassandra/saved_caches',
#          '/var/lib/cassandra/commitlog', ]:
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
}
