# @summary Platform independent way to specify an SSH authorized key
#
# @param [String[1]] user The user account in which the SSH key should be installed.
#
# @param [Enum[present, absent]] ensure The ensure value for the ssh authorized key resource.
#
# @param [Optional[Ssh::Key::String]] key The public key itself.
#
# @param [Ssh::Key::Type] type The encryption type used.
#
# @param [Array[Ssh::Key::Option]] options Key options; see sshd(8) for possible values.
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
    if $ensure == present and $key {
      if $options.length() > 0 {
        $options_string = $options.join(',')
        $prefix = "${options_string} "
      } else {
        $prefix = undef
      }

      $line = "${prefix}${type} ${key} ${title}"
      concat::fragment { "ssh::authorized_key::file ${title} ${line}":
        order   => '10', # then ordered by title
        target  => "ssh::authorized_key::file ${user}",
        content => ssh::fix_eol("${line}\n"),
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
