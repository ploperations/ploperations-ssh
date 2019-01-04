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

  include ssh::params

  $client_package  = $ssh::params::client_package
  $ssh_config      = $ssh::params::ssh_config
  $sshd_config     = $ssh::params::sshd_config
  $ssh_service     = $ssh::params::ssh_service
  $syslog_facility = $ssh::params::syslog_facility

  if $::kernel == 'Linux' or $::kernel == 'SunOS' {
    package { $client_package:
      ensure => latest,
    }
  }
}
