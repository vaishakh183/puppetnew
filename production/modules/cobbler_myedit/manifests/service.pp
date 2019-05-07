class cobbler::service {

  service {"cobblerd":
     ensure => "running",
     enable => "true"
          }
 
  service { "dhcpd":
    ensure => "running",
    enable => "true"
       }  

 service { "named":
    ensure => "running",
    enable => "true"
       }

 service { "httpd":
    ensure => "running",
    enable => "true"
       }


}
