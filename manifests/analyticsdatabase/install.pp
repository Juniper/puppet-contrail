# == Class: contrail::database::install
#
# Install the database service
#
# === Parameters:
#
# === Parameters:
#
# [*container_name*]
#   (optional) Container name to load,
#
# [*container_url*]
#   URL for downloading container
#

class contrail::analyticsdatabase::install (
  $container_image          = undef,
  $container_name           = undef,
  $container_url            = undef,
) inherits contrail::params {

  if $version < 4 {
    package { 'wget' :
      ensure => latest,
    } ->
    package { 'java-1.8.0-openjdk' :
      ensure => latest,
    } ->
    package { 'contrail-openstack-database' :
      ensure => latest,
    }
#   } ->
#   exec { 'stop contrail-database service':
#        command => '/bin/systemctl stop contrail-database',
#   } ->
#   exec { 'rm -rf /var/lib/cassandra/data/*' :
#      path => '/bin',
#   }
  } else {
     contrail::container::install { $container_name :
      container_image => $container_image,
      container_url   => $container_url,
    }
  }
}
