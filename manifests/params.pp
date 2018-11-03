# Class: ssh::params
#
# Sets varables for the SSH class
#
class ssh::params {
  $ssh_dir           = '/etc/ssh'
  $sshd_config       = "${ssh_dir}/sshd_config"
  $ssh_config        = "${ssh_dir}/ssh_config"
  $known_hosts       = "${ssh_dir}/ssh_known_hosts"

  case $facts['os']['name'] {
    'CentOS', 'RedHat', 'Fedora': {
      $client_package  = 'openssh-clients'
      $server_package  = 'openssh-server'
      $ssh_service     = 'sshd'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = true
    }
    'SLES': {
      $client_package  = 'openssh'
      $server_package  = 'openssh'
      $ssh_service     = 'sshd'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = true
    }
    'CumulusLinux', 'Debian', 'Ubuntu': {
      $client_package  = 'openssh-client'
      $server_package  = 'openssh-server'
      $ssh_service     = 'ssh'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = false
    }
    'Darwin': {
      $ssh_service     = 'com.openssh.sshd'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = true
    }
    'FreeBSD': {
      $ssh_service     = 'sshd'
      $syslog_facility = 'AUTHPRIV'
      $print_motd      = true
    }
    'Solaris','SunOS': {
      case $::kernelrelease {
        '5.10': {
          $client_package  = 'openssh'
          $server_package  = 'openssh'
          $ssh_service     = 'svc:/network/cswopenssh:default'
          $syslog_facility = 'AUTH'
        }
        '5.11': {
          $client_package  = 'service/network/ssh'
          $server_package  = 'service/network/ssh'
          $ssh_service     = 'network/ssh'
          $syslog_facility = 'AUTH'
        }
        default: {
          fail("module ssh does not support Solaris ${facts['kernelrelease']}")
        }
      }

      $print_motd = false
    }
    default: {
      fail("module ssh does not support operatingsystem ${::operatingsystem}")
    }
  }
}
