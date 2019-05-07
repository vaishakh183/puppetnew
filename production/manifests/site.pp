



#node "osdnode1" {
# include motd
# include user_account
#include chrony
#}


#node "osdnode2" {
#include ntp
#}   

node  "monitornode"{
#include cobbler
include ntp
}


node "default" {
 notify {"This is a production Environment":
     }
}
