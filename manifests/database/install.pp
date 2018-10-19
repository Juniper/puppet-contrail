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
  } ->
  package { 'java-1.8.0-openjdk' :
  } ->
  package { 'contrail-database' :
  }
}
