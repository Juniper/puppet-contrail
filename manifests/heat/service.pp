# == Class: contrail::heat::service
#
# Manage the heat service
#
class contrail::heat::service {

  service {'openstack-heat-engine' :
    ensure => running,
    enable => true,
  }
}
