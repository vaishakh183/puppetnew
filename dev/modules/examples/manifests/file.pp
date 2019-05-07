class examples::file {
     file{"examplefile":
       path     => "/tmp/examplefile",
       source   => 'puppet:///modules/examples/examplefile',         ##------ /// is for making server field blank.So it checks for file on puppet server
       } 

     }
