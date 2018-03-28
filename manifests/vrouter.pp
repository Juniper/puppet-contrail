# == Class: contrail::vrouter
#
# Install and configure the vrouter service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for vrouter
#
class contrail::vrouter (
  $contrail_version,
  $discovery_ip,
  $gateway,
  $host_ip,
  $is_tsn,
  $is_dpdk,
  $netmask,
  $macaddr,
  $mask,
  $package_name = $contrail::params::vrouter_package_name,
  $physical_interface,
  $vhost_ip,
  $keystone_config = {},
  $vrouter_agent_config = {},
  $vrouter_nodemgr_config = {},
  $vnc_api_lib_config = {},
) inherits contrail::params {

  anchor {'contrail::vrouter::start': } ->
  class {'::contrail::vrouter::install': 
    is_dpdk          => $is_dpdk,
    contrail_version => $contrail_version,
  } ->
  class {'::contrail::vrouter::config':
    compute_device         => $physical_interface,
    contrail_version       => $contrail_version,
    device                 => $physical_interface,
    discovery_ip           => $discovery_ip,
    gateway                => $gateway,
    is_tsn                 => $is_tsn,
    is_dpdk                => $is_dpdk,
    macaddr                => $macaddr,
    mask                   => $mask,
    netmask                => $netmask,
    vhost_ip               => $vhost_ip,
    keystone_config        => $keystone_config,
    vrouter_agent_config   => $vrouter_agent_config,
    vrouter_nodemgr_config => $vrouter_nodemgr_config,
    vnc_api_lib_config     => $vnc_api_lib_config,
  } ->
  class {'::contrail::vrouter::service': 
    cidr               => $mask,
    gateway            => $gateway,
    host_ip            => $host_ip,
    is_tsn             => $is_tsn,
    is_dpdk            => $is_dpdk,
    macaddr            => $macaddr,
    physical_interface => $physical_interface,
    vhost_ip           => $vhost_ip,
  } ->
  anchor {'contrail::vrouter::end': }
}
