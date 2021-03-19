# This is needed to test puppetlabs/acl on OSs other than Windows. If it's not
# present, then `pdk test unit` gives errors like:
#
# undefined method `symlink?' for Puppet::Util::Windows::File:Module
RSpec.configure do |c|
  c.mock_with :rspec
end
