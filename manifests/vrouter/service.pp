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

  $service_name = 'supervisor-vrouter'
  File<||> -> Service<| name == $service_name |>
  Ini_setting<||> -> Service<| name == $service_name |>
  File_line<||> -> Service<| name == $service_name |>

  service {'supervisor-vrouter' :
    ensure => running,
    enable => true,
  }
  if $step == 5 and $is_dpdk {
    # hacks: there are races sometime, easy hack to just check status and restart
    exec { 'restart contrail-vrouter-agent if down':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      command => 'supervisorctl -c /etc/contrail/supervisord_vrouter.conf restart contrail-vrouter-agent && /bin/sleep 10',
      unless  => 'contrail-status | grep -q "contrail-vrouter-agent[ ]\+active"',
      require => Service['supervisor-vrouter'],
    } ->
    exec { 'restart contrail-vrouter-nodemgr if down':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      command => 'supervisorctl -c /etc/contrail/supervisord_vrouter.conf restart contrail-vrouter-nodemgr',
      unless  => 'contrail-status | grep -c "\(contrail-vrouter-nodemgr\|contrail-vrouter-agent\)[ ]\+active" | grep 2',
      require => Service['supervisor-vrouter'],
    } ->
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
