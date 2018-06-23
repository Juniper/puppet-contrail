# == Class: contrail::database::install
#
# Install the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::database::install (
) {

  package { 'wget' :
    ensure => latest,
  } ->
#Set up on controller node during STEP1 WEBUI install 
# as webui has dependency on JDK version
#  package { 'java-1.8.0-openjdk' :
#    ensure => '1.8.0.151-5.b12.el7_4',
#  } ->
#  package { 'contrail-openstack-database' :
#  package { 'zookeeper' :
#    ensure => latest,
#  }
  package { 'contrail-database' :
    ensure => latest,
  }
}
