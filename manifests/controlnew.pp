# == Class: contrail::control
#
# Install and configure the control service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for control
#
class contrail::controlnew (
  $control_config         = {},
  $control_nodemgr_config = {},
  $dns_config             = {},
  $package_name           = $contrail::params::control_package_name,
  $secret,
) inherits contrail::params {

  anchor {'contrail::controlnew::start': } ->
  class {'::contrail::controlnew::install': } ->
  class {'::contrail::controlnew::config':
    control_config         => $control_config,
    control_nodemgr_config => $control_nodemgr_config,
    dns_config             => $dns_config,
    secret                 => $secret,
  } ~>
  class {'::contrail::controlnew::service': }
  anchor {'contrail::controlnew::end': }
  
}
