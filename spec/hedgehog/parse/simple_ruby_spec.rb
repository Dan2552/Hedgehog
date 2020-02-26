RSpec.describe Hedgehog::Parse::Parser do
  let(:described_instance) { described_class.new(tokens, Hedgehog::Parse::SimpleRubyRootHandler) }

  describe "#parse" do
    let(:tokens) { [] }
    subject { described_instance.parse }

    describe "nothing special (e.g. git log)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :end)
      end

      it "doesn't raise" do
        expect { subject }.to_not raise_error
      end
    end

    describe "string (e.g. \"abc\")" do
      let(:tokens) do
        t(:double_quote,
          :word_starting_with_letter,
          :double_quote,
          :end)
      end

      it "doesn't raise" do
        expect { subject }.to_not raise_error
      end
    end

    describe "incomplete string (e.g. \"abc)" do
      let(:tokens) do
        t(:double_quote,
          :word_starting_with_letter,
          :end)
      end

      it "does raise" do
        expect { subject }
          .to raise_error(Hedgehog::Parse::UnexpectedToken)
      end
    end

    describe "string (e.g. 'abc')" do
      let(:tokens) do
        t(:single_quote,
          :word_starting_with_letter,
          :single_quote,
          :end)
      end

      it "doesn't raise" do
        expect { subject }.to_not raise_error
      end
    end

    describe "incomplete string (e.g. 'abc)" do
      let(:tokens) do
        t(:single_quote,
          :word_starting_with_letter,
          :end)
      end

      it "does raise" do
        expect { subject }
          .to raise_error(Hedgehog::Parse::UnexpectedToken)
      end
    end

    describe "split up by semicolons (e.g. abc;abc)"
    describe "quote with semicolons (e.g. 'abc;abc')"
  end
end
