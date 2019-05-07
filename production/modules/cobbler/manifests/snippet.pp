define cobbler::snippet {

  file { "/var/lib/cobbler/snippets/${name}" :
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("cobbler/snippets/${name}.erb"),
  }
}
