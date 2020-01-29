RSpec.describe Hedgehog::Parse::Parser do
  let(:described_instance) { described_class.new(tokens) }

  def t(*token_types)
    token_types.map do |type|
      type_map = {
        word_starting_with_letter: "abc",
        space: " ",
        number: "123",
        word_starting_with_number: "1bc",
        equals: "=",
        single_quote: "'",
        double_quote: "\"",
        backtick: "`",
        pipe: "|",
        end: ""
      }
      Hedgehog::Parse::Token.new(type, type_map[type])
    end
  end

  fdescribe "#parse" do
    let(:tokens) { [] }
    subject { described_instance.parse }

    describe "simplest command" do
      let(:tokens) { t(:word_starting_with_letter) }

      it "returns the parsed output" do
        expect(subject.type).to eq("")
      end
    end
  end
end
