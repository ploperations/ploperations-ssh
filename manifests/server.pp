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
  Optional[String[3]]            $config_mode           = $ssh::params::config_mode,
) inherits ssh::params {
  include ssh

  notify { "ssh::params::config_mode = ${ssh::params::config_mode}":
    loglevel => warning,
  }
  notify { "ssh::server::config_mode = ${config_mode}":
    loglevel => warning,
  }
  if $ssh::params::server_class {
    include $ssh::params::server_class
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
      mode   => $ssh::params::config_dir_mode,
      before => Concat['ssh::params::sshd_config'],
    }
  }

  # Use $ssh::params::config_mode instead of $config_mode. This must be world
  # readable, and $config_mode might not be.
  file { $ssh::params::known_hosts:
    ensure => file,
    owner  => $ssh::params::config_owner,
    group  => $ssh::params::config_group,
    mode   => $ssh::params::config_mode,
    notify => Service['sshd'],
  }

  concat { 'ssh::params::sshd_config':
    path           => $ssh::params::sshd_config,
    owner          => $ssh::params::config_owner,
    group          => $ssh::params::config_group,
    mode           => $config_mode,
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

  service { 'sshd':
    ensure     => running,
    name       => $ssh::params::ssh_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => $ssh::params::has_restart,
  }
}
