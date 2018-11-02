# Pass through strings and convert booleans into 'yes' or 'no'
function ssh::yesno ( Variant[Boolean, String[1]] $value ) >> String[1] {
  case $value {
    true:    { 'yes' }
    false:   { 'no' }
    default: { $value }
  }
}
