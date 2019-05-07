class examples::goodbye{
   file {"bye":
       path   => "/tmp/goodbye",
       content => "Good Bye",
      }

}
