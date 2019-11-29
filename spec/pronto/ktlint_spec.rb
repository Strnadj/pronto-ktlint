require 'spec_helper'

module Pronto
  describe Ktlint do
    let(:ktlint) { Ktlint.new(patches) }
    let(:patches) { nil }
    let(:pronto_config) do
      instance_double Pronto::ConfigFile, to_h: config_hash
    end
    let(:config_hash) { {} }

    before do
      allow(Pronto::ConfigFile).to receive(:new) { pronto_config }
    end

    describe '#run' do
      subject { ktlint.run }

      context 'patches are nil' do
        it { should == [] }
      end

      context 'no patches' do
        let(:patches) { [] }
        it { should == [] }
      end

      context 'patches with multiple offenses' do
        include_context 'test repo'

        let(:patches) { repo.show_commit('b5969dc') }

        its(:count) { should == 7 }

        it 'returns messages' do
          expect(subject.map(&:msg))
            .to match(
              [
                'class C should be declared in a file named C.kt (cannot be auto-corrected)',
                'Parameter should be on a separate line (unless all parameters can fit a single line)',
                'Trailing space(s)',
                "Unexpected indentation (expected 4, actual 13)",
                "Unexpected indentation (expected 4, actual 13)",
                "Missing newline before \")\"",
                "Unnecessary block (\"{}\")"
              ]
            )
        end
      end
    end
  end
end
