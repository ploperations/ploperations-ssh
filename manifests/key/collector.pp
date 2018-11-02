# Collect SSH public keys exported by ssh::key and add them to authorized_keys
#
# This is not secure. It grants remote access to a host pulled from PuppetDB,
# so if you can run custom puppet code on a host, you can cause this to
# collect the public key from the malicious host.
#
# See ssh::key::remote for a more secure option.
#
# $key_name - The name of the ssh::key resource. Defaults to $name.
# $users    - Users to add the key to. Defaults to [$name].
# $options  - Options to pass to ssh_authorized_key.
define ssh::key::collector (
  String[1] $key_name = $name,
  Array[String[1], 1] $users = [$name],
  Optional[Array[String[1], 1]] $options = undef,
) {
  $public_keys = unique(query_nodes(
    "Ssh::Key::Marker['${key_name} to ${facts['fqdn']}']",
    "ssh_public_key_${key_name}_rsa"))
  $public_keys.each |$public_key| {
    [$key_type, $key, $comment] = $public_key.split(' ')

    $users.each |$user| {
      ssh_authorized_key { "${comment} for ${user}":
        ensure  => present,
        user    => $user,
        type    => $key_type,
        key     => $key,
        options => $options,
      }
    }
  }
}
