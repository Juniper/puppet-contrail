
define contrail::container::config (
  $config_file,
  $config_file_dir                = '/etc/contrailctl',
  $template_file,
  $template_file_dir              = 'contrail/contrailctl',

  $aaa_mode                       = hiera('contrail::aaa_mode', 'cloud-admin'),
  $cloud_admin_role               = hiera('contrail::cloud_admin_role', undef),
  $global_read_only_role          = hiera('contrail::global_read_only_role', undef),

  $analytics_aaa_mode             = hiera('contrail::analytics_aaa_mode', 'cloud-admin'),

  $admin_password                 = hiera('contrail::admin_password', undef),
  $admin_port                     = 35357,
  $admin_tenant                   = hiera('contrail::admin_tenant_name', undef),
  $admin_user                     = hiera('contrail::admin_user', undef),
  $auth_host                      = hiera('contrail::auth_host', undef),
  $auth_protocol                  = hiera('contrail::auth_protocol', 'http'),
  $insecure                       = hiera('contrail::insecure', true),
  $ssl_enabled                    = hiera('contrail_ssl_enabled', false),

  $analytics_list                 = hiera('contrail_analytics_node_ips', undef),

  $analyticsdb_list               = hiera('contrail_analytics_database_node_ips', undef),
  $analyticsdb_cassandra_user     = hiera('contrail_analyticsdb_cassandra_user', 'contrail_analyticsdb_cassandra_user'),
  $analyticsdb_cassandra_password = hiera('contrail_analyticsdb_cassandra_password', 'contrail_analyticsdb_cassandra_password'),

  $cloud_orchestrator             = hiera('contrail_cloud_orchestrator', 'openstack'),

  $controller_list                = hiera('contrail_config_node_ips', undef),
  $configdb_cassandra_user        = hiera('contrail_configdb_cassandra_user', 'contrail_configdb_cassandra_user'),
  $configdb_cassandra_password    = hiera('contrail_configdb_cassandra_password', 'contrail_configdb_cassandra_password'),

  $controller_virtual_ip          = hiera('controller_virtual_ip', '127.0.0.1'),
  $glance_api_ip                  = hiera('glance_api_vip', $controller_virtual_ip),
  $neutron_metadata_ip            = hiera('neutron::agents::metadata::metadata_ip',
                                        hiera('nova_metadata_vip', $controller_virtual_ip)),
  $nova_api_ip                    = hiera('nova_api_vip', $controller_virtual_ip),
  $external_rabbitmq_list         = hiera('contrail::external_rabbitmq_servers', hiera('rabbitmq_node_ips', undef)),
  $rabbitmq_user                  = hiera('contrail::rabbit_user', 'contrail_rabbitmq_user'),
  $rabbitmq_password              = hiera('contrail::rabbit_password', 'contrail_rabbitmq_password'),
  $rabbitmq_vhost                 = hiera('contrail::rabbitmq_vhost', undef),

  $external_lb                    = hiera('contrail::external_lb', undef),
  $external_zookeeper_list        = hiera('contrail::external_zookeeper_servers', undef),
  $external_cassandra_list        = hiera('contrail::external_cassandra_servers', undef),

  $ceph_controller_nodes_list     = hiera('contrail::ceph_controller_nodes', undef),

  $web_http_listen_port           = hiera('contrail::webui::http_port', undef),
  $web_https_listen_port          = hiera('contrail::webui::https_port', undef),
) {

  if $auth_protocol == 'https' {
    $auth_port_public = hiera('contrail::auth_port_ssl_public',
      hiera('contrail::auth_port_public', 5000))
    $cafile = hiera('contrail::service_certificate', undef)
    $certfile = hiera('contrail::service_certificate', undef)
  } else {
    $auth_port_public = hiera('contrail::auth_port_public', 5000)
    $cafile = undef
    $certfile = undef
  }

  $analytics_nodes = join($analytics_list, ',')
  $analyticsdb_nodes = join($analyticsdb_list, ',')
  $controller_nodes = join($controller_list, ',')
  $external_rabbitmq_servers = $external_rabbitmq_list ? {
    undef   => undef,
    default => join($external_rabbitmq_list, ','),
  }
  $external_zookeeper_servers = $external_zookeeper_list ? {
    undef   => undef,
    default => join($external_zookeeper_list, ','),
  }
  $external_cassandra_servers = $external_cassandra_list ? {
    undef   => undef,
    default => join($external_cassandra_list, ','),
  }
  $ceph_controller_nodes = $ceph_controller_nodes_list ? {
    undef   => undef,
    default => join($ceph_controller_nodes_list, ','),
  }
  file { "${config_file_dir}/${config_file}" :
    ensure  => file,
    content => template("${template_file_dir}/${template_file}"),
  }
}
