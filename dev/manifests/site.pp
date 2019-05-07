
node "default" {
 notify {"This is a Development Environment":}
 include examples::template
 include examples::file
    }

