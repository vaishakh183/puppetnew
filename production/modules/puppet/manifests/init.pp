#class puppet {
   
#  package { 'puppet-agent':
#      ensure => 'latest',
#           }

#  service { 'puppet':
#      ensure => 'stopped',
#      enable => false,
#      require => Package['puppet-agent'],
#      }
#        }



class puppet {

  package { 'puppet-agent':
      ensure => 'latest',
           }
   service { 'puppet':
      ensure => hiera('puppet_status'),
      enable => hiera('puppet_enable'),
      require => Package['puppet-agent'],
      }
        }


