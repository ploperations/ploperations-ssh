# Sets up a chroot for a given group
#
# @param [String[1]] group The group used to setup a chroot environment.
#
# @param [Boolean] tcp_forwarding Whether TCP forwarding is permitted.
define ssh::chrootgroup (
  String[1] $group          = $title,
  Boolean   $tcp_forwarding = false,
) {
  include ssh::params
  include ssh::chroot

  file {
    "/var/chroot/${group}":
      ensure => directory,
      owner  => 'root',
      group  => '0',
      mode   => '0755',
      ;
    "/var/chroot/${group}/drop":
      ensure => directory,
      owner  => 'root',
      group  => $group,
      mode   => '0775',
      ;
  }

  # Match directives MUST come last -- they match up until the next Match.
  concat::fragment { "ssh::params::sshd_config chroot ${group}":
    order   => '99',
    target  => 'ssh::params::sshd_config',
    content => ssh::fix_eol(
      epp('ssh/chroot_group.epp',
        {
          group          => $group,
          tcp_forwarding => $tcp_forwarding,
          force_command  => $ssh::params::sftp_subsystem,
        }
      )
    ),
  }
}
