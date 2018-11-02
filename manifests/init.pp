# Installs and manages an SSH client
#
# Requires Chocolatey or Cygwin on Windows.
class ssh {
  include ssh::params

  if $ssh::params::client_package {
    ensure_packages([$ssh::params::client_package], {
      provider => $ssh::params::package_provider,
    })
  }
}
