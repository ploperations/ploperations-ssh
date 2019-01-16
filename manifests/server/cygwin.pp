# Cygwin OpenSSH server
class ssh::server::cygwin {
  include ssh::params
  include ssh::server

  acl { $ssh::params::sshd_config:
    purge                      => true,
    inherit_parent_permissions => false,
    permissions                => [
      {'identity' => 'Administrators', 'rights' => ['full']},
      {'identity' => 'NT AUTHORITY\SYSTEM', 'rights' => ['full']},
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
  ### FIXME node_encrypt::secret
  ### implepup 'resources { type = "Exec" and title ~ "^bash.exe " limit 1 }'
  exec { $script:
    command     => "bash.exe ${script} --yes --pwd '${password}'",
    path        => $exec_path,
    logoutput   => true,
    creates     => cygwin::windows_path('/etc/ssh_host_rsa_key'),
    require     => [Package['openssh']], # , User['cyg_server']
    notify      => Service['sshd'],
  }
}
