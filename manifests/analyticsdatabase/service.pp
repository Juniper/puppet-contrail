# == Class: contrail::database::service
#
# Manage the database service
#
# === Parameters:
#
# [*container_image*]
#   (optional) Mandatory in case of container based deployment
#   Container image to be run
#

class contrail::analyticsdatabase::service(
  $container_image      = undef,
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment

    service {'contrail-database' :
      ensure => running,
      enable => true,
    }
    service {'supervisor-database' :
      ensure => running,
      enable => true,
    }
  } else {

    # Container based deployment

    contrail::container::run { 'contrail-analyticsdb-container' :
      container_image => $container_image,
    }
  }
}
