# == Class: contrail::control::service
#
# Manage the control service
#
class contrail::control::service {

  service {'supervisor-control' :
    ensure => running,
    enable => true,
  }
  service {'contrail-dns':
    ensure => running,
    enable => true,
    subscribe => File["/etc/contrail/contrail-dns.conf"],
  }
  service {'contrail-named':
    ensure => running,
    enable => true,
    subscribe => File["/etc/contrail/dns/contrail-named.conf"],
  }
  service {'supervisord':
    ensure => running,
    enable => true,
    subscribe => [
      File["/etc/contrail/contrail-dns.conf"],
      File["/etc/contrail/dns/contrail-named.conf"],
    ],
  }

}
