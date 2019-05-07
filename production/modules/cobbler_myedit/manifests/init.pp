class cobbler{

$package_list = ['cobbler','dhcp','tftp','dnsmasq','syslinux','pykickstart','xinetd','bind','httpd']
 package { $package_list:
   ensure => present,
}

#package { $::cobbler::params::tftp_package:     ensure => present, }

  


include cobbler::cobblerconfig
include cobbler::dhcpconfig
include cobbler::service

}


