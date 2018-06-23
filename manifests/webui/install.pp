# == Class: contrail::webui::install
#
# Install the webui service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for webui
#
class contrail::webui::install (
) {
  package { 'yum-plugin-versionlock' :
    ensure => 'latest',
  } ->
# Install JDK package for webui 
  package { 'java-1.8.0-openjdk' :
    ensure => '1.8.0.151-5.b12.el7_4',
  } ->
  exec { 'lock java version':
    command => 'yum versionlock java-1.8.0-openjdk-*',
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  } ->
  package { 'contrail-openstack-webui' :
    ensure => latest,
  }
}
