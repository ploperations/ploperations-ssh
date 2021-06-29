# Class: ssh::params
#
# Sets varables for the SSH class that are not available via module data
#
# @param [Boolean] cygwin Whether to use cygwin as the OpenSSH provider.
class ssh::params (
  Boolean $cygwin = lookup('cygwin::enable', Boolean, undef, false),
) {
  if $facts['os']['name'] == 'windows' {
    # This fact doesn't exist during testing, and occasionally it doesn't have
    # PROGRAMDATA (WTF).
    $_windows_env = pick($facts['windows_env'], {})
    $_programdata = pick($_windows_env['PROGRAMDATA'], 'C:\ProgramData')
    $_windir = pick($_windows_env['WINDIR'], 'C:\Windows')

    if $cygwin {
      # Use Cygwin openssh
      $server_class      = 'ssh::server::cygwin'
      $package_provider  = 'cygwin'
      $config_dir        = cygwin::windows_path('/etc')
      $manage_config_dir = false
      $sftp_subsystem    = '/usr/bin/sftp-server'
      $authorized_keys   = '.ssh/authorized_keys'
      $strict_modes      = false # I couldn't figure these out
      $dos_line_endings  = false
    } else {
      # Use native openssh
      $server_class        = 'ssh::server::chocolatey'
      $package_provider    = 'chocolatey'
      $config_dir          = "${_programdata}\\ssh"
      $manage_config_dir   = true
      $sftp_subsystem      = 'sftp-server.exe'
      $authorized_keys     = "${config_dir}\\user_authorized_keys\\%u"
      $strict_modes        = true
      $dos_line_endings    = true

      # Settings special to this platform
      $default_shell       = "${_windir}\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
      $authorized_keys_dir = "${config_dir}\\user_authorized_keys"
    }
  }
}
