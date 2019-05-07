#class motd {
#  file { "/etc/motd":
#   ensure => "present",
#   content => file ('motd/message')
#       }
#           }

##------------------------------

class motd  ($var="Daily"){
 $allowed = ['^Daily$','^Weekly$']
 validate_re($var,$allowed)
 file { "/etc/motd":
   ensure => "present",
   content => file("motd/$var")
 
 }

}

##-------------------------------
#
#




