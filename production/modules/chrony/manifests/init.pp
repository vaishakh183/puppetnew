class chrony ( $version = 'present', $server  = '0.centos.pool.ntp.org',  $enable  = 'true', $start   = 'true') {
 
#   class {'chrony::install':}
include chrony::install
}
