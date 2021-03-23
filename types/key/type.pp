# I believe there are more key types than this, but I don't know what they are.
type Ssh::Key::Type = Enum[
  'ssh-dsa',
  'ssh-dss',
  'rsa',
  'ssh-rsa',
  'ssh-ecdsa',
  'ssh-ed25519',
  'ecdsa-sha2-nistp256',
  'ecdsa-sha2-nistp384',
  'ecdsa-sha2-nistp521',
]
