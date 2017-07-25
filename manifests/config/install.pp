# == Class: contrail::config::install
#
# Install the config service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for config
#
class contrail::config::install (
) {
  package { 'wget' :
    ensure => latest,
  }
  package { 'python-gevent' :
    ensure => latest,
  } ->
  package { 'contrail-openstack-config' :
    ensure => latest,
  }

}
