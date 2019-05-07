#class ntp::service {

#service { "chronyd":
# ensure => "stopped",
# enable => "true"
#}

#}



class ntp::service (
 $ntp_service
)
   {

  service  {'NTP service':
    ensure   => 'stopped',
    enable   => true,
    name     => $ntp_service,
    subscribe  => Class[ntp::config],     
     }

 }
