# == Class: contrail::config::service
#
# Manage the config service
#
# === Parameters:
#
# [*container_image*]
#   (optional) Mandatory in case of container based deployment
#   Container image to be run
#

class contrail::config::service(
  $container_image      = undef,
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment
    service {'supervisor-config' :
      ensure => running,
      enable => true,
    }
  } else {

    # Container based deployment

    contrail::container::run { 'contrail-controller-container' :
      container_image => $container_image,
    }
  }
}

