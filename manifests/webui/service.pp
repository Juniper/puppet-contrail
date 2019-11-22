# == Class: contrail::webui::service
#
# Manage the webui service
#
class contrail::webui::service {

  $service_name = 'redis'
  File<||> -> Service<| name == $service_name |>
  Ini_setting<||> -> Service<| name == $service_name |>
  File_line<||> -> Service<| name == $service_name |>
  Package<| tag == 'contrail-openstack-webui' |> ~> Service<| tag == 'supervisor-webui' |>

  service {'redis' :
    ensure => running,
    enable => true,
  } ->
  service {'supervisor-webui' :
    ensure => running,
    enable => true,
  }

}
