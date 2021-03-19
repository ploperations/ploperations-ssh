require 'spec_helper'

describe 'ssh::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:puppet_util_windows_security) do
        class_double('Puppet::Util::Windows::Security').as_stubbed_const(transfer_nested_constants: true)
      end
      let(:puppet_util_windows_file) do
        class_double('Puppet::Util::Windows::File').as_stubbed_const(transfer_nested_constants: true)
      end
      let(:puppet_util_windows_sid) do
        class_double('Puppet::Util::Windows::SID').as_stubbed_const(transfer_nested_constants: true)
      end
      let(:pre_condition) do
        allow(puppet_util_windows_security).to receive(:valid_sid?).and_return(true)
        allow(puppet_util_windows_file).to receive(:symlink?).and_return(false)
        allow(puppet_util_windows_sid).to receive(:respond_to?).with(:valid_sid?).and_return(true)
        allow(puppet_util_windows_sid).to receive(:respond_to?).with(:sid_to_name).and_return(true)
        allow(puppet_util_windows_sid).to receive(:sid_to_name)
        allow(puppet_util_windows_sid).to receive(:valid_sid?).and_return(true)
      end

      it { is_expected.to compile }
    end
  end
end
