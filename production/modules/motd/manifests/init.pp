class motd($message = "WElcome to Hiera COde" ) {
 
        file {"/etc/motd":
         ensure  => 'file',
         content => $message,     
            }

      }
