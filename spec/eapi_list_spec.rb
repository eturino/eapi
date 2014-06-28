require 'spec_helper'

RSpec.describe Eapi do

  context 'list' do
    class Eapi::MyTestClassValMult
      include Eapi::Common

      property :something, multiple: true
    end

    it '#add_something' do
      eapi = Eapi::MyTestClassValMult.new something: [1, 2]
      res  = eapi.add_something 3
      expect(res).to be eapi
      expect(eapi.something).to eq [1, 2, 3]
    end

    it '#init_something called on first add if element is nil' do
      eapi = Eapi::MyTestClassValMult.new
      res  = eapi.add_something :a
      expect(res).to be eapi
      expect(eapi.something.to_a).to eq [:a]
    end

    class Eapi::MyTestClassValMultImpl
      include Eapi::Common

      property :something, type: Set
    end

    class MyMultiple
      def self.is_multiple?
        true
      end

      def <<(x)
        @elements ||= []
        @elements << x
      end

      def to_a
        @elements.to_a
      end
    end

    class Eapi::MyTestClassValMultImpl2
      include Eapi::Common

      property :something, type: MyMultiple
    end

    class MyMultipleEapi
      include Eapi::Multiple

      def <<(x)
        @elements ||= []
        @elements << x
      end

      def to_a
        @elements.to_a
      end
    end

    class Eapi::MyTestClassValMultImpl3
      include Eapi::Common

      property :something, type: MyMultipleEapi
    end

    it 'if type is Array or Set, or responds true to is_multiple?, it is multiple implicitly + uses that class to initialize the property when adding' do
      [
        [Eapi::MyTestClassValMult, Array],
        [Eapi::MyTestClassValMultImpl, Set],
        [Eapi::MyTestClassValMultImpl2, MyMultiple],
        [Eapi::MyTestClassValMultImpl3, MyMultipleEapi],
      ].each do |(eapi_class, type_class)|
        eapi = eapi_class.new
        res  = eapi.add_something :a
        expect(res).to be eapi
        expect(eapi.something.to_a).to eq [:a]
        expect(eapi.something).to be_a_kind_of type_class
      end
    end

    it 'validate elements' do
      skip 'test TBD'
    end
  end

end