# == Class: contrail::analytics::service
#
# Manage the analytics service
#
# === Parameters:
#
# [*container_image*]
#   (optional) Mandatory in case of container based deployment
#   Container image to be run
#

class contrail::analytics::service(
  $container_image      = undef,
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment

    service {'redis' :
      ensure => running,
      enable => true,
    } ->
    service {'supervisor-analytics' :
      ensure => running,
      enable => true,
    }
  } else {

    # Container based deployment

    contrail::container::run { 'contrail-analytics-container' :
      container_image => $container_image,
    }
  }
}
