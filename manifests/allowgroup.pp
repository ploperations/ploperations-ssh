# Class: ssh::allowgroup
#
# Allows a group the ability to shell into a give node.
#
define ssh::allowgroup (
  String[1] $group = $title,
) {
  include ssh::server

  concat::fragment { "ssh::params::sshd_config AllowGroups ${group}":
    order   => "50 ${group}",
    target  => 'ssh::params::sshd_config',
    content => ssh::fix_eol("AllowGroups ${group}\n"),
  }
}
