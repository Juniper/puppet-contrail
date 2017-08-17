# == Class: contrail::analytics::install
#
# Install the analytics service
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

class contrail::analytics::install (
  $container_image          = undef,
  $container_name           = undef,
  $container_url            = undef,
) inherits contrail::params {

  if $version < 4 {
    package { 'python-redis' :
      ensure => absent,
    } ->
    package { 'python-gevent' :
      ensure => latest,
    } ->
    package { 'contrail-openstack-analytics' :
      ensure => latest,
    }
  } else {
    contrail::container::install { $container_name :
      container_image => $container_image,
      container_url   => $container_url,
    }
  }
}
