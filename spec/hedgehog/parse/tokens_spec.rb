RSpec.describe Hedgehog::Parse::Tokens do
  let(:described_instance) { described_class.new(text) }

  describe "#tokenize" do
    let(:text) { "" }
    subject { described_instance.tokenize }

    describe "a simple command" do
      let(:text) { "ls" }

      it "returns the tokens" do
        expect(subject.count).to eq(2)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("ls")
        expect(subject[1].type).to eq(:end)
        expect(subject[1].text).to eq("")
      end
    end

    describe "surrounding whitespace" do
      let(:text) { "  \n  ls  \n " }

      it "doesn't count towards extra tokens" do
        expect(subject.count).to eq(2)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("ls")
      end
    end

    describe "a command with a single argument" do
      let(:text) { "echo hello" }

      it "returns the tokens" do
        expect(subject.count).to eq(4)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("echo")

        expect(subject[1].type).to eq(:space)
        expect(subject[1].text).to eq(" ")

        expect(subject[2].type).to eq(:word_starting_with_letter)
        expect(subject[2].text).to eq("hello")
      end
    end

    describe "a command with multiple arguments" do
      let(:text) { "echo hello world" }

      it "returns the tokens" do
        expect(subject.count).to eq(6)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("echo")

        expect(subject[1].type).to eq(:space)
        expect(subject[1].text).to eq(" ")

        expect(subject[2].type).to eq(:word_starting_with_letter)
        expect(subject[2].text).to eq("hello")

        expect(subject[3].type).to eq(:space)
        expect(subject[3].text).to eq(" ")

        expect(subject[4].type).to eq(:word_starting_with_letter)
        expect(subject[4].text).to eq("world")
      end
    end

    describe "numbers" do
      let(:text) { "123" }

      it "returns the tokens" do
        expect(subject.count).to eq(2)
        expect(subject[0].type).to eq(:number)
        expect(subject[0].text).to eq("123")
      end
    end

    describe "word starting with letter with numbers" do
      let(:text) { "abc123" }

      it "returns the tokens" do
        expect(subject.count).to eq(2)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("abc123")
      end
    end

    describe "word starting with a number" do
      let(:text) { "123abc" }

      it "returns the tokens" do
        expect(subject.count).to eq(2)
        expect(subject[0].type).to eq(:word_starting_with_number)
        expect(subject[0].text).to eq("123abc")
      end
    end

    describe "word starting with a number "

    describe "equals (like env vars) with numbers as value" do
      let(:text) { "abc=123" }

      it "returns the tokens" do
        expect(subject.count).to eq(4)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("abc")

        expect(subject[1].type).to eq(:equals)
        expect(subject[1].text).to eq("=")

        expect(subject[2].type).to eq(:number)
        expect(subject[2].text).to eq("123")
      end
    end

    describe "equals (like env vars) with word starting with number as value" do
      let(:text) { "abc=123a" }

      it "returns the tokens" do
        expect(subject.count).to eq(4)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("abc")

        expect(subject[1].type).to eq(:equals)
        expect(subject[1].text).to eq("=")

        expect(subject[2].type).to eq(:word_starting_with_number)
        expect(subject[2].text).to eq("123a")
      end
    end

    describe "equals (like env vars) with word starting with letter as value" do
      let(:text) { "abc=a123" }

      it "returns the tokens" do
        expect(subject.count).to eq(4)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("abc")

        expect(subject[1].type).to eq(:equals)
        expect(subject[1].text).to eq("=")

        expect(subject[2].type).to eq(:word_starting_with_letter)
        expect(subject[2].text).to eq("a123")
      end
    end

    describe "equals with spaces" do
      let(:text) { "abc = 123" }

      it "returns the tokens" do
        expect(subject.count).to eq(6)
        expect(subject[0].type).to eq(:word_starting_with_letter)
        expect(subject[0].text).to eq("abc")

        expect(subject[1].type).to eq(:space)
        expect(subject[1].text).to eq(" ")

        expect(subject[2].type).to eq(:equals)
        expect(subject[2].text).to eq("=")

        expect(subject[3].type).to eq(:space)
        expect(subject[3].text).to eq(" ")

        expect(subject[4].type).to eq(:number)
        expect(subject[4].text).to eq("123")
      end
    end

    describe "single quote" do
      let(:text) { "'hello'" }

      it "returns the tokens" do
        expect(subject.count).to eq(4)

        expect(subject[0].type).to eq(:single_quote)
        expect(subject[0].text).to eq("'")

        expect(subject[1].type).to eq(:word_starting_with_letter)
        expect(subject[1].text).to eq("hello")


        expect(subject[2].type).to eq(:single_quote)
        expect(subject[2].text).to eq("'")
      end
    end

    describe "double quote" do
      let(:text) { "\"hello\"" }

      it "returns the tokens" do
        expect(subject.count).to eq(4)

        expect(subject[0].type).to eq(:double_quote)
        expect(subject[0].text).to eq("\"")

        expect(subject[1].type).to eq(:word_starting_with_letter)
        expect(subject[1].text).to eq("hello")


        expect(subject[2].type).to eq(:double_quote)
        expect(subject[2].text).to eq("\"")
      end
    end

    describe "backtick" do
      let(:text) { "`hello`" }

      it "returns the tokens" do
        expect(subject.count).to eq(4)

        expect(subject[0].type).to eq(:backtick)
        expect(subject[0].text).to eq("`")

        expect(subject[1].type).to eq(:word_starting_with_letter)
        expect(subject[1].text).to eq("hello")


        expect(subject[2].type).to eq(:backtick)
        expect(subject[2].text).to eq("`")
      end
    end

    describe "pipe" do
      let(:text) { "|" }

      it "returns the tokens" do
        expect(subject.count).to eq(2)

        expect(subject[0].type).to eq(:pipe)
        expect(subject[0].text).to eq("|")
      end
    end
  end
end
