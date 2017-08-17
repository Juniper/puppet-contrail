# == Class: contrail::database
#
# Install and configure the database service
#
# === Parameters:
#
# [*container_name*]
#   (optional) Container name to run,
# [*container_url*]
#   URL for downloading container
# [*container_tag*]
#   (optional) Container tag to be pullled from registry,
# [*package_name*]
#   (optional) Package name for database
#
class contrail::analyticsdatabase (
  $analyticsdatabase_params = {},
  $container_image          = $contrail::params::analyticsdb_container_image,
  $container_name           = $contrail::params::analyticsdb_container_name,
  $container_url            = $contrail::params::container_url,
  $package_name             = $contrail::params::database_package_name,
) inherits contrail::params {

  anchor {'contrail::analyticsdatabase::start': } ->
  class {'::contrail::analyticsdatabase::install':
    container_image          => $container_image,
    container_name           => $container_name,
    container_url            => $container_url,
  } ->
  class {'::contrail::analyticsdatabase::config':
    cassandra_ip            => $analyticsdatabase_params['host_ip'],
    cassandra_servers       => $analyticsdatabase_params['cassandra_servers'],
    database_nodemgr_config => $analyticsdatabase_params['database_nodemgr_config'],
    kafka_hostnames         => $analyticsdatabase_params['kafka_hostnames'],
    vnc_api_lib_config      => $analyticsdatabase_params['vnc_api_lib_config'],
    zookeeper_server_ips    => $analyticsdatabase_params['zookeeper_server_ips'],
  } ~>
  class {'::contrail::analyticsdatabase::service':
    container_image          => $container_image,
  }
  anchor {'contrail::analyticsdatabase::end': }
}
