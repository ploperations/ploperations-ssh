# Solaris specific server configuration
class ssh::server::solaris {
  $os_config = file('ssh/sshd_solaris')

  # Add a trailing newline for legibility.
  concat::fragment { 'ssh::params::sshd_config os_config':
    order   => '20',
    target  => 'ssh::params::sshd_config',
    content => ssh::fix_eol("${os_config}\n"),
  }
}
