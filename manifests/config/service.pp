# == Class: contrail::config::service
#
# Manage the config service
#
class contrail::config::service {

  $service_name = 'supervisor-config'
  File<||> -> Service<| name == $service_name |>
  Ini_setting<||> -> Service<| name == $service_name |>
  File_line<||> -> Service<| name == $service_name |>

  service {'supervisor-config' :
    ensure => running,
    enable => true,
  } ->
  # Restart service is needed for:
  #  - https://bugs.launchpad.net/juniperopenstack/+bug/1718184
  #  - https://bugs.launchpad.net/juniperopenstack/+bug/1779943
  exec { 'restart config-api':
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => 'supervisorctl -c /etc/contrail/supervisord_config.conf restart contrail-api:0',
  }
}

