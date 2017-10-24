# == Class: contrail::database::install
#
# Install the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::analyticsdatabasenew::install (
) {

  package { 'wget' :
    ensure => latest,
  } ->
  package { 'java-1.8.0-openjdk' :
    ensure => latest,
  } ->
  package { 'contrail-openstack-database' :
    ensure => latest,
  }
#  } ->
#  exec { 'stop contrail-database service':
#      command => '/bin/systemctl stop contrail-database',
#  } ->
#  exec { 'rm -rf /var/lib/cassandra/data/*' :
#    path => '/bin',
#  }

}
