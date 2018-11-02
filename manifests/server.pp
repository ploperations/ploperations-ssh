# This class installs and manages an SSH server
#
# $cyg_server_password is only required on Cygwin. It's the password for the
# ssh daemon user.
class ssh::server (
  Boolean                        $print_motd            = $ssh::params::print_motd,
  Boolean                        $permit_x11_forwarding = false,
  Array[String[1]]               $accept_env            = [],
  Optional[String[1]]            $kex_algorithm         = undef,
  Ssh::PermitRootLogin           $permit_root_login     = $ssh::params::permit_root_login,
  Optional[Sensitive[String[1]]] $cyg_server_password   = undef,
) inherits ssh::params {
  include ssh

  if $facts['kernel'] == 'windows' {
    class { 'ssh::server::windows':
      cyg_server_password => $cyg_server_password,
    }
  }

  if $ssh::params::server_package {
    ensure_packages([$ssh::params::server_package], {
      provider => $ssh::params::package_provider,
    })

    Package[$ssh::params::server_package] ~> Service['sshd']

    if $ssh::params::manage_config_dir {
      Package[$ssh::params::server_package] -> File[$ssh::params::config_dir]
    }
  }

  if $ssh::params::manage_config_dir {
    file { $ssh::params::config_dir:
      ensure => directory,
      owner  => $ssh::params::config_owner,
      group  => $ssh::params::config_group,
      mode   => '0755',
      before => Concat['ssh::params::sshd_config'],
    }
  }

  file { $ssh::params::known_hosts:
    ensure => file,
    owner  => $ssh::params::config_owner,
    group  => $ssh::params::config_group,
    mode   => '0644',
    notify => Service['sshd'],
  }

  concat { 'ssh::params::sshd_config':
    path           => $ssh::params::sshd_config,
    owner          => $ssh::params::config_owner,
    group          => $ssh::params::config_group,
    mode           => '0640',
    ensure_newline => false, # might want CRLF instead of LF
    notify         => Service['sshd'],
  }

  $sshd_configuration = ssh::fix_eol(epp('ssh/sshd_config.epp', {
    accept_env            => $accept_env,
    authorized_keys       => $ssh::params::authorized_keys,
    kex_algorithm         => $kex_algorithm,
    permit_root_login     => $permit_root_login,
    permit_x11_forwarding => $permit_x11_forwarding,
    print_motd            => $print_motd,
    root_group            => $ssh::params::root_access_group,
    sftp_subsystem        => $ssh::params::sftp_subsystem,
    strict_modes          => $strict_modes,
    syslog_facility       => $ssh::params::syslog_facility,
  }))

  # Add a trailing newline for legibility.
  concat::fragment { 'ssh::params::sshd_config header':
    order   => '00',
    target  => 'ssh::params::sshd_config',
    content => ssh::fix_eol("${sshd_configuration}\n"),
  }

  $os_config = $facts['kernel'] ? {
    'Linux' => file('ssh/sshd_linux'),
    'SunOS' => file('ssh/sshd_solaris'),
    default => undef,
  }

  if $os_config {
    # Add a trailing newline for legibility.
    concat::fragment { 'ssh::params::sshd_config os_config':
      order   => '20',
      target  => 'ssh::params::sshd_config',
      content => ssh::fix_eol("${os_config}\n"),
    }
  }

  service { 'sshd':
    ensure     => running,
    name       => $ssh::params::ssh_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => $ssh::params::has_restart,
  }
}
