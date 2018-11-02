# Ensure line endings are correct for the current platform.
function ssh::fix_eol ( String $value ) >> String {
  if $ssh::params::dos_line_endings {
    unix2dos($value)
  } else {
    dos2unix($value)
  }
}
