class examples {
   file { "hi":
     path    => "/tmp/test",
     content => "HIIIIIIIIIIIIIIIIIIIIIII",
}
include examples::goodbye
}
