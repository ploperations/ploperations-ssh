# Configuration for native OpenSSH
class ssh::server::windows::chocolatey (
  Enum[present, absent] $default_shell_ensure         = present,
  Stdlib::Absolutepath  $default_shell                = $ssh::params::default_shell,
  String                $default_shell_command_option = '/c',
) inherits ssh::params {
  # The client package is the same as the server package. The server package
  # just needs an extra parameter.
  #
  # Unfortunately, it will not reinstall if the package options change.
  Package <| title == $ssh::params::server_package |> {
    install_options => ['-params', '/SSHServerFeature'],
  }

  registry_key { 'HKLM:\SOFTWARE\OpenSSH': }

  registry_value {
    default:
      ensure  => $default_shell_ensure,
      require => Package[$ssh::params::server_package],
    ;
    'HKLM:\SOFTWARE\OpenSSH\DefaultShell':
      data => $default_shell,
    ;
    'HKLM:\SOFTWARE\OpenSSH\DefaultShellCommandOption':
      data => $default_shell_command_option,
    ;
  }
}
