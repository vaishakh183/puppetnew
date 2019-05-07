# Bind zone template file creation

class cobbler::zones inherits cobbler {

  define create_zone_templates($type, $records) {
    file { "/etc/cobbler/zone_templates/${name}":
      content => template("cobbler/${type}.zone.template.erb")
    }
  }

  $records = hiera_hash('cobbler::zones::records', {})

  create_zone_templates { $forward_zones:
    type    => 'forward',
    records => $records,
  }
  create_zone_templates { $reverse_zones:
    type    => 'reverse',
    records => $records,
  }

}
