# Installs SSH server on Windows
#
# Requires chocolatey or cygwin, acl, and registry.
class ssh::server::windows (
  Optional[Sensitive[String[1]]] $cyg_server_password = undef,
) {
  include ssh::server
  include ssh::params

  if $facts['cygwin_home'] =~ String[1] {
    class { 'ssh::server::windows::cygwin':
      cyg_server_password => $cyg_server_password,
    }
  } else {
    include ssh::server::windows::chocolatey
  }

  file { $ssh::params::authorized_keys_dir:
    ensure => directory,
    owner  => 'Administrators',
    group  => 'NT AUTHORITY\SYSTEM',
  }

  acl { $ssh::params::authorized_keys_dir:
    purge                      => true,
    inherit_parent_permissions => false,
    permissions                => [
      {'identity' => 'NT AUTHORITY\SYSTEM', 'rights' => ['full']},
      {'identity' => 'Administrators', 'rights' => ['full']},
    ],
  }
}
