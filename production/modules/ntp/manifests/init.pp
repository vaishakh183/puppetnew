#Managed by Puppet - Do not edit
#class ntp {

#file { '/etc/chrony.conf':
#   owner => 'root',
#   group => 'root',
#   mode  => '664',
#   ensure => 'file'
#    }
#include ntp::service
#}


#if we want to call another call with parameters we can use class inside a class as below instead of 'include'.


class ntp (
$ntp_local_server = 'ntp.ubuntu.org',
$ntp_regional_server = 'uk.pool.ntp.org',
$ntp_monitor = false,
$ntp_service = 'chrony',
$admingroup = 'wheel',
)
{

    
   class { ntp::config:
      ntp_local_server       => $ntp_local_server,
      ntp_regional_server    => $ntp_regional_server,
      ntp_monitor            => $ntp_monitor,
      admingroup             => $admingroup, 
}

  
  class { ntp::service:
      ntp_service            => $ntp_service,    
     }


}
