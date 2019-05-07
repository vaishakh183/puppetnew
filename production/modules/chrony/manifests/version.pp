class chrony::install {
  
   package {'chrony':  
    ensure => $chrony::version
   } 
}
