# Class: cobbler::params
#
#   The cobbler default configuration settings.
#
class cobbler::params {
  case $::osfamily {
    'RedHat': {
      $service_name       = 'cobblerd'
      $package_name        = 'cobbler'
      $package_name_web    = 'cobbler-web'
      $tftp_package        = 'tftp-server'
      $syslinux_package    = 'syslinux'
      $http_config_prefix  = '/etc/httpd/conf.d'
      $proxy_config_prefix = '/etc/httpd/conf.d'
      $distro_path         = '/distro'
      $apache_service      = 'httpd'
      $default_kickstart   = '/var/lib/cobbler/kickstarts/default.ks'
    }
    'Debian': {
      $service_name        = 'cobbler'
      $package_name        = 'cobbler'
      $package_name_web    = 'cobbler-web'
      $tftp_package        = 'tftpd-hpa'
      $syslinux_package    = 'syslinux'
      $http_config_prefix  = '/etc/apache2/conf.d'
      $proxy_config_prefix = '/etc/apache2/conf.d'
      $distro_path         = '/var/www/cobbler/ks_mirror'
      $apache_service      = 'apache2'
      $default_kickstart   = '/var/lib/cobbler/kickstarts/ubuntu-server.preseed'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} currently only supports osfamily RedHat")
    }
  }
  $package_ensure = 'present'

  # class containing all module dependencies
  $dependency_class = '::cobbler::dependency'

  # location of the cobbler web root
  $webroot = '/var/www/cobbler'
  $reporoot = '/var/www/cobbler/repo_mirror'
  $pleskroot = '/var/www/plesk/'
  $repo_ip_allow = ['all']
  # general settings
  $next_server_ip = $::ipaddress
  $server_ip      = $::ipaddress
  $nameservers    = ['8.8.8.8', '8.8.4.4']

  # default root password for kickstart files
  $defaultrootpw = 'bettergenerateityourself'

  # dhcp options
  $manage_dhcp        = 1
  $dhcp_option        = 'isc'
  $dhcp_interfaces    = split($::interfaces, ',')
  $dhcp_subnets       = ''

  # dns options
  $manage_dns = 1
  $dns_option = 'bind'
  $named_acl_trusted = ''

  # tftpd options
  $manage_tftpd = 1
  $tftpd_option = 'in_tftpd'

  # puppet integration setup
  $puppet_auto_setup                     = 1
  $sign_puppet_certs_automatically       = 1
  $remove_old_puppet_certs_automatically = 1

  # depends on apache
  # access, regulated through Proxy directive
  $allow_access = "${server_ip} 127.0.0.1"

  # authorization
  $auth_module = 'authn_denyall'

  # signature url
  $signature_url = 'http://cobbler.github.io/signatures/2.6.x/latest.json'

}
