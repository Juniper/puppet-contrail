# == Class: contrail::control::install
#
# Install the control service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for control
#
class contrail::control::install (
) {
  file {'/etc/ld.so.conf.d/contrail.conf':
    ensure => file,
    content => '/usr/lib',
  } ->
  exec { '/sbin/ldconfig':
    command => '/sbin/ldconfig',
  } ->
  package { 'boost' :
    ensure => latest,
  } ->
  package { 'contrail-openstack-control' :
    ensure => latest,
  }
}
