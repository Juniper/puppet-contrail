# == Class: contrail::config::service
#
# Manage the config service
#
class contrail::config::service {

  service {'supervisor-config' :
    ensure => running,
    enable => true,
  }
  # hack to work around https://bugs.launchpad.net/juniperopenstack/+bug/1718184
  exec { 'restart config-api':
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => 'supervisorctl -c /etc/contrail/supervisord_config.conf restart contrail-api:0',
  }
}

