# == Class: contrail::analytics::install
#
# Install the analytics service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for analytics
#
class contrail::analyticsnew::install (
) {

  package { 'wget' :
    ensure => latest,
  }
  package { 'python-redis' :
    ensure => absent,
  } ->
  package { 'contrail-openstack-analytics' :
    ensure => latest,
  }

}
