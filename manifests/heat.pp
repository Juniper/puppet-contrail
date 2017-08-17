# == Class: contrail::config
#
# Install and configure the config service
#
# === Parameters:
#

class contrail::heat (
  $heat_config,
) inherits contrail::params  {

  if $version < 4 {
    anchor {'contrail::heat::start': } ->
    class {'::contrail::heat::install': } ->
    class {'::contrail::heat::config':
      heat_config => $heat_config,
    }
    #} ~>
    #class {'::contrail::heat::service': }
    anchor {'contrail::heat::end': }
  } else {
    notify { "Skip Contrail-Heat configuration in container based deploument": }
  }
}

