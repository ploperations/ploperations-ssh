# Ensure line endings are correct for the current platform.
#
# @param [String] value The string to perform a line ending conversion on.
#
# @return [String] Returns a string with the desired line ending.
function ssh::fix_eol ( String $value ) >> String {
  if $ssh::params::dos_line_endings {
    unix2dos($value)
  } else {
    dos2unix($value)
  }
}
