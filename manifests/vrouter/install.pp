# == Class: contrail::vrouter::install
#
# Install the vrouter service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for vrouter
#
class contrail::vrouter::install (
  $is_dpdk = undef,
  $contrail_version,
) {

  $common_pkgs = [
    'python-gevent',
    'contrail-nova-vif',
    'contrail-vrouter-agent',
  ]
  $no_dpdk_common_pkgs = [
    'contrail-vrouter',
    'contrail-vrouter-init',
  ]
  $v4_pkgs = [
    'contrail-lib',
    'contrail-nodemgr',
    'contrail-utils',
    'contrail-setup',
    'contrail-vrouter-common',
  ]
  $v3_no_dpdk_pkgs = [
    'contrail-openstack-vrouter',
  ]

  if $contrail_version < 4 {
    $ver_pkgs = $v3_no_dpdk_pkgs
  } else {
    $ver_pkgs = $v4_pkgs
  }

  if !$is_dpdk {
    $pkgs = concat(concat($common_pkgs, $ver_pkgs), $no_dpdk_common_pkgs)
    package { $pkgs :
      ensure => latest,
    }
  } else {
    $pkgs = concat($common_pkgs, $ver_pkgs)
    package { $pkgs :
      ensure => latest,
    } ->
    exec { 'set selinux to permissive' :
      command => 'setenforce permissive',
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      onlyif  => 'sestatus | grep -i "Current mode" | grep -q enforcing',
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
  exec { 'enable vrouter supervisor daemon':
    command => '/bin/systemctl enable supervisor-vrouter',
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
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    onlyif  => 'sestatus | grep -i "Current mode" | grep -q enforcing',
  }
}
