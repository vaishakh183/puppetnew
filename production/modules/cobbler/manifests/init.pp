# Class: cobbler
#
# This class manages Cobbler
# https://fedorahosted.org/cobbler/
#
# Parameters:
#
#   - $service_name [type: string]
#     Name of the cobbler service, defaults to 'cobblerd'.
#
#   - $package_name [type: string]
#     Name of the installation package, defaults to 'cobbler'
#
#   - $package_ensure [type: string]
#     Defaults to 'present', buy any version can be set
#
#   - $distro_path [type: string]
#     Defines the location on disk where distro files will be
#     stored. Contents of the ISO images will be copied over
#     in these directories, and also kickstart files will be
#     stored. Defaults to '/distro'
#
#   - $manage_dhcp [type: bool]
#     Wether or not to manage ISC DHCP.
#
#   - $dhcp_dynamic_range [type: string]
#     Range for DHCP server
#
#   - $manage_dns [type: string]
#     Wether or not to manage DNS
#
#   - $dns_option [type: string]
#     Which DNS deamon to manage - Bind or dnsmasq. If dnsmasq,
#     then dnsmasq has to be used for DHCP too.
#
#   - $manage_tftpd [type: bool]
#     Wether or not to manage TFTP daemon.
#
#   - $tftpd_option [type:string]
#     Which TFTP daemon to use.
#
#   - $server_ip [type: string]
#     IP address of a server.
#
#   - $next_server_ip [type: string]
#     Next Server in cobbler config.
#
#   - $nameservers [type: array]
#     Nameservers for kickstart files to put in resolv.conf upon
#     installation.
#
#   - $dhcp_interfaces [type: array]
#     Interface for DHCP to listen on.
#
#   - $dhcp_subnets [type: array]
#     If you use *DHCP relay* on your network, then $dhcp_interfaces
#     won't suffice. $dhcp_subnets have to be defined, otherwise,
#     DHCP won't offer address to a machine in a network that's
#     not directly available on the DHCP machine itself.
#
#   - $defaultrootpw [type: string]
#     Hash of root password for kickstart files.
#
#   - $apache_service [type: string]
#     Name of the apache service.
#
#   - $allow_access [type: string]
#     For what IP addresses/hosts will access to cobbler_api be granted.
#     Default is for server_ip, ::ipaddress and localhost
#
#   - $purge_distro  [type: bool]
#   - $purge_repo    [type: bool]
#   - $purge_profile [type: bool]
#   - $purge_system  [type: bool]
#     Decides wether or not to purge (remove) from cobbler distro,
#     repo, profiles and systems which are not managed by puppet.
#     Default is false.
#
#   - default_kickstart [type: string]
#     Location of the default kickstart. Default depends on $::osfamily.
#
#   - webroot [type: string]
#     Location of Cobbler's web root. Default: '/var/www/cobbler'.
#
#   - create_resources [type: bool]
#     Automatically create resources from hiera hashes. Default: false
#
# Actions:
#   - Install Cobbler
#   - Manage Cobbler service
#
# Requires:
#   - puppetlabs/apache class
#     (http://forge.puppetlabs.com/puppetlabs/apache)
#
# Sample Usage:
#
class cobbler (
  $service_name       = $::cobbler::params::service_name,
  $package_name       = $::cobbler::params::package_name,
  $package_ensure     = $::cobbler::params::package_ensure,
  $distro_path        = $::cobbler::params::distro_path,
  $manage_dhcp        = $::cobbler::params::manage_dhcp,
  $dhcp_option        = $::cobbler::params::dhcp_option,
  $dhcp_dynamic_range = $::cobbler::params::dhcp_dynamic_range,
  $manage_dns         = $::cobbler::params::manage_dns,
  $dns_option         = $::cobbler::params::dns_option,
  $manage_tftpd       = $::cobbler::params::manage_tftpd,
  $tftpd_option       = $::cobbler::params::tftpd_option,
  $server_ip          = $::cobbler::params::server_ip,
  $next_server_ip     = $::cobbler::params::next_server_ip,
  $nameservers        = $::cobbler::params::nameservers,
  $dhcp_interfaces    = $::cobbler::params::dhcp_interfaces,
  $dhcp_subnets       = $::cobbler::params::dhcp_subnets,
  $defaultrootpw      = $::cobbler::params::defaultrootpw,
  $apache_service     = $::cobbler::params::apache_service,
  $allow_access       = $::cobbler::params::allow_access,
  $purge_distro       = false,
  $purge_repo         = false,
  $purge_profile      = false,
  $purge_system       = false,
  $default_kickstart  = $::cobbler::params::default_kickstart,
  $webroot            = $::cobbler::params::webroot,
  $auth_module        = $::cobbler::params::auth_module,
  $create_resources   = false,
  $repo_ip_allow      = $::cobbler::params::repo_ip_allow,
  $named_acl_trusted  = $::cobbler::params::named_acl_trusted,
  $reporoot           = $::cobbler::params::reporoot,
  $pleskroot          = $::cobbler::params::pleskroot,
  $dependency_class   = $::cobbler::params::dependency_class,
  $signature_url      = $::cobbler::params::signature_url,
) inherits cobbler::params {

  $forward_zones = hiera('cobbler::forward_zones', [])
  $reverse_zones = hiera('cobbler::reverse_zones', [])

  # include dependencies
  if $::cobbler::dependency_class {
    include $::cobbler::dependency_class
  }

  # install section
  package { $::cobbler::params::tftp_package:     ensure => present, }
  package { $::cobbler::params::syslinux_package: ensure => present, }
  package { 'cobbler':
    ensure  => $package_ensure,
    name    => $package_name,
    require => [ Package[$::cobbler::params::syslinux_package], Package[$::cobbler::params::tftp_package] ],
  }

  service { 'cobbler':
    ensure  => running,
    name    => $service_name,
    enable  => true,
    require => Package['cobbler']
  }

  service { 'xinetd':
    ensure  => running,
    require => Exec['cobblersync']
  }

  # file defaults
  File {
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
  }
  file { "${::cobbler::params::proxy_config_prefix}/proxy_cobbler.conf":
    content => template('cobbler/proxy_cobbler.conf.erb'),
    notify  => Service['httpd'],
  }
  file { $distro_path :
    ensure => directory,
    mode   => '0755',
  }

  # kickstarts
  file { "/var/lib/cobbler/kickstarts/custom" :
    ensure  => directory,
    mode    => '0755',
    recurse => true,
    force   => true,
    purge   => true,
    require => Package['cobbler']
  }

  $kickstarts = hiera_array('cobbler::kickstarts', [])
  ::cobbler::kickstart { $kickstarts: }

  $snippets = hiera_array('cobbler::snippets', [])
  ::cobbler::snippet { $snippets: }

  file { '/etc/cobbler/settings':
    content => template('cobbler/settings.erb'),
    require => Package['cobbler'],
    notify  => Service['cobbler'],
  }
  file { '/etc/cobbler/modules.conf':
    content => template('cobbler/modules.conf.erb'),
    require => Package['cobbler'],
    notify  => Service['cobbler'],
  }
  file { "${::cobbler::params::http_config_prefix}/distros.conf": content => template('cobbler/distros.conf.erb'), }
  file { "${::cobbler::params::http_config_prefix}/cobbler.conf": content => template('cobbler/cobbler.conf.erb'), }

  # cobbler sync command
  exec { 'cobblersync':
    command     => '/usr/bin/cobbler sync',
    refreshonly => true,
    require     => [ Service['cobbler'], Service['httpd'] ],
  }

  # include ISC DHCP only if we choose manage_dhcp
  if $manage_dhcp == '1' {
    $dhcp_package = $dhcp_option ? {
      'isc'     => 'dhcp',
      'dnsmasq' => 'dnsmasq',
    }
    $dhcp_service = $dhcp_option ? {
      'isc'     => 'dhcpd',
      'dnsmasq' => 'dnsmasq',
    }
    package { $dhcp_package:
      ensure => present
    }
    service { $dhcp_service:
      enable  => true,
      require => Package[$dhcp_package],
    }
    file { "/etc/cobbler/${dhcp_package}.template":
      ensure  => present,
      content => template("cobbler/${dhcp_package}.template.erb"),
      require => Package['cobbler'],
      notify  => Exec['cobblersync'],
    }
  }

  # include bind only if we choose manage_dns
  if $manage_dns == '1' and $dns_option == 'bind' and $dhcp_option == 'isc' {
    package { $dns_option:
      ensure => present
    }
    service { 'named':
      ensure  => running,
      enable  => true,
      require => [
        File['/etc/cobbler/named.template'],
        Package['bind'],
        Exec['cobblersync'],
      ],
    }
    file { '/etc/cobbler/named.template':
      ensure  => present,
      content => template('cobbler/named.template.erb'),
      require => Package['cobbler'],
      notify  => Exec['cobblersync'],
    }
    class { '::cobbler::zones':
      require => Package['cobbler'],
      notify  => Exec['cobblersync'],
    }
  }

  # resource defaults
  resources { 'cobblerdistro':
    purge   => $purge_distro,
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  resources { 'cobblerrepo':
    purge   => $purge_repo,
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  resources { 'cobblerprofile':
    purge   => $purge_profile,
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  resources { 'cobblersystem':
    purge   => $purge_system,
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  # create resources from hiera
  if ( $create_resources == true ) {
    create_resources(cobblerrepo,    hiera_hash('cobbler::repos',    {}) )
    create_resources(cobblerdistro,  hiera_hash('cobbler::distros',  {}) )
    create_resources(cobblerprofile, hiera_hash('cobbler::profiles', {}) )
    create_resources(cobblersystem,  hiera_hash('cobbler::systems',  {}) )
  }

}


# vi:nowrap:
