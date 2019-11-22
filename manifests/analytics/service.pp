# == Class: contrail::analytics::service
#
# Manage the analytics service
#
class contrail::analytics::service {

  $service_name = 'redis'
  File<||> -> Service<| name == $service_name |>
  Ini_setting<||> -> Service<| name == $service_name |>
  File_line<||> -> Service<| name == $service_name |>
  Package<| tag == 'contrail-openstack-analytics' |> ~> Service<| tag == 'supervisor-analytics' or tag == 'redis' |>

  service {'redis' :
    ensure => running,
    enable => true,
  } ->
  service {'supervisor-analytics' :
    ensure => running,
    enable => true,
  }

}
