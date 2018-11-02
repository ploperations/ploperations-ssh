# Set up an authorized key file on Windows with, optionally, a key in it.
#
# $ensure determines whether the file should exist.
# $key may be undef, in wich case we ensure that the primary user key is not in
#   the file.
define ssh::windows::authorized_key (
  String[1]                  $user     = $title,
  Enum[present, absent]      $ensure   = present,
  Optional[Ssh::Key::String] $key      = undef,
  Ssh::Key::Type             $key_type = 'ssh-rsa',
) {
  include ssh::params

  $path = "${ssh::params::authorized_keys_dir}\\${user}"

  if $ensure == present {
    if $key {
      $authorized_key = ssh::fix_eol("${key_type} ${key} ${title}\n")
    } else {
      $authorized_key = ''
    }

    file { $path:
      ensure  => file,
      owner   => 'Administrators',
      group   => 'NT AUTHORITY\SYSTEM',
      content => $authorized_key,
      force   => true,
    }

    acl { $path:
      purge                      => true,
      inherit_parent_permissions => false,
      permissions                => [
        {'identity' => 'NT AUTHORITY\SYSTEM', 'rights' => ['full']},
        {'identity' => 'Administrators', 'rights' => ['full']},
        {'identity' => $user, 'rights' => ['full']},
      ],
    }
  } else {
    # ensure => absent: the user has been deleted, or for some other reason the
    # authorized_keys file should not exist at all.
    file { $path:
      ensure => absent,
      force  => true,
    }
  }
}
