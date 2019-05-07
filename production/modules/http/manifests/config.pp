class http::config {
  
file {"/etc/httpd/conf.d/test.conf":
   notify => Service['httpd'],
#   ensure => file,
   content => template("http/testserver.conf.erb"),
    }

   }
