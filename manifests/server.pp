# This class installs and manages an SSH server
class ssh::server (
  Variant[Boolean, Enum['without-password', 'forced-commands-only']] $permit_root_login = false,
  Boolean $permit_x11_forwarding = false,
  Boolean $print_motd = $ssh::params::print_motd,
  Optional[Array[String[1], 1]] $accept_env = undef,
  Optional[String[1]] $kex_algorithm = undef,
) inherits ssh::params {
  include ssh

  if $facts['kernel'] == 'Linux' {
    ensure_packages([$ssh::params::server_package], {
      ensure => latest,
    })

    Package[$ssh::params::server_package] -> Concat[$ssh::params::sshd_config]
    Package[$ssh::params::server_package] ~> Service['sshd']
  }

  $permit_root_login_string = $permit_root_login ? {
    String[1] => $permit_root_login,
    true      => 'yes',
    false     => 'no',
  }

  concat { $ssh::params::sshd_config:
    mode   => '0640',
    notify => Service['sshd'],
  }
  concat::fragment { 'sshd_config-header':
    order   => '00',
    target  => $ssh::params::sshd_config,
    content => template('ssh/sshd_config.erb'),
  }

# fix sshd_confog for Debian (but not for centos or solaris, because :(
  if $facts['os']['name'] == 'Debian' {
    concat::fragment { 'sshd_config-kexalgorithms':
      order   => '40',
      target  => $ssh::params::sshd_config,
      content => template('ssh/kexalgorithms.erb'),
    }
  }

  service { 'sshd':
    ensure     => running,
    name       => $ssh::params::ssh_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => $facts['kernel'] != 'Darwin',
  }

  file { $ssh::params::ssh_dir:
    ensure => directory,
    owner  => 'root',
    group  => '0',
    mode   => '0755',
  }

  file { $ssh::params::known_hosts:
    ensure => file,
    owner  => 'root',
    group  => '0',
    mode   => '0644',
  }
}
