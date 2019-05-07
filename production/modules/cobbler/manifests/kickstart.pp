define cobbler::kickstart {

  file { "/var/lib/cobbler/kickstarts/custom/${name}" :
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("cobbler/kickstarts/${name}.erb"),
  }
}
