# Pass through strings and convert booleans into 'yes' or 'no'
#
# @param [Variant[Boolean, String[1]]] value The boolean value to convert to a string.
#
# @return [String[1]] Returns a string content of either 'yes' or 'no'.
function ssh::yesno ( Variant[Boolean, String[1]] $value ) >> String[1] {
  case $value {
    true:    { 'yes' }
    false:   { 'no' }
    default: { $value }
  }
}
