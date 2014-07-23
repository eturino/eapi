require 'spec_helper'

RSpec.describe Eapi do

  class IgnoreDefaultSpecTestItem
    include Eapi::Item
    property :something, ignore: :blank?, default: 123
  end

  class IgnoreDefaultSpecTestItemWithoutDefault
    include Eapi::Item
    property :something, ignore: :blank?
  end


  describe 'on render: ignored values with default option' do
    describe 'Item' do
      subject { IgnoreDefaultSpecTestItem.new }

      it 'use the default if value is to be ignored' do
        subject.something ""
        expected = {something: 123}
        expect(subject.render).to eq expected
      end

      it 'the default value is not used if the actual value is not to be ignored' do
        subject.something 1
        expected = {something: 1}
        expect(subject.render).to eq expected
      end

      describe '#converted_or_default_value_for' do
        it 'returns the converted value if it is not ignored' do
          subject.something 1
          expect(subject.converted_or_default_value_for :something).to eq 1
        end

        it 'returns the default value if it is ignored' do
          subject.something ""
          expect(subject.converted_or_default_value_for :something).to eq 123
        end

        describe 'without default value' do
          subject { IgnoreDefaultSpecTestItemWithoutDefault.new }

          it 'returns nil if the converted value is ignored' do
            subject.something ""
            expect(subject.converted_or_default_value_for :something).to be_nil
          end
        end
      end

      describe '#yield_final_value_for' do
        it 'yields the converted value if it is not ignored' do
          subject.something 1
          init = :initial_value
          subject.yield_final_value_for(:something) { |v| init = v }
          expect(init).to eq 1
        end

        it 'yields the default value if it is ignored' do
          subject.something ""
          init = :initial_value
          subject.yield_final_value_for(:something) { |v| init = v }
          expect(init).to eq 123
        end

        describe 'without default value' do
          subject { IgnoreDefaultSpecTestItemWithoutDefault.new }

          it 'does not yield anything if the converted value is ignored' do
            subject.something ""
            init = :initial_value
            subject.yield_final_value_for(:something) { |v| init = v }
            expect(init).to eq :initial_value
          end
        end
      end
    end
  end
end