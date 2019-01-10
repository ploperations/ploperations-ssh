# Cygwin OpenSSH server
class ssh::server::cygwin {
  include ssh::params
  include ssh::server

#   user { 'cyg_server':
#     groups   => ['Administrators'],
#     comment  => 'Privilege separation for Cygwin sshd',
#     password => $ssh::server::cyg_server_password,
#   }

  acl { $ssh::params::sshd_config:
    purge                      => true,
    inherit_parent_permissions => false,
    permissions                => [
      {'identity' => 'NT AUTHORITY\SYSTEM', 'rights' => ['full']},
      {'identity' => 'Administrators', 'rights' => ['full']},
      {'identity' => 'Everyone', 'rights' => ['read']},
    ],
  }

  $windir = $facts.dig('windows_env', 'WINDIR')
  $exec_path = [
    "${windir}\\System32",
    $windir,
    "${windir}\\System32\\Wbem",
    cygwin::windows_path('/bin'),
    "${facts['choco_install_path']}\\bin",
  ]

  $password = $ssh::server::cyg_server_password.unwrap()
  $script = cygwin::windows_path('/bin/ssh-host-config')
  exec { "bash.exe ${script} --yes --pwd '${password}'":
    path        => $exec_path,
    logoutput   => true,
    creates     => cygwin::windows_path('/etc/ssh_host_rsa_key'),
    require     => [Package['openssh']], # , User['cyg_server']
    notify      => Service['sshd'],
  }
}
