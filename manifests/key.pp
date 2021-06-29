# Generate an ssh key pair and publish the public key as a fact
#
# The fact will be named "ssh_public_key_${name}_rsa".
#
# If you specify $target_query, you will be able to add the corresponding
# public key on hosts matching $target_query with ::ssh::key::collector.
#
# @param [String[1]] user The account to generate an ssh key pair for.
#
# @param [Pattern[/^\//]] key_path The location of the ssh private key.
#
# @param [Optional[String[1]]] target_query The query used to gather targets used for ssh::key::marker and known_hosts, if applicable.
#
# @param [Boolean] manage_known_hosts Whether to manage the known_hosts file.
define ssh::key (
  String[1] $user = $name,
  Pattern[/^\//] $key_path = "/home/${user}/.ssh/id_rsa",
  Optional[String[1]] $target_query = undef,
  # If true, add entries to known_hosts for hosts matching $target_query
  Boolean $manage_known_hosts = true,
) {
  $fact_name = "ssh_public_key_${name}_rsa"

  $escaped_fact_name = shellquote($fact_name)
  $escaped_fact_path = shellquote("/opt/puppetlabs/facter/facts.d/${fact_name}.txt")

  if $user == $name {
    $escaped_comment = shellquote("${user}@${facts['networking']['fqdn']}")
  } else {
    $escaped_comment = shellquote("${name}: ${user}@${facts['networking']['fqdn']}")
  }

  exec { "ssh-keygen -t rsa -b 4096 -N '' -f ${key_path} -C ${escaped_comment}":
    path    => '/usr/local/bin:/usr/bin:/bin',
    user    => $user,
    creates => $key_path,
  }

  ~> exec { "echo ${escaped_fact_name}=\$(cat ${key_path}.pub) >${escaped_fact_path}":
    path    => '/usr/local/bin:/usr/bin:/bin',
    creates => "/opt/puppetlabs/facter/facts.d/${fact_name}.txt",
  }

  # Add known_hosts entries and markers for querying for hosts matching $target_query
  if $target_query {
    $web_hosts = query_facts($target_query, ['fqdn', 'primary_ip', 'ssh'])
    $web_hosts.each |$_, $info| {
      # This is the resource that ssh::key::collector queries for
      ssh::key::marker { "${name} to ${info['fqdn']}": }

      if $manage_known_hosts {
        $rsa = $info['ssh']['rsa']
        if $rsa {
          sshkey { $info['fqdn']:
            key          => $rsa['key'],
            host_aliases => [$info['primary_ip']],
            type         => 'ssh-rsa',
          }
        }
      }
    }
  }
}
