describe Hedgehog::Command do
  let(:described_instance) { described_class.new(command) }

  before do
    settings = Hedgehog::Settings.shared_instance
    settings.binary_in_path_finder = Hedgehog::BinaryInPathFinder::Ruby.new
  end

  describe "#treat_as_shell?" do
    subject { described_instance.treat_as_shell? }
    context "where there is no command" do
      let(:command) { "" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is a command" do
      let(:command) { "echo hello" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "when there is a command with an absolute path" do
      let(:command) { "/bin/echo hello" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end
  end

  describe "#sequential?" do
    subject { described_instance.sequential? }

    context "when there is no command" do
      let(:command) { "" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is only 1 command" do
      let(:command) { "echo hello" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is an pipe" do
      let(:command) { "echo hello | grep he" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is an or" do
      let(:command) { "echo x || echo y" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is an and" do
      let(:command) { "echo x && echo y" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there are multiple commands split by semicolon" do
      let(:command) { "echo x; echo y" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "when there are multiple commands split by newline" do
      let(:command) { "echo x\necho y" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end
  end

  describe "#sequence" do
    subject { described_instance.sequence }

    context "when there are multiple commands split by newline" do
      let(:command) { "echo x\necho y" }

      it "returns the commands" do
        expect(subject).to be_an(Array)
        expect(subject).to all(be_a(Hedgehog::Command))
        expect(subject.first.original).to eq("echo x")
        expect(subject.second.original).to eq("echo y")
      end
    end
  end

  describe "#operation_parts" do
    subject { described_instance.operation_parts }

    context "when there is no command" do
      let(:command) { "" }

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when there is only 1 command" do
      let(:command) { "echo hello" }

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when there is an pipe" do
      let(:command) { "echo hello | grep he" }

      it "returns the operator details" do
        expect(subject).to eq(
          operator: :pipe,
          lhs: "echo hello",
          rhs: "grep he"
        )
      end
    end

    context "when there is an or" do
      let(:command) { "echo x || echo y" }

      it "returns the operator details" do
        expect(subject).to eq(
          operator: :or,
          lhs: "echo x",
          rhs: "echo y"
        )
      end
    end

    context "when there is an and" do
      let(:command) { "echo x && echo y" }

      it "returns the operator details" do
        expect(subject).to eq(
          operator: :and,
          lhs: "echo x",
          rhs: "echo y"
        )
      end
    end

    context "when there are multiple commands split by semicolon" do
      let(:command) { "echo x; echo y" }

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when there are multiple commands split by newline" do
      let(:command) { "echo x\necho y" }

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#binary_operation?" do
    subject { described_instance.binary_operation? }

    context "when there is no command" do
      let(:command) { "" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is only 1 command" do
      let(:command) { "echo hello" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is an pipe" do
      let(:command) { "echo hello | grep he" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is an or" do
      let(:command) { "echo x || echo y" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "when there is an and" do
      let(:command) { "echo x && echo y" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "when there are multiple commands split by semicolon" do
      let(:command) { "echo x; echo y" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there are multiple commands split by newline" do
      let(:command) { "echo x\necho y" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "#piped?" do
    subject { described_instance.piped? }

    context "when there is no command" do
      let(:command) { "" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is only 1 command" do
      let(:command) { "echo hello" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is an pipe" do
      let(:command) { "echo hello | grep he" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "when there is an or" do
      let(:command) { "echo x || echo y" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there is an and" do
      let(:command) { "echo x && echo y" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there are multiple commands split by semicolon" do
      let(:command) { "echo x; echo y" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when there are multiple commands split by newline" do
      let(:command) { "echo x\necho y" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end

  # context "echo hello world" do
  #   let(:command) { "echo hello world" }

  #   describe "#binary_name" do
  #     subject { described_instance.binary_name }

  #     it { is_expected.to eq("echo") }
  #   end

  #   describe "#incomplete?" do
  #     subject { described_instance.incomplete? }

  #     it { is_expected.to eq(false) }

  #     context "when ending in a backslash" do
  #       let(:command) { "echo hello world \\ " }

  #       it { is_expected.to eq(true) }
  #     end
  #   end

  #   describe "#env_vars" do
  #     subject { described_instance.env_vars }

  #     it { is_expected.to match_array([]) }
  #   end
  # end

  # context 'echo "one one" two' do
  #   let(:command) { 'echo "one one" two' }

  #   describe "#arguments" do
  #     subject { described_instance.arguments }

  #     it { is_expected.to be_a(Hedgehog::Command::Arguments) }
  #     it { is_expected.to match_array(['"one one"', "two"]) }
  #   end
  # end

  # context 'cd ~/wedding\ upload\ to\ fb/' do
  #   let(:command) { 'cd ~/wedding\ upload\ to\ fb/' }

  #   describe "#binary_name" do
  #     subject { described_instance.binary_name }

  #     it { is_expected.to eq("cd") }
  #   end

  #   describe "#arguments" do
  #     subject { described_instance.arguments }

  #     it { is_expected.to be_a(Hedgehog::Command::Arguments) }
  #     it { is_expected.to match_array(['~/wedding\ upload\ to\ fb/']) }

  #     describe "to_s" do
  #       subject { described_instance.arguments.to_s }

  #       it { is_expected.to eq('~/wedding\ upload\ to\ fb/') }
  #     end
  #   end
  # end

  # context "TEST=test ruby -e \"puts ENV['TEST']\"" do
  #   let(:command) { "TEST=test ruby -e \"puts ENV['TEST']\"" }

  #   describe "#binary_name" do
  #     subject { described_instance.binary_name }

  #     it { is_expected.to eq("ruby") }
  #   end

  #   describe "#arguments" do
  #     subject { described_instance.arguments }

  #     it { is_expected.to be_a(Hedgehog::Command::Arguments) }
  #     it { is_expected.to match_array(["-e", "\"puts ENV['TEST']\""]) }

  #     describe "to_s" do
  #       subject { described_instance.arguments.to_s }

  #       it { is_expected.to eq("-e \"puts ENV['TEST']\"") }
  #     end
  #   end

  #   describe "#env_vars" do
  #     subject { described_instance.env_vars }

  #     it { is_expected.to match_array(["TEST=test"]) }
  #   end
  # end
end
