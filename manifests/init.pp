# Class: ssh
#
# This class installs and manages SSH
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class ssh {

  include ::ssh::params

  $client_package  = $::ssh::params::client_package
  $ssh_config      = $::ssh::params::ssh_config
  $sshd_config     = $::ssh::params::sshd_config
  $ssh_service     = $::ssh::params::ssh_service
  $syslog_facility = $::ssh::params::syslog_facility

  if $::kernel == 'Linux' or $::kernel == 'SunOS' {
    package { $client_package:
      ensure => latest,
    }
  }

  file { $ssh_config:
    ensure    => file,
    owner     => root,
    group     => 0,
    mode      => '0644',
    require   => $::kernel ? {
      'Darwin'  => undef,
      'freebsd' => undef,
      'openbsd' => undef,
      'solaris' => undef,
      'SunOS'   => undef,
      default   => Package[$client_package],
    }
  }

  # Disable UseRoaming - per bugs CVE-2016-0777 and CVE-2016-0778
  augeas { 'ssh_config':
    changes => [
      "set /files/${ssh_config}/Host *",
      "rm /files/${ssh_config}/Host/UseRoaming no",
    ],
    require => File[$ssh_config],
  }
}
