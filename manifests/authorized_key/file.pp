define ssh::authorized_key::file (
  Enum[present, absent, if_not_empty] $ensure = 'if_not_empty',
  String[1]                           $user   = $title,
  String[1]                           $group  = 'NT AUTHORITY\SYSTEM',
  Array[String[1]]                    $lines  = [],
) {
  include ssh::params

  case $ssh::params::server_class {
    'ssh::server::chocolatey': {
      $path = "${ssh::params::authorized_keys_dir}\\${user}"
      $owner = 'Administrators'

      acl { $path:
        purge                      => true,
        inherit_parent_permissions => false,
        permissions                => [
          {'identity' => $group, 'rights' => ['full']},
          {'identity' => $owner, 'rights' => ['full']},
          {'identity' => $user,  'rights' => ['full']},
        ],
      }
    }
    'ssh::server::cygwin': {
      $path = cygwin::windows_path("/home/${user}/${ssh::params::authorized_keys}")
      $owner = $user
    }
    default: {
      fail("ssh::authorized_key::file cannot be used with ${ssh::params::server_class}")
    }
  }

  if $ensure == 'present' or ($ensure == 'if_not_empty' and $lines.length() < 1) {
    $content = @("END")
      # This file is managed by Puppet. Modifications will be overwritten.
      ${lines.sort().join("\n")}
      | END

    file { $path:
      ensure  => 'file',
      owner   => $owner,
      group   => $group,
      content => ssh::fix_eol($content),
      force   => true,
    }
  } else {
    file { $path:
      ensure => 'absent',
      force  => true,
    }
  }
}
