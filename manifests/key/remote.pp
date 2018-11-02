# Collect an SSH public key exported by ssh::key and add it to authorized_keys
#
# This is secure. You must specify the accessing node explicitly by certname,
# so a malicious host cannot spoof its way to access.
#
# $title    - $user@$certname
# $user     - The user to add the key to. Defaults to the first part of $title.
# $certname - The certname of the remote host. Defaults to second part of $title.
# $key_name - The name of the ssh::key resource. Defaults to $user.
# $options  - Options to pass to ssh_authorized_key.
define ssh::key::remote (
  String[1] $user = $title.split('@')[0],
  Pattern[/\A[a-z0-9_.-]+\Z/] $certname = $title.split('@')[1],
  String[1] $key_name = $user,
  Optional[Array[String[1], 1]] $options = undef,
) {
  $nodes = query_nodes("certname='${certname}'", "ssh_public_key_${key_name}_rsa")
  if $nodes.size() > 1 {
    fail("Found more than one ssh_public_key_${key_name}_rsa for certname='${certname}'")
  }

  $nodes.each |$node| {
    [$key_type, $key, $comment] = $node.split(' ')
    ssh_authorized_key { "${title} for ${user}":
      ensure  => present,
      user    => $user,
      type    => $key_type,
      key     => $key,
      options => $options,
    }
  }
}
