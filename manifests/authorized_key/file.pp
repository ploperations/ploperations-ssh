# @summary Manage the authorized_keys file
#
# This is only used on systems where ssh_authorized_key doesn't work.
#
# @param [Enum[present, absent]] ensure The ensure value for the ssh authorized key file.
#
# @param [String[1]] user The target user's authorized key file to manage and file owner permission to set.
#
# @param [String[1]] group The group permissions of the authorized key file.
#
# @param [Optional[String[3]]] mode The file mode to set for the ssh authorized key file.
define ssh::authorized_key::file (
  Enum[present, absent] $ensure = 'present',
  String[1]             $user   = $title,
  String[1]             $group  = 'NT AUTHORITY\SYSTEM',
  Optional[String[3]]   $mode   = undef,
) {
  include ssh::params

  if $mode {
    $_mode = $mode
  } else {
    $_mode = $ssh::params::config_mode
  }

  case $ssh::params::server_class {
    'ssh::server::chocolatey': {
      $path = "${ssh::params::authorized_keys_dir}\\${user}"
      $owner = 'Administrators'
    }
    'ssh::server::cygwin': {
      $path = cygwin::windows_path("/home/${user}/${ssh::params::authorized_keys}")
      $owner = $user
    }
    default: {
      fail("ssh::authorized_key::file cannot be used with ${ssh::params::server_class}")
    }
  }

  if $ensure == 'present' {
    concat { "ssh::authorized_key::file ${title}":
      path           => $path,
      mode           => $_mode,
      ensure_newline => false, # probably want CRLF instead of LF
    }

    $notice = 'This file is managed by Puppet. Modifications will be overwritten.'
    concat::fragment { "ssh::authorized_key::file ${title} header":
      order   => '00',
      target  => "ssh::authorized_key::file ${title}",
      content => ssh::fix_eol("# ${notice}.\n"),
    }

    if $ssh::params::server_class == 'ssh::server::chocolatey' {
      acl { $path:
        purge                      => true,
        inherit_parent_permissions => false,
        owner                      => $owner,
        group                      => $group,
        permissions                => unique([
            { 'identity' => $group, 'rights' => ['full'] },
            { 'identity' => $owner, 'rights' => ['full'] },
            { 'identity' => $user, 'rights' => ['full'] },
            { 'identity' => 'Everyone', 'rights' => ['read'] },
          ],
        ),
      }
    }
  } else {
    file { $path:
      ensure => 'absent',
      force  => true,
    }
  }
}
