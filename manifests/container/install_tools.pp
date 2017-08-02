
class contrail::container::install_tools {

  $docker_package = $::operatingsystem ? {
    'CentOS'  => 'docker-engine',
    default   => 'docker',
  }
  package { 'wget' :
    ensure => installed,
  } ->
  package { $docker_package :
    ensure => installed,
  } ->
  service { 'docker' :
    ensure => 'running',
    enable => true,
  }->
  file { '/etc/contrailctl':
    ensure => directory,
  }
}

