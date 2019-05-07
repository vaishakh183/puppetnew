class cobbler::dhcpconfig{

 file{ "/etc/cobbler/dhcp.template":
   ensure => "present"
     }

 file_line {"enable_dhcp":
   ensure => "present",
   path   => "/etc/cobbler/dhcp.template",
   match  => "^manage_dhcp: 0",
   line   => "manage_dhcp: 1"
     }
 }

