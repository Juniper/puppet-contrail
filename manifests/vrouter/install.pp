# == Class: contrail::vrouter::install
#
# Install the vrouter service
#
class contrail::vrouter::install (
  $is_dpdk = undef,
) {
  if !$is_dpdk {
    package { 'contrail-vrouter' :
      ensure => latest,
    }
    package { 'contrail-vrouter-init' :
      ensure => latest,
    }
  } else {
    package { 'contrail-nova-vif' :
      ensure => latest,
    }
    package { 'contrail-lib' :
      ensure => latest,
    }
    package { 'contrail-nodemgr' :
      ensure => latest,
    }
  }
  package { 'contrail-vrouter-agent' :
    ensure => latest,
  }
  package { 'contrail-utils' :
    ensure => latest,
  }
  package { 'contrail-setup' :
    ensure => latest,
  }
  package { 'contrail-vrouter-common' :
    ensure => latest,
  }

  if $is_dpdk {
    exec { 'set selinux to permissive' :
      command => '/sbin/setenforce permissive',
    }
    file_line { 'make permissive mode persistant':
      ensure => present,
      path   => '/etc/selinux/config',
      line   => 'SELINUX=permissive',
      match  => '^SELINUX=',
    }
    file {'/etc/contrail/supervisord_vrouter_files/contrail-vrouter.rules' :
      ensure  => file,
      source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/contrail-vrouter.rules',
    }
  }
  exec { 'ldconfig vrouter agent':
      command => '/sbin/ldconfig',
  } ->
  exec { '/sbin/weak-modules --add-kernel' :
    command => '/sbin/weak-modules --add-kernel',
  } ->
  group { 'nogroup':
      ensure => present,
  } ->
  file { '/tmp/contrailselinux.te' :
    ensure  => file,
    source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/contrailselinux.te',
  } ->
  exec { 'checkmodule -M -m -o /tmp/contrailselinux.mod /tmp/contrailselinux.te':
    command => '/bin/checkmodule -M -m -o /tmp/contrailselinux.mod /tmp/contrailselinux.te',
  } ->
  exec { 'semodule_package -o /tmp/contrailselinux.pp -m /tmp/contrailselinux.mod':
    command => '/bin/semodule_package -o /tmp/contrailselinux.pp -m /tmp/contrailselinux.mod',
  } ->
  exec { 'semodule -i /tmp/contrailselinux.pp':
    command => '/sbin/semodule -i /tmp/contrailselinux.pp',
  } ->
  # if selinux is in seneforcing mode there is a like a bug in systemd:
  # 'systemctl unmask supervisor-vrouter' failes with access denied error
  # restart of daemon-reexec is a workaround
  # (https://major.io/2015/09/18/systemd-in-fedora-22-failed-to-restart-service-access-denied/)
  exec { 'systemctl daemon-reexec':
    command => 'systemctl daemon-reexec || true',
    path    => '/bin::/sbin:/usr/bin:/usr/sbin',
    onlyif  => 'sestatus | grep -i "Current mode" | grep -q enforcing',
  }
}
