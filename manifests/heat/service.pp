# == Class: contrail::heat::service
#
# Manage the heat service
#
class contrail::heat::service {

  $service_name = 'openstack-heat-engine'
  File<||> -> Service<| name == $service_name |>
  Ini_setting<||> -> Service<| name == $service_name |>
  File_line<||> -> Service<| name == $service_name |>

  service {'openstack-heat-engine' :
    ensure => running,
    enable => true,
  }
}
