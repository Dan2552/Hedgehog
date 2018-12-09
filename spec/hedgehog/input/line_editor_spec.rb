RSpec.describe Hedgehog::Input::LineEditor do
  let(:described_instance) { described_class.new(handle_teletype: false) }

  describe "#readline" do
    let(:prompt) { "" }
    subject { described_instance.readline(prompt) }

    context "when there is a prompt" do
      let(:prompt) { "prompt >" }

      before do
        stub_characters(:enter)
      end

      it "prints the prompt" do
        expect { subject }
          .to output(/prompt >/)
          .to_stdout
      end
    end

    context "when a command is typed" do
      before do
        stub_characters(:e, :c, :h, :o, :enter)
      end

      it "returns the inputted command" do
        expect(subject).to eq("echo")
      end

      it "prints each character" do
        expect { subject }
          .to output(/echo/)
          .to_stdout
      end
    end

    context "when something is edited with arrow keys" do
      before do
        stub_characters(:e, :h, :o, :left, :left, :c, :enter)
      end

      it "returns the inputted command" do
        expect(subject).to eq("echo")
      end

      it "prints each character" do
        expect { subject }
          .to output(/echo/)
          .to_stdout
      end
    end

    context "when ctrl_d is pressed" do
      before do
        stub_characters(:ctrl_d)
      end

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when ctrl_c is pressed" do
      context "when nothing is entered beforehand" do
        before do
          stub_characters(:ctrl_c, :h, :i, :enter)
        end

        it "acts as if it were never pressed" do
          expect(subject).to eq("hi")
        end
      end

      context "when something is entered beforehand" do
        before do
          stub_characters(:h, :i, :ctrl_c)
        end

        it "raises Interrupt" do
          expect { subject }.to raise_error(Interrupt)
        end

        it "prints the cancelled command with a ^C" do
          rescued_subject = Proc.new do
            begin
              subject
            rescue Interrupt
              nil
            end
          end

          expected_output = Regexp.escape("hi\e[38;5;0m\e[48;5;15m^C\e[0m")

          expect(&rescued_subject)
            .to output(/#{expected_output}/)
            .to_stdout
        end
      end
    end

    context "when backspace is used" do
      before do
        stub_characters(:e, :c, :c, :backspace, :h, :o, :enter)
      end

      it "returns the inputted command" do
        expect(subject).to eq("echo")
      end

      it "prints each character" do
        expect { subject }
          .to output(/echo/)
          .to_stdout
      end
    end

    context "tab completion" do
      context "when completing nothingness" do
        before do
          stub_characters(:tab, :enter)
        end

        it "makes a Choice with binary proc" do
          instance = double

          expected_proc = Hedgehog::Input::Choice::PATH_BINARY_PROC

          expect(expected_proc)
            .to receive(:call)

          subject
        end
      end

      context "when not completing a path as first word" do
        before do
          stub_characters("l", :tab, :enter)
        end

        it "makes a Choice with binary proc" do
          instance = double

          expected_proc = Hedgehog::Input::Choice::PATH_BINARY_PROC

          expect(expected_proc)
            .to receive(:call)

          subject
        end
      end

      context "when completing a path with escaped spaces" do
        before do
          stub_characters(*("~/wedding\\ upload".each_char.to_a) + [:tab, :enter])
        end

        it "makes a Choice" do
          instance = double

          expect(Hedgehog::Input::Choice)
            .to receive(:new)
            .with(editor: described_instance, handle_teletype: false, completion_proc: nil)
            .and_return(instance)

          expect(instance)
            .to receive(:read_choice)
            .with("~/wedding\\ upload", 0)

          subject
        end
      end

      context "when completing a path as second word" do
        before do
          stub_characters(:c, :d, " ", "~", "/", :D, :tab, :enter)
        end

        it "makes a Choice with only the path" do
          instance = double

          expect(Hedgehog::Input::Choice)
            .to receive(:new)
            .with(editor: described_instance, handle_teletype: false, completion_proc: nil)
            .and_return(instance)

          expect(instance)
            .to receive(:read_choice)
            .with("~/D", 2)

          subject
        end
      end

      context "when completing an empty second word" do
        before do
          stub_characters(:c, :d, " ", :tab, :enter)
        end

        it "makes a choice" do
          instance = double

          expect(Hedgehog::Input::Choice)
            .to receive(:new)
            .with(editor: described_instance, handle_teletype: false, completion_proc: nil)
            .and_return(instance)

          expect(instance)
            .to receive(:read_choice)
            .with("", 2)

          subject
        end
      end
    end
  end
end
