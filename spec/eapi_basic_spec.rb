require 'spec_helper'

RSpec.describe Eapi do

  context 'basic behaviour' do
    class MyTestKlass
      include Eapi::Common

      property :something
    end

    describe '#something (fluent setter/getter)' do
      describe '#something as getter' do
        it 'return the value' do
          eapi = MyTestKlass.new something: :hey
          expect(eapi.something).to eq :hey
        end
      end

      describe '#something("val")' do
        it 'set the value and return self' do
          eapi = MyTestKlass.new something: :hey
          res  = eapi.something :other
          expect(eapi).to be res
          expect(eapi.something).to eq :other
        end
      end

      describe '#set_something("val")' do
        it 'set the value and return self' do
          eapi = MyTestKlass.new something: :hey
          res  = eapi.set_something :other
          expect(eapi).to be res
          expect(eapi.something).to eq :other
        end
      end
    end

    describe '#get' do
      it 'will use the getter' do
        eapi = MyTestKlass.new something: :hey
        expect(eapi.get(:something)).to eq :hey
        expect(eapi.get('something')).to eq :hey
      end

    end
    
    describe '#set' do
      it 'will use the fluent setter' do
        eapi = MyTestKlass.new
        expect(eapi.set(:something, :hey)).to equal eapi
        expect(eapi.get(:something)).to eq :hey
      end
    end

  end

end