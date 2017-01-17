# == Class: contrail::database::install
#
# Install the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::analyticsdatabase::install (
) {

  package { 'wget' :
    ensure => installed,
  } ->
  package { 'java-1.8.0-openjdk' :
    ensure => installed,
  } ->
  package { 'contrail-openstack-database' :
    ensure => installed,
  }
#  } ->
#  exec { 'stop contrail-database service':
#      command => '/bin/systemctl stop contrail-database',
#  } ->
#  exec { 'rm -rf /var/lib/cassandra/data/*' :
#    path => '/bin',
#  }

}
