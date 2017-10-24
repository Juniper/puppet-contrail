# == Class: contrail::database::service
#
# Manage the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::analyticsdatabasenew::service {

  service {'contrail-database' :
    ensure => running,
    enable => true,
  }
  service {'supervisor-database' :
    ensure => running,
    enable => true,
  }

}
