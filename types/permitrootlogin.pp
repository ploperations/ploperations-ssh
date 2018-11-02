# For ssh::server::permit_root_login.
type Ssh::PermitRootLogin = Variant[
  Boolean,
  Enum['without-password', 'forced-commands-only'],
]
