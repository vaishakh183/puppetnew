class examples::template {
         file {"exampletemplate":
              path     => "/tmp/exampletemplate",
              content  => template('examples/example-template.erb')

          }

       }
