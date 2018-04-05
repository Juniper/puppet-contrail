# == Class: contrail::control
#
# Install and configure the control service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for control
#
class contrail::control (
  $control_config         = {},
  $contrail_version       = '',
  $control_nodemgr_config = {},
  $dns_config             = {},
  $package_name           = $contrail::params::control_package_name,
  $secret,
  $manage_named           = 'true',
) inherits contrail::params {

  anchor {'contrail::control::start': } ->
  class {'::contrail::control::install': } ->
  class {'::contrail::control::config':
    contrail_version       => $contrail_version,
    control_config         => $control_config,
    control_nodemgr_config => $control_nodemgr_config,
    dns_config             => $dns_config,
    secret                 => $secret,
    manage_named           => $manage_named,
  } ->
  class {'::contrail::control::service': } ->
  anchor {'contrail::control::end': }
  
}
