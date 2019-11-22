# == Class: contrail::database::service
#
# Manage the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::database::service {

  $service_name = 'supervisor-database'
  File<||> -> Service<| name == $service_name |>
  Ini_setting<||> -> Service<| name == $service_name |>
  File_line<||> -> Service<| name == $service_name |>

  Package<| tag == 'contrail-database' |> ~> Service<| tag == 'contrail-database' |>

  service {'contrail-database' :
    ensure => running,
    enable => true,
  }
#  service {'zookeeper' :
#    ensure => running,
#    enable => false,
#  }
#  service {'supervisor-database' :
#    ensure => stopped,
#    enable => false,
#  }

}
