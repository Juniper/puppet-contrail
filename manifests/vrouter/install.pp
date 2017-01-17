# == Class: contrail::vrouter::install
#
# Install the vrouter service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for vrouter
#
class contrail::vrouter::install (
) {

  package { 'contrail-openstack-vrouter' :
    ensure => installed,
  }

  #file { '/opt/contrail/utils/update_dev_net_config_files.py' :
  #  ensure => file,
  #  source => 'puppet:///modules/contrail/vrouter/update_dev_net_config_files.py',
  #}

}
