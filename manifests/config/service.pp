# == Class: contrail::config::service
#
# Manage the config service
#
class contrail::config::service {

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

