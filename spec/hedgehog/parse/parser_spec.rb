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

    describe "no end" do
      let(:tokens) { t(:word_starting_with_letter) }

      it "raises an exception" do
        expect { subject }
          .to raise_error("Expected :end at the end of the token list")
      end
    end

    describe "one argument (e.g. ls)" do
      let(:tokens) { t(:word_starting_with_letter, :end) }

      it "returns the parsed output" do
        subject

        expect(subject.type).to eq(:root)
        expect(subject.children.count).to eq(1)
        expect(subject.children[0].type).to eq(:command)

        expect(subject.structure).to eq({
          root: { command: :argument }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc")
      end
    end

    describe "simple multiple arguments (e.g. git log)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: { command: [:argument, :argument] }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc abc")
      end
    end

    describe "quoted arguments (e.g. hello \"hello world\" 'world hello')" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :space,
          :double_quote,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :double_quote,
          :space,
          :single_quote,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :single_quote,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: { command: [
            :argument,
            { argument: { string: [:string_part, :string_part, :string_part]}},
            { argument: { string: [:string_part, :string_part, :string_part]}}
          ] }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc \"abc abc\" 'abc abc'")
      end
    end

    describe "simple environment variable (e.g. a=hello)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: { command: { env_var: [ :lhs, :rhs ] } }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc=abc")
      end
    end

    describe "simple environment variable with a number (e.g. a=1hello)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :word_starting_with_number,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: { command: { env_var: [ :lhs, :rhs ] } }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc=1bc")
      end
    end

    describe "multiple environment variables (e.g. a=hello b=world)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :equals,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            command: [
              { env_var: [ :lhs, :rhs ] },
              { env_var: [ :lhs, :rhs ] }
            ]
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc=abc abc=abc")
      end
    end

    describe "empty env var with argument (e.g. a= hello)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            command: [
              { env_var: [ :lhs, :rhs ] },
              :argument
            ]
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc= abc")
      end
    end

    describe "command starting with number (e.g. 1hello)" do
      let(:tokens) do
        t(:word_starting_with_number,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: { command: :argument }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("1bc")
      end
    end

    describe "command of a string (e.g. 'abc')" do
      let(:tokens) do
        t(:single_quote,
          :word_starting_with_letter,
          :single_quote,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: { command: { argument: { string: :string_part } } }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("'abc'")
      end
    end

    describe 'command of a string (e.g. "abc")' do
      let(:tokens) do
        t(:double_quote,
          :word_starting_with_letter,
          :double_quote,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: { command: { argument: { string: :string_part } } }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("\"abc\"")
      end
    end

    describe "unclosed string (')" do
      let(:tokens) do
        t(:single_quote,
          :end)
      end

      xit "returns the parsed output"
    end

    describe "unclosed string (echo 'hello)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :space,
          :single_quote,
          :word_starting_with_letter,
          :end)
      end

      xit "returns the parsed output"
    end

    describe "command starting with number with an equals (e.g. 1hello=)" do
      let(:tokens) do
        t(:word_starting_with_number,
          :equals,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: { command: { argument: [:argument_part, :argument_part] } }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("1bc=")
      end
    end

    describe 'env var with value in double quotes (e.g. a="hello")' do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :double_quote,
          :word_starting_with_letter,
          :double_quote,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            command: {
              env_var: [ :lhs, { rhs: [:rhs_part, :rhs_part, :rhs_part] } ]
            }
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc=\"abc\"")
      end
    end

    describe "env var with value in single quotes (e.g. a='hello')" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :single_quote,
          :word_starting_with_letter,
          :single_quote,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            command: {
              env_var: [ :lhs, { rhs: [:rhs_part, :rhs_part, :rhs_part] } ]
            }
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc='abc'")
      end
    end

    describe "complex environment variable (e.g. a=$(echo hello))" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :dollar,
          :left_bracket,
          :word_starting_with_letter,
          :word_starting_with_letter,
          :right_bracket,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            command: {
              env_var: [ :lhs, { rhs: [:rhs_part, :rhs_part, :rhs_part, :rhs_part, :rhs_part] } ]
            }
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc=$(abc abc))")
      end
    end

    describe 'complex environment variable (e.g. a=123"hello"456)' do
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :word_starting_with_number,
          :double_quote,
          :word_starting_with_letter,
          :double_quote,
          :word_starting_with_number,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            command: {
              env_var: [ :lhs, { rhs: [:rhs_part, :rhs_part, :rhs_part, :rhs_part, :rhs_part] } ]
            }
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc=1bc\"abc\"1bc")
      end
    end

    describe "A command that looks like an env var but isn't (e.g. a=one $a=two)" do
      # for reference, bash outputs:
      # bash: one=two: command not found
      let(:tokens) do
        t(:word_starting_with_letter,
          :equals,
          :word_starting_with_letter,
          :space,
          :dollar,
          :word_starting_with_letter,
          :equals,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            command: [
              { env_var: [:lhs, :rhs] },
              { argument: [:argument_part, :argument_part, :argument_part, :argument_part] }
            ]
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc=abc $abc=abc")
      end
    end

    describe 'Multiple commands split by newline (e.g. echo hello\necho world)' do
      let(:tokens) do
        t(:word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :newline,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: [
            { command: [ :argument, :argument ] },
            { command: [ :argument, :argument ] }
          ]
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc abc\nabc abc") # maybe should just be ; ?
      end
    end

    describe 'String arguement with escaped quote (e.g. echo "\"")' do
      xit "returns the parsed output"
    end

    describe 'An argument with a newline (e.g. echo "hello\nworld")' do
      let(:tokens) do
        t(:word_starting_with_letter,
          :space,
          :double_quote,
          :word_starting_with_letter,
          :newline,
          :word_starting_with_letter,
          :double_quote,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            command: [
              :argument,
              argument: { string: [:string_part, :string_part, :string_part] }
            ]
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc \"abc\nabc\"")
      end
    end

    describe "Pipe (e.g. echo hello | grep hello)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :space,
          :pipe,
          :space,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: {
            pipe: [
              { lhs: { command: [:argument, :argument] } },
              { rhs: { command: [:argument, :argument] } }
            ]
          }
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc abc | abc abc")
      end
    end

    describe "multiple commands, some with pipes (e.g. echo hello\necho hello | grep hello\necho hello\necho hello | grep hello)" do
      let(:tokens) do
        t(:word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :newline,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :space,
          :pipe,
          :space,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :newline,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :newline,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :space,
          :pipe,
          :space,
          :word_starting_with_letter,
          :space,
          :word_starting_with_letter,
          :end)
      end

      it "returns the parsed output" do
        expect(subject.structure).to eq({
          root: [
            { command: [:argument, :argument] },
            {
              pipe: [
                { lhs: { command: [:argument, :argument] } },
                { rhs: { command: [:argument, :argument] } }
              ]
            },
            { command: [:argument, :argument] },
            {
              pipe: [
                { lhs: { command: [:argument, :argument] } },
                { rhs: { command: [:argument, :argument] } }
              ]
            }
          ]
        })
      end

      it "can be converted back into a string" do
        expect(subject.to_s).to eq("abc abc\nabc abc | abc abc\nabc abc\nabc abc | abc abc")
      end
    end
  end
end
