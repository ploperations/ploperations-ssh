# @summary Platform independent way to specify an SSH authorized key
define ssh::authorized_key (
  String[1]                  $user    = $title,
  Enum[present, absent]      $ensure  = 'present',
  Optional[Ssh::Key::String] $key     = undef,
  Ssh::Key::Type             $type    = 'ssh-rsa',
  Array[Ssh::Key::Option]    $options = [],
) {
  include ssh::params

  $use_file = $ssh::params::server_class ? {
    'ssh::server::chocolatey' => true,
    'ssh::server::cygwin'     => true,
    default                   => false,
  }

  if $use_file {
    ensure_resource('ssh::authorized_key::file', $user)

    if $ensure == present and $key {
      if $options.length() > 0 {
        $options_string = $options.join(',')
        $prefix = "${options_string} "
      } else {
        $prefix = ''
      }

      Ssh::Authorized_key::File <| title == $user |> {
        lines +> ["${prefix}${type} ${key} ${comment}"],
      }
    }
  } else {
    # ssh_authorized_key works on this platform
    ssh_authorized_key { $title:
      ensure  => $ensure,
      key     => $key,
      type    => $type,
      user    => $user,
      options => $options,
    }
  }
}