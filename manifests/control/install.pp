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

  package { 'contrail-openstack-control' :
    ensure => installed,
  }

}
