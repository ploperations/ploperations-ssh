# Marks a host in PuppetDB that produces the ssh_public_key_${name}_rsa fact.
#
# Nodes are marked by using the ssh::key defined type. They are queried for
# this marker in the ssh::key::collector defined type.
define ssh::key::marker {
}
