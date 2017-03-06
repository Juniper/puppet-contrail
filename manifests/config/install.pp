# == Class: contrail::config::install
#
# Install the config service
#
# === Parameters:
#
# [*container_name*]
#   (optional) Container name to load,
#
# [*container_url*]
#   Mandatory for container based deployment
#   URL for downloading container
#

class contrail::config::install (
  $container_image          = undef,
  $container_name           = undef,
  $container_url            = undef,
) inherits contrail::params {

  if $version < 4 {
    package { 'wget' :
      ensure => latest,
    }
    package { 'python-gevent' :
      ensure => latest,
    } ->
    package { 'contrail-openstack-config' :
      ensure => latest,
    }
  } else {
     contrail::container::install { $container_name :
      container_image => $container_image,
      container_url   => $container_url,
    }
  }
}
