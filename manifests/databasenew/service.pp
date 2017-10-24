# == Class: contrail::database::service
#
# Manage the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::databasenew::service {

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
