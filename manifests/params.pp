# == Class: contrail::params
#
class contrail::params(
  $analytics                  = {},
  $analyticsdatabase          = {},
  $container_tag              = hiera('contrail::container::tag', '4.0.1.0-25'),
  $container_url              = hiera('contrail::container::url', undef),
  $config                     = {},
  $control                    = {},
  $database                   = {},
  $webui                      = {},
  $version                    = 4,
) {
  $control_package_name = ['contrail-openstack-control']
  $config_package_name = ['contrail-openstack-config']
  $analytics_package_name = ['contrail-openstack-analytics']
  $webui_package_name = ['contrail-openstack-webui']
  $database_package_name = ['contrail-openstack-database']
  $vrouter_package_name = ['contrail-openstack-vrouter']

  if $::osfamily != 'RedHat' {
    $container_ver=downcase("${::operatingsystem}${::operatingsystemrelease}")
  } else {
    $container_ver='redhat7'
  }

  $analytics_container_name = "contrail-analytics-${container_ver}-${container_tag}"
  $analyticsdb_container_name = "contrail-analyticsdb-${container_ver}-${container_tag}"
  $controller_container_name = "contrail-controller-${container_ver}-${container_tag}"

  $analytics_container_image = "contrail-analytics-${container_ver}:${container_tag}"
  $analyticsdb_container_image = "contrail-analyticsdb-${container_ver}:${container_tag}"
  $controller_container_image = "contrail-controller-${container_ver}:${container_tag}"
}
