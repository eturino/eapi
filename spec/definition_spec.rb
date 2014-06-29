require 'spec_helper'

RSpec.describe Eapi do

  context '#definition_for' do
    class MyTestKlassDefinition
      include Eapi::Common

      property :something, type: Hash, unrecognised_option: 1
    end

    it 'will return the definition of a property, even with the unrecognised options (a copy of the hash, not editable)' do
      definition = MyTestKlassDefinition.definition_for :something
      expected   = {type: Hash, unrecognised_option: 1}
      expect(definition).to eq expected

      #changing the definition
      definition[:type] = Array

      definition_2 = MyTestKlassDefinition.definition_for :something
      expect(definition_2).to eq expected
      expect(definition_2[:type]).to eq Hash
    end
  end

end