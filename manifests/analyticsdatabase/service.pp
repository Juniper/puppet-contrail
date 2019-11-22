# == Class: contrail::database::service
#
# Manage the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::analyticsdatabase::service {

  $service_name = 'contrail-database'
  File<||> -> Service<| name == $service_name |>
  Ini_setting<||> -> Service<| name == $service_name |>
  File_line<||> -> Service<| name == $service_name |>

  Package<| tag == 'contrail-openstack-database' |> ~> Service<| tag == 'contrail-database' or tag == 'supervisor-database' |>


  service {'contrail-database' :
    ensure => running,
    enable => true,
  } ->
  service {'supervisor-database' :
    ensure => running,
    enable => true,
  }

}
