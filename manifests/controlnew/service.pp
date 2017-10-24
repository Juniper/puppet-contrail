# == Class: contrail::control::service
#
# Manage the control service
#
class contrail::controlnew::service {

  service {'supervisor-control' :
    ensure => running,
    enable => true,
  }

}
