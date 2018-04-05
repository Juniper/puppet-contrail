# == Class: contrail::config
#
# Install and configure the config service
#
# === Parameters:
#
class contrail::heat (
  $heat_config,
) inherits contrail::params  {

  anchor {'contrail::heat::start': } ->
  class {'::contrail::heat::install': } ->
  class {'::contrail::heat::config': 
    heat_config => $heat_config,
  } ->
  #} ~>
  #class {'::contrail::heat::service': }
  anchor {'contrail::heat::end': }
}

