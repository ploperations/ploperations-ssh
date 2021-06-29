# Class: ssh::allowgroup
#
# Allows a group the ability to shell into a give node.
#
# @param [String[1]] group A list of group name patterns, separated by spaces, to only allow members of those group(s) to login.
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
