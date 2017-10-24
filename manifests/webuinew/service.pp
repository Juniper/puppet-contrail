# == Class: contrail::webui::service
#
# Manage the webui service
#
class contrail::webuinew::service {

  service {'redis' :
    ensure => running,
    enable => true,
  } ->
  service {'supervisor-webui' :
    ensure => running,
    enable => true,
  }

}
