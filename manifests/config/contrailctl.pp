class contrail::config::contrailctl () {

  file { '/etc/contrailctl':
    ensure => 'directory',
  }

  file {'/etc/contrailctl/controller.conf':
    ensure => 'file',
  }
}
