# == Class: contrail::config::install
#
# Install the config service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for config
#
class contrail::confignew::install (
) {
  package { 'wget' :
    ensure => latest,
  }
#  exec { "downgrade python":
#    path => '/bin',
#    command => "yum downgrade -y python-libs-2.7.5-38.el7_2 python-2.7.5-38.el7_2 python-devel-2.7.5-38.el7_2",
#  } ->
  package { 'contrail-openstack-config' :
    ensure => latest,
  }

}
