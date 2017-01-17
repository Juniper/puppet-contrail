# == Class: contrail::analytics::service
#
# Manage the analytics service
#
class contrail::analytics::service {

  service {'redis' :
    ensure => running,
    enable => true,
  } ->
  service {'supervisor-analytics' :
    ensure => running,
    enable => true,
  }

}
