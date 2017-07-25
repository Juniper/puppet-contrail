# == Class: contrail::heat::install
#
# Install the heat plugin
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for config
#
class contrail::heat::install (
) {
  package { 'contrail-heat' :
    ensure => latest,
  }

}
