class contrail::analyticsdb::contrailctl () {

  file { '/etc/contrailctl':
    ensure => 'directory',
  }

  file {'/etc/contrailctl/analyticsdb.conf':
    ensure => 'file',
  }
}
