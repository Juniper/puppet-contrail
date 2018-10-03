# == Class: contrail::control::service
#
# Manage the control service
#
class contrail::control::service {

  $service_name = 'supervisor-control'
  File<||> -> Service<| name == $service_name |>
  Ini_setting<||> -> Service<| name == $service_name |>
  File_line<||> -> Service<| name == $service_name |>

  service {'supervisor-control' :
    ensure => running,
    enable => true,
  }

}
