# == Class: contrail::config::service
#
# Manage the config service
#
class contrail::confignew::service {

  service {'supervisor-config' :
    ensure => running,
    enable => true,
  }

}

