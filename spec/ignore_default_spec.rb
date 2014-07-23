require 'spec_helper'

RSpec.describe Eapi do

  class IgnoreDefaultSpecTestItem
    include Eapi::Item
    property :something, ignore: :blank?, default: 123
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
    end
  end
end