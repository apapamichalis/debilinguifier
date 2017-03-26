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
end

