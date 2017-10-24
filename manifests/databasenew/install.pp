# == Class: contrail::database::install
#
# Install the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::databasenew::install (
) {

  package { 'wget' :
    ensure => latest,
  } ->
  package { 'java-1.8.0-openjdk' :
    ensure => latest,
  } ->
#  package { 'contrail-openstack-database' :
#  package { 'zookeeper' :
#    ensure => latest,
#  }
  package { 'contrail-database' :
    ensure => latest,
  }
}
