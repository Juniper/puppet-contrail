# == Class: contrail::database
#
# Install and configure the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::databasenew (
  $package_name = $contrail::params::database_package_name,
  $database_params = $database_params,
) inherits contrail::params {

  Service <| name == 'supervisor-analytics' |> -> Service['supervisor-database']
  Service <| name == 'supervisor-config' |> -> Service['supervisor-database']
  Service <| name == 'supervisor-control' |> -> Service['supervisor-database']
  Service['supervisor-database'] -> Service <| name == 'supervisor-webui' |>

  anchor {'contrail::databasenew::start': } ->
  class {'::contrail::databasenew::install': } ->
  class {'::contrail::databasenew::config': 
    cassandra_servers       => $database_params['cassandra_servers'],
    cassandra_ip            => $database_params['host_ip'],
    database_nodemgr_config => $database_params['database_nodemgr_config'],
    zookeeper_server_ips    => $database_params['zookeeper_server_ips'],
    zookeeper_client_ip     => $database_params['zookeeper_client_ip'],
    zookeeper_hostnames     => $database_params['zookeeper_hostnames'],
  } ~>
  class {'::contrail::databasenew::service': }
  anchor {'contrail::databasenew::end': }
  
}
