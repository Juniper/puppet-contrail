# Puppet-contrail

[![License](http://img.shields.io/:license-apache2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)

#### Table of Contents

1. [Module Description - What does the module do?](#module-description)
2. [Setup OpenStack Cloud with Contrail Networking](#setup-openstack-cloud-with-contrail-networking)

Module Description
------------------

The puppet-contrail module is a thorough attempt to make Puppet capable of managing the entirety of OpenContrail. The current implementation is limited to support Contrail v4.0 and to be used together with [RDO](https://www.rdoproject.org/), [Contral TripleO Heat Templates](https://github.com/Juniper/contrail-tripleo-heat-templates) and [Contrail TripleO Puppet](https://github.com/Juniper/contrail-tripleo-puppet).

Setup OpenStack Cloud with Contrail Networking
----------------------------------------------

### The overall instruction is described [here](https://github.com/Juniper/contrail-tripleo-heat-templates/blob/master/README.md). Follow it with the changes below:

* If you wnat to use [CentOS based images](https://cloud.centos.org/centos/7/images/) you will have to build own overcloud images for Compute nodes with Trove service excluded. This is because Trove depends on python2-xml2dict package that conflicts with the custom Contrail package xmltodict-0.7.0-0contrail.el7.noarch.rpm.

* At the step 'Undercloud configuration / get contrail' download Contrail v4.0 install packages and docker containers
(there is an assumption that you have acces to Juniper build server 10.84.5.120)
```
wget http://10.84.5.120/github-build/R4.0/LATEST/redhat70/newton/contrail-install-packages-4.0.0.0-20~newton.el7.noarch.rpm
sudo rpm -ivh contrail-install-packages-4.0.0.0-20~newton.el7.noarch.rpm
sudo tar -zxvf /opt/contrail/contrail_packages/contrail_rpms.tgz -C /var/www/html/contrail
wget http://10.84.5.120/github-build/R4.0/LATEST/redhat70/newton/contrail-docker-images_4.0.0.0-20.tgz
sudo tar -zxvf contrail-docker-images_4.0.0.0-20.tgz -C /var/www/html/contrail/
```

* At the step 'Configure overcloud / get puppet modules' use this puppet-contrail module.
```
mkdir -p ~/usr/share/openstack-puppet/modules
git clone https://github.com/Juniper/contrail-tripleo-puppet -b stable/newton ~/usr/share/openstack-puppet/modules/tripleo
git clone https://github.com/alexey-mr/puppet-contrail -b stable/newton ~/usr/share/openstack-puppet/modules/contrail
tar czvf puppet-modules.tgz usr/
```

*  If you use CentOS based images add openstack-utils packet into Contrail rpm repo. It is needed since CentOS images don't have this packet installed but Contrail requires it.
```
sudo wget -P /var/www/html/contrail  http://mirror.comnet.uz/centos/7/cloud/x86_64/openstack-newton/common/openstack-utils-2017.1-1.el7.noarch.rpm
sudo createrepo --update -v /var/www/html/contrail
```
