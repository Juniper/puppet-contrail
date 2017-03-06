class contrail::analytics::contrailctl () {

  file { '/etc/contrailctl':
    ensure => 'directory',
  }

  file {'/etc/contrailctl/analytics.conf':
    ensure => 'file',
  }
}
