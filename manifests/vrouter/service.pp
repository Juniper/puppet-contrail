# == Class: contrail::vrouter::service
#
# Manage the vrouter service
#
class contrail::vrouter::service(
  $step = hiera('step'),
  $cidr,
  $gateway,
  $host_ip,
  $is_tsn,
  $is_dpdk,
  $macaddr,
  $physical_interface,
  $vhost_ip,
) {

  service {'supervisor-vrouter' :
    ensure => running,
    enable => true,
  }
  if $is_dpdk {
    exec { 'ifup vhost0' :
      command => "/bin/sleep 10 && /sbin/ifup vhost0 && /sbin/ip link set dev vhost0 address ${macaddr}",
      require => Service['supervisor-vrouter'],
    }
  }
  if $step == 5 and !$is_tsn {
    exec { 'restart nova compute':
      path => '/bin',
      command => "systemctl restart openstack-nova-compute",
    }
  }
}
