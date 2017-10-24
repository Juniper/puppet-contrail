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
class contrail::databasenew::config (
  $database_nodemgr_config = {},
  $cassandra_servers       = [],
  $cassandra_ip            = $::ipaddress,
  $storage_port            = '7000',
  $ssl_storage_port        = '7001',
  $client_port             = '9042',
  $client_port_thrift      = '9160',
  $zookeeper_server_ips    = [],
  $zookeeper_client_ip     = $::ipaddress,
  $zookeeper_hostnames     = [],
  $packages                = ['zookeeper'],
  $service_name            = 'zookeeper'
) {
  $zk_server_ip_2181 = join([join($zookeeper_server_ips, ':2181,'),":2181"],'')
  validate_hash($database_nodemgr_config)
  $contrail_database_nodemgr_config = { 'path' => '/etc/contrail/contrail-database-nodemgr.conf' }
  $cassandra_seeds_list = $cassandra_servers[0,2]
  if $cassandra_seeds_list.size > 1 {
    $cassandra_seeds = join($cassandra_seeds_list,",")
  } else {
    $cassandra_seeds = $cassandra_seeds_list[0]
  }

  create_ini_settings($database_nodemgr_config, $contrail_database_nodemgr_config)
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
      'cluster_name'          => 'ConfigDatabase',
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
  validate_ipv4_address($zookeeper_client_ip)

  file {['/usr/lib', '/usr/lib/zookeeper', '/usr/lib/zookeeper/bin/']:
    ensure => directory
  } ->
  class {'::zookeeper':
    servers   => $zookeeper_server_ips,
    client_ip => $zookeeper_client_ip,
    id        => extract_id($zookeeper_hostnames, $::hostname),
    cfg_dir   => '/etc/zookeeper',
#    cfg_dir   => '/etc/zookeeper/conf',
    packages  => $packages,
    service_name => $service_name,
  }
#  } ->
#  file_line { 'adjust zookeeper service':
#    path => '/etc/rc.d/init.d/zookeeper',
#    line => "ZOOCFGDIR=/etc/zookeeper/conf",
#    match   => "^ZOOCFGDIR=.*$",
#  } ->
#  exec { 'systemctl daemon-reload':
#    path => '/bin',
#  }
}
