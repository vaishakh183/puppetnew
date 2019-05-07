class ntp::config (
$ntp_local_server,
$ntp_regional_server,
$ntp_monitor,
$admingroup,
){

file { '/etc/chrony.conf':
   content => epp ('ntp/ntp.conf.epp', {
      'monitor'             => $ntp_monitor,
      'ntp_local_server'    => $ntp_local_server,
      'ntp_regional_server' => $ntp_regional_server,
}
),

   owner => 'root',
   group => 'root',
   mode  => '664',
   ensure => 'file',
    }


}
