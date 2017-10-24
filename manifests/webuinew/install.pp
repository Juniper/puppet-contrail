# == Class: contrail::webui::install
#
# Install the webui service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for webui
#
class contrail::webuinew::install (
) {

  package { 'contrail-openstack-webui' :
    ensure => latest,
  }

}
