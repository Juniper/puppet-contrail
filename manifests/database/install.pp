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
  } ->
  # overwrite to fix the issue: https://access.redhat.com/solutions/4420581
  # overwrite to fix the issue: https://access.redhat.com/solutions/4420581
  file {'/etc/rc.d/init.d/cassandra' :
    ensure  => file,
    source => 'puppet:///modules/contrail/cassandra/etc/rc.d/init.d/cassandra',
  } ->
  exec { 'stop contrail-database service':
     command => '/bin/systemctl stop contrail-database || true',
  } ->
  # service will be rerun by service.pp
  exec { 'kill all cassandra contrail-database service':
     command => '/bin/sleep 10 && /bin/killall cassandra || true',
  }

}
