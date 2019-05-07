class cobbler::cobblerconfig { 

  file { "/etc/cobbler/config":
    ensure => "present"
       }

 file_line {'server ip':
    ensure => "present",
    path   => "/etc/cobbler/config",
    match  => "^server: 127.0.0.1",
    line   => "server: 192.168.122.179"

           }

 file_line {'nextserver ip':
    ensure => "present",
    path   => "/etc/cobbler/config",
    match  => "^next_server: 127.0.0.1",
    line   => "next_server: 192.168.122.179"

           }


                      }
