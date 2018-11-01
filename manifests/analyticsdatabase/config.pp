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
  $cassandra_servers       = '',
  $cassandra_ip            = $::ipaddress,
  $storage_port            = 7000,
  $ssl_storage_port        = 7001,
  $client_port             = 9042,
  $client_port_thrift      = 9160,
  $kafka_hostnames         = hiera('contrail_analytics_database_short_node_names', ''),
  $vnc_api_lib_config      = {},
  $zookeeper_server_ips    = hiera('contrail_database_node_ips'),
  $kafka_config            = hiera('contrail_kafka_config', '/etc/kafka/server.properties'),
) {
  $zk_server_ip_2181 = join([join($zookeeper_server_ips, ':2181,'),":2181"],'')
  validate_hash($database_nodemgr_config)
  validate_hash($vnc_api_lib_config)
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
  
  $settings_no_vtokens = {
    'cluster_name'                                    => 'ContrailAnalytics',
    'listen_address'                                  => $cassandra_ip,
    'storage_port'                                    => $storage_port,
    'ssl_storage_port'                                => $ssl_storage_port,
    'native_transport_port'                           => $client_port,
    'rpc_port'                                        => $client_port_thrift,
    'commitlog_directory'                             => '/var/lib/cassandra/commitlog',
    'commitlog_sync'                                  => 'periodic',
    'commitlog_sync_period_in_ms'                     => 10000,
    'partitioner'                                     => 'org.apache.cassandra.dht.Murmur3Partitioner',
    'endpoint_snitch'                                 => 'GossipingPropertyFileSnitch',
    'data_file_directories'                           => ['/var/lib/cassandra/data'],
    'saved_caches_directory'                          => '/var/lib/cassandra/saved_caches',
    'seed_provider'                                   => [
      {
        'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
        'parameters' => [
          {
            'seeds' => $cassandra_seeds,
          },
        ],
      },
    ],
    'start_native_transport'                          => true,
    'hinted_handoff_enabled'                          => true,
    'max_hint_window_in_ms'                           => 10800000, # 3 hours
    'hinted_handoff_throttle_in_kb'                   => 1024,
    'hints_flush_period_in_ms'                        => 10000,
    'max_hints_file_size_in_mb'                       => 128,
    'max_hints_delivery_threads'                      => 2,
    'batchlog_replay_throttle_in_kb'                  => 1024,
    'authenticator'                                   => 'AllowAllAuthenticator',
    'authorizer'                                      => 'AllowAllAuthorizer',
    'role_manager'                                    => 'CassandraRoleManager',
    'cdc_enabled'                                     => false,
    'disk_failure_policy'                             => 'stop',
    'commit_failure_policy'                           => 'stop',
    'commitlog_segment_size_in_mb'                    => 32,
    'concurrent_reads'                                => 32,
    'concurrent_writes'                               => 32,
    'concurrent_counter_writes'                       => 32,
    'concurrent_materialized_view_writes'             => 32,
    'memtable_allocation_type'                        => 'heap_buffers',
    'index_summary_resize_interval_in_minutes'        => 60,
    'trickle_fsync'                                   => false,
    'trickle_fsync_interval_in_kb'                    => 10240,
    'start_rpc'                                       => false,
    'rpc_address'                                     => $cassandra_ip,
    'rpc_keepalive'                                   => true,
    'rpc_server_type'                                 => 'sync',
    'thrift_framed_transport_size_in_mb'              => 15,
    'incremental_backups'                             => false,
    'snapshot_before_compaction'                      => false,
    'auto_snapshot'                                   => true,
    'tombstone_failure_threshold'                     => 100000,
    'tombstone_warn_threshold'                        => 1000,
    'column_index_size_in_kb'                         => 64,
    'column_index_cache_size_in_kb'                   => 2,
    'batch_size_warn_threshold_in_kb'                 => 5,
    'batch_size_fail_threshold_in_kb'                 => 50,
    'batchlog_replay_throttle_in_kb'                  => 1024,
    'unlogged_batch_across_partitions_warn_threshold' => 10,
    'compaction_throughput_mb_per_sec'                => 16,
    'compaction_large_partition_warning_threshold_mb' => 100,
    'sstable_preemptive_open_interval_in_mb'          => 50,
    'read_request_timeout_in_ms'                      => 5000,
    'range_request_timeout_in_ms'                     => 10000,
    'write_request_timeout_in_ms'                     => 2000,
    'counter_write_request_timeout_in_ms'             => 5000,
    'cas_contention_timeout_in_ms'                    => 1000,
    'truncate_request_timeout_in_ms'                  => 60000,
    'request_timeout_in_ms'                           => 10000,
    'slow_query_log_timeout_in_ms'                    => 500,
    'cross_node_timeout'                              => false,
    'dynamic_snitch_badness_threshold'                => 0.1,
    'dynamic_snitch_reset_interval_in_ms'             => 600000,
    'dynamic_snitch_update_interval_in_ms'            => 100,
    'request_scheduler'                               => 'org.apache.cassandra.scheduler.NoScheduler',
    'server_encryption_options'                       => {
      'internode_encryption' => 'none',
      'keystore'             => 'conf/.keystore',
      'keystore_password'    => 'cassandra',
      'truststore'           => 'conf/.truststore',
      'truststore_password'  => 'cassandra',
    },
    'client_encryption_options'                       => {
      'enabled'           => false,
      'optional'          => false,
      'keystore'          => 'conf/.keystore',
      'keystore_password' => 'cassandra',
    },
    'internode_compression'                           => 'dc',
    'inter_dc_tcp_nodelay'                            => false,
    'tracetype_query_ttl'                             => 86400,
    'tracetype_repair_ttl'                            => 604800,
    'windows_timer_interval'                          => 1,
    'transparent_data_encryption_options'             => {
      'enabled'         => false,
      'chunk_length_kb' => 64,
      'cipher'          => 'AES/CBC/PKCS5Padding',
      'key_alias'       => 'testing:1',
      'key_provider'    => [
        {
          'class_name' => 'org.apache.cassandra.security.JKSKeyProvider',
          'parameters' => [
            {
              'keystore'          => 'conf/.keystore',
              'keystore_password' => 'cassandra',
              'store_type'        => 'JCEKS',
              'key_password'      => 'cassandra',
            },
          ],
        },
      ],
    },
    'gc_warn_threshold_in_ms'                         => 1000,
    'back_pressure_enabled'                           => false,
  }

  if $::analytics_db_config_file and $::analytics_db_config_file != '' {
    if $::analytics_db_num_tokens {
      $cassandra_settings = deep_merge($settings_no_vtokens, {
        'num_tokens'  => $::analytics_db_num_tokens,
      })    
    } else {
      $cassandra_settings = $settings_no_vtokens
    }
  } else {
    $cassandra_settings = deep_merge($settings_no_vtokens, {
      'num_tokens'  => 256,
    })
  }

  file { ['/var/lib/cassandra', ]:
    ensure  => 'directory',
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0755',
  } ->

  class { '::cassandra':
    package_name    => 'cassandra',
    hints_directory => '/var/lib/cassandra/hints',
    settings        => $cassandra_settings,
  }

  $kafka_broker_id = extract_id($kafka_hostnames, $::hostname)
  file { $kafka_config :
    ensure => present,
  } ->
  file_line { 'add zookeeper servers to kafka config':
    path  => $kafka_config,
    line  => "zookeeper.connect=${zk_server_ip_2181}",
    match => '^zookeeper.connect=.*$',
  } ->
  file_line { 'set kafka broker id':
    path  => $kafka_config,
    line  => "broker.id=${kafka_broker_id}",
    match => '^broker.id=.*$',
  } ->
  file_line { 'set kafka advertised.host.name':
    path => $kafka_config,
    line => "advertised.host.name=${::ipaddress}",
  } ->
  file_line { 'set kafka num.network.threads=3':
    path => $kafka_config,
    line => 'num.network.threads=3',
  } ->
  file_line { 'set kafka num.io.threads=8':
    path => $kafka_config,
    line => 'num.io.threads=8',
  } ->
  file_line { 'set kafka socket.send.buffer.bytes=102400':
    path => $kafka_config,
    line => 'socket.send.buffer.bytes=102400',
  } ->
  file_line { 'set kafka socket.receive.buffer.bytes=102400':
    path => $kafka_config,
    line => 'socket.receive.buffer.bytes=102400',
  } ->
  file_line { 'set kafka socket.request.max.bytes=104857600':
    path => $kafka_config,
    line => 'socket.request.max.bytes=104857600',
  } ->
  file_line { 'set kafka num.partitions=1':
    path => $kafka_config,
    line => 'num.partitions=1',
  } ->
  file_line { 'set kafka num.recovery.threads.per.data.dir=1':
    path => $kafka_config,
    line => 'num.recovery.threads.per.data.dir=1',
  } ->
  file_line { 'set kafka log.retention.hours=24':
    path => $kafka_config,
    line => 'log.retention.hours=24',
  } ->
  file_line { 'set kafka log.retention.bytes=268435456':
    path => $kafka_config,
    line => 'log.retention.bytes=268435456',
  } ->
  file_line { 'set kafka log.segment.bytes=268435456':
    path => $kafka_config,
    line => 'log.segment.bytes=268435456',
  } ->
  file_line { 'set kafka log.retention.check.interval.ms=300000':
    path => $kafka_config,
    line => 'log.retention.check.interval.ms=300000',
  } ->
  file_line { 'set kafka zookeeper.connection.timeout.ms=6000':
    path => $kafka_config,
    line => 'zookeeper.connection.timeout.ms=6000',
  } ->
  file_line { 'set kafka log.cleanup.policy=delete':
    path => $kafka_config,
    line => 'log.cleanup.policy=delete',
  } ->
  file_line { 'set kafka delete.topic.enable=true':
    path => $kafka_config,
    line => 'delete.topic.enable=true',
  } ->
  file_line { 'set kafka log.cleaner.threads=2':
    path => $kafka_config,
    line => 'log.cleaner.threads=2',
  } ->
  file_line { 'set kafka log.cleaner.dedupe.buffer.size=250000000':
    path => $kafka_config,
    line => 'log.cleaner.dedupe.buffer.size=250000000',
  } ->
  file_line { 'set kafka default.replication.factor=':
    path => $kafka_config,
    line => "default.replication.factor=${kafka_replication}",
  }
}
