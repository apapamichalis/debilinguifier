require 'spec_helper'
require 'debilinguifier'
require 'yaml'

describe DeBiLinguifier do 
  
  context 'When trying to de-bi-linguify a word' do 
    let(:examples) { YAML.load_file('spec/fixtures/examples.yml') }
    
    it 'should return the expected result' do 
      examples.each_pair do |input, output|
        expect(DeBiLinguifier.dbl(input.upcase)).to eq(output.upcase)
      end
    end
  end

  context 'When using the bias' do 
    it 'should work with greek' do 
      expect(DeBiLinguifier.dbl('fψaι'.upcase, 'greek')).to eq('fψαι'.upcase)
    end

    it 'should work with latin' do 
      expect(DeBiLinguifier.dbl('fψaι'.upcase, 'latin')).to eq('fψai'.upcase)
    end

    it 'should work with nil' do 
      expect(DeBiLinguifier.dbl('fψaι'.upcase, nil)).to eq('fψaι'.upcase)
    end

    it 'should work with anything other than ["greek", "latin"] like it was nil' do 
      expect(DeBiLinguifier.dbl('fψaι'.upcase, 'asdf')).to eq('fψaι'.upcase)
    end
  end

end

