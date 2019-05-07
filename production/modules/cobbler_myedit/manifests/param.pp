
class cobbler::params {

      $service_name       = 'cobblerd'
      $package_name        = 'cobbler'
      $package_name_web    = 'cobbler-web'
      $tftp_package        = 'tftp-server'
      $syslinux_package    = 'syslinux'
      $http_config_prefix  = '/etc/httpd/conf.d'
      $distro_path         = '/distro'
      $apache_service      = 'httpd'
      $default_kickstart   = '/var/lib/cobbler/kickstarts/default.ks'



  #location of the cobbler web root
  $webroot = '/var/www/cobbler'
  $reporoot = '/var/www/cobbler/repo_mirror'


  # general settings
  $next_server_ip = $::ipaddress
  $server_ip      = $::ipaddress
  $nameservers    = ['8.8.8.8', '8.8.4.4']


  # dhcp options
  $manage_dhcp        = 1

  # dns options
  $manage_dns = 1

  # tftpd options
  $manage_tftpd = 1




          }
