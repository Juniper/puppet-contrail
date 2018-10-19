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
  }
  package { 'python-gevent' :
  } ->
  package { 'contrail-openstack-config' :
  }

}
