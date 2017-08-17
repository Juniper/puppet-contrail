# == Class: contrail::config::config
#
# Configure the config service
#
# === Parameters:
#
# [*heat_config*]
#   (optional) Hash of parameters for /etc/heat/heat.conf
#   Defaults to {}
#
class contrail::heat::config (
  $heat_config = {},
) {

  validate_hash($heat_config)

  file { '/usr/lib/heat':
    ensure => 'directory',
  } ->
  file { '/usr/lib/heat/contrail_heat':
    ensure => 'link',
    target => '/usr/lib/python2.7/site-packages/vnc_api/gen/heat',
  }

  $contrail_heat_config = { 'path' => '/etc/heat/heat.conf' }

  create_ini_settings($heat_config, $contrail_heat_config)
}
