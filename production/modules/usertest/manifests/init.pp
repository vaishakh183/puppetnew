#class user_account{
 
# user { testuser:
#   ensure => 'present',
#   home   => '/home/testuser',
#   shell  => '/bin/bash'
#      }
  
#}


# node 'osdnode2' {
#  
#     class { 'user_account':  
#           username => 'testuser'  }   
#               }

# node 'default' {
#                   }



class usertest {
 
   user {'test user':
      name  => lookup('newuser'),
      home  => '/home/newuser',
      shell => '/bin/bash',

      }
         }
