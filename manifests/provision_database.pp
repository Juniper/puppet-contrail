# == Class: contrail::provision_control
#
# Provision following 3 things
#
#   * database
#
# This class is simply an helper to be included when all three provisions needs
# to be done
#
class contrail::provision_database (
) inherits contrail::params {

  if $version < 4 {
    include ::contrail::control::provision_database
  } else {
    notify { "Skip Contrail provision database in container based deploument": }
  }
}
