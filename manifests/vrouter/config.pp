# == Class: contrail::vrouter::config
#
# Configure the vrouter service
#
# === Parameters:
#
# [*vhost_ip*]
#   (optional) IP of the vrouter agent
#   Defaults to '127.0.0.1'
#
# [*discovery_ip*]
#   (optional) IP of the discovery service
#   Defaults to '127.0.0.1'
#
# [*device*]
#   (optional) Network device
#   Defaults to 'eth0'
#
# [*kmod_path*]
#   (optional) full path for vrouter.ko
#   Defaults to '/lib/modules/${::kernelrelease}/extra/net/vrouter/vrouter.ko
#
# [*compute_device*]
#   (optional) Network device for Openstack compute
#   Defaukts to 'eth0;
#
# [*mask*]
#   (optional) Netmask in CIDR form
#   Defaults '24'
#
# [*netmask*]
#   (optional) Full netmask
#   Defaults '255.255.255.0'
#
# [*gateway*]
#   (optional) Gateway IP address
#   Defaults to '127.0.0.1'
#
# [*vgw_public_subnet*]
#   (optional) Virtual Gateway public subnet
#   Defaults to undef
#
# [*vgw_interface*]
#   (optional) Virtual Gateway interface
#   Defaults to undef
#
# [*macaddr*]
#   (optional) Mac address
#   Defaults to $::macaddr
#
# [*vrouter_agent_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-vrouter-agent.conf
#   Defaults {}
#
# [*vrouter_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-vrouter-nodemgr.conf
#   Defaults {}
#
class contrail::vrouter::config (
  $step = hiera('step'),
  $compute_device         = 'eth0',
  $discovery_ip           = '127.0.0.1',
  $device                 = 'eth0',
  $gateway                = '127.0.0.1',
  $is_tsn                 = undef,
  $is_dpdk                = undef,
  $kmod_path              = "vrouter",
  $macaddr                = $::macaddress,
  $mask                   = '24',
  $netmask                = '255.255.255.0',
  $keystone_config        = {},
  $vhost_ip               = '127.0.0.1',
  $vgw_public_subnet      = undef,
  $vgw_interface          = undef,
  $vrouter_agent_config   = {},
  $vrouter_nodemgr_config = {},
  $vnc_api_lib_config     = {},
) inherits contrail::params {

#  include ::contrail::vnc_api
#  include ::contrail::ctrl_details
#  include ::contrail::service_token
#
  file { '/etc/contrail/contrail-keystone-auth.conf':
    ensure => file,
  }

  if $version < 4 {
    $keystone_cfg = $keystone_config
    $agent_cfg    = $vrouter_agent_config
    $nodemgr_cfg  = $vrouter_nodemgr_config
    $vnc_api_cfg  = $vnc_api_lib_config
  } else {
    $keystone_cfg = undef
    $_keystone_cfg = $keystone_config['KEYSTONE']
    # TODO: read parameters from input paramerers
    $_web_server = hiera('contrail_config_vip', hiera('internal_api_virtual_ip'))
    $_web_port = hiera('contrail::api_port', 8082)
    $_vnc_api_cfg_blobal = {
      'global' => {
        'WEB_SERVER'  => $_web_server,
        'WEB_PORT'    => $_web_port,
      }
    }
    if $_keystone_cfg and $_keystone_cfg['auth_host'] {
      $_vnc_api_cfg_auth = {
        'auth' => {
          'AUTHN_TYPE'      => 'keystone',
          'AUTHN_SERVER'    => $_keystone_cfg['auth_host'],
          'AUTHN_PROTOCOL'  => $_keystone_cfg['auth_protocol'],
          'AUTHN_PORT'      => $_keystone_cfg['auth_port'],
          'insecure'        => $_keystone_cfg['insecure'],
          'certfile'        => $_keystone_cfg['certfile'],
          'cafile'          => $_keystone_cfg['cafile'],
        }
      }
    } else {
      $_vnc_api_cfg_auth = {
        'auth' => {
          'AUTHN_TYPE' => 'noauth',
        }
      }
    }
    $vnc_api_cfg = deep_merge($_vnc_api_cfg_blobal, $_vnc_api_cfg_auth)

    $_analytics_nodes = join(suffix(hiera('contrail_analytics_node_ips'), ':8086'), ' ')
    $nodemgr_cfg = {
      'COLLECTOR' => {
        'server_list' => $_analytics_nodes,
      }
    }

    $_cfg_nodes = hiera('contrail_config_node_ips')
    $_control_nodes = join(suffix($_cfg_nodes, ':5269'), ' ')
    $_dns_nodes = join(suffix($_cfg_nodes, ':53'), ' ')
    $_ssl_enabled = hiera('contrail_ssl_enabled', false)
    $_agent_cfg = {
      'CONTROL-NODE' => {
        'servers' => $_control_nodes,
      },
      'DNS' => {
        'servers' => $_dns_nodes,
      },
      'DEFAULT' => {
        'collectors'                      => $_analytics_nodes,
        'xmpp_auth_enable'                => $_ssl_enabled,
        'xmpp_dns_auth_enable'            => $_ssl_enabled,

      },
      'SANDESH' => {
        'introspect_ssl_enable'           => $_ssl_enabled,
        'sandesh_ssl_enable'              => $_ssl_enabled,
      }
    }

    $agent_cfg = deep_merge($vrouter_agent_config, $_agent_cfg)
  }

  validate_hash($agent_cfg)
  validate_hash($nodemgr_cfg)
  validate_hash($vnc_api_cfg)

  $contrail_vrouter_agent_config = { 'path' => '/etc/contrail/contrail-vrouter-agent.conf' }
  $contrail_vrouter_nodemgr_config = { 'path' => '/etc/contrail/contrail-vrouter-nodemgr.conf' }
  $contrail_vnc_api_lib_config = { 'path' => '/etc/contrail/vnc_api_lib.ini' }

  if $keystone_cfg {
    validate_hash($keystone_cfg)
    $contrail_keystone_config = { 'path' => '/etc/contrail/contrail-keystone-auth.conf' }
    create_ini_settings($keystone_cfg, $contrail_keystone_config)
  }
  create_ini_settings($agent_cfg, $contrail_vrouter_agent_config)
  create_ini_settings($nodemgr_cfg, $contrail_vrouter_nodemgr_config)
  create_ini_settings($vnc_api_cfg, $contrail_vnc_api_lib_config)

  if $step == 5 and !$is_tsn {
    file { '/nova_libvirt.patch' :
      ensure  => file,
      content => template('contrail/vrouter/nova_libvirt.patch.erb'),
    } ->
    file_line { 'patch nova':
      ensure => present,
      path   => '/usr/lib/python2.7/site-packages/nova/virt/libvirt/designer.py',
      line   => '    conf.script = None',
      match  => '^\ \ \ \ conf.script\ \=',
    }
  }

  if $is_dpdk {
    ini_setting { "libvirt_vif_driver":
      ensure  => present,
      path    => '/etc/nova/nova.conf',
      section => 'DEFAULT',
      setting => 'libvirt_vif_driver',
      value   => 'nova_contrail_vif.contrailvif.VRouterVIFDriver',
    }
    ini_setting { "use_userspace_vhost":
      ensure  => present,
      path    => '/etc/nova/nova.conf',
      section => 'CONTRAIL',
      setting => 'use_userspace_vhost',
      value   => 'true',
    }
    ini_setting { "use_huge_pages":
      ensure  => present,
      path    => '/etc/nova/nova.conf',
      section => 'LIBVIRT',
      setting => 'use_huge_pages',
      value   => 'true',
    }
  }

  file { '/etc/contrail/agent_param' :
    ensure  => file,
    content => template('contrail/vrouter/agent_param.erb'),
  }

  file { '/etc/contrail/default_pmac' :
    ensure  => file,
    content => $macaddr,
  }

  if !$is_dpdk {
    file { '/etc/contrail/vrouter_nodemgr_param' :
      ensure  => file,
      content => "DISCOVERY=${discovery_ip}",
    }
  }
  if $::ipaddress_vhost0 != $vhost_ip {
    file { '/opt/contrail/utils/update_dev_net_config_files.py':
      ensure => file,
      source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/update_dev_net_config_files.py',
    } ->
    exec { '/bin/python /opt/contrail/utils/update_dev_net_config_files.py' :
      path => '/usr/bin',
      command => "/bin/python /opt/contrail/utils/update_dev_net_config_files.py \
                   --vhost_ip ${vhost_ip} \
                   --dev ${device} \
                   --compute_dev ${device} \
                   --netmask ${netmask} \
                   --gateway ${gateway} \
                   --cidr ${vhost_ip}/${mask} \
                   --mac ${macaddr}",
    }
  }
}
