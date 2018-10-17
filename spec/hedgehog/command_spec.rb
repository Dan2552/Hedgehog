describe Hedgehog::Command do
  let(:described_instance) { described_class.new }

  before do
    Hedgehog::Settings.shared_instance.binary_in_path_finder = Hedgehog::BinaryInPathFinder::Ruby.new
    described_instance << command
  end

  context "echo hello world" do
    let(:command) { "echo hello world" }

    describe "#binary_name" do
      subject { described_instance.binary_name }

      it { is_expected.to eq("echo") }
    end

    describe "#binary_path" do
      subject { described_instance.binary_path }

      it { is_expected.to eq("/bin/echo") }
    end

    describe "#original" do
      subject { described_instance.original }

      it { is_expected.to eq("echo hello world") }
    end

    describe "#with_binary_path" do
      subject { described_instance.with_binary_path }

      it { is_expected.to eq("/bin/echo hello world") }
    end

    describe "#arguments" do
      subject { described_instance.arguments }

      it { is_expected.to be_a(Hedgehog::Command::Arguments) }
      it { is_expected.to match_array(["hello", "world"]) }
    end

    describe "#incomplete?" do
      subject { described_instance.incomplete? }

      it { is_expected.to eq(false) }

      context "echo hello world \\" do
        let(:command) { "echo hello world \\" }

        it { is_expected.to eq(true) }
      end

      shared_examples_for "balanced" do
        it { is_expected.to eq(true) }

        context "when closing" do
          before do
            described_instance << second_command
          end

          it { is_expected.to eq(false) }
        end
      end

      context "{" do
        let(:command) { "{" }
        let(:second_command) { "}" }

        it_behaves_like("balanced")
      end

      context "[" do
        let(:command) { "[" }
        let(:second_command) { "]" }

        it_behaves_like("balanced")
      end

      context "(" do
        let(:command) { "(" }
        let(:second_command) { ")" }

        it_behaves_like("balanced")
      end

      context "`" do
        let(:command) { "`" }
        let(:second_command) { "`" }

        it_behaves_like("balanced")
      end

      context "'" do
        let(:command) { "'" }
        let(:second_command) { "'" }

        it_behaves_like("balanced")
      end

      context '"' do
        let(:command) { '"' }
        let(:second_command) { '"' }

        it_behaves_like("balanced")
      end
    end

    describe "#env_vars" do
      subject { described_instance.env_vars }

      it { is_expected.to match_array([]) }
    end
  end

  context 'echo "one one" two' do
    let(:command) { 'echo "one one" two' }

    describe "#arguments" do
      subject { described_instance.arguments }

      it { is_expected.to be_a(Hedgehog::Command::Arguments) }
      it { is_expected.to match_array(['"one one"', "two"]) }
    end
  end

  context 'cd ~/wedding\ upload\ to\ fb/' do
    let(:command) { 'cd ~/wedding\ upload\ to\ fb/' }

    describe "#binary_name" do
      subject { described_instance.binary_name }

      it { is_expected.to eq("cd") }
    end

    describe "#arguments" do
      subject { described_instance.arguments }

      it { is_expected.to be_a(Hedgehog::Command::Arguments) }
      it { is_expected.to match_array(['~/wedding\ upload\ to\ fb/']) }

      describe "to_s" do
        subject { described_instance.arguments.to_s }

        it { is_expected.to eq('~/wedding\ upload\ to\ fb/') }
      end
    end
  end

  context "TEST=test ruby -e \"puts ENV['TEST']\"" do
    let(:command) { "TEST=test ruby -e \"puts ENV['TEST']\"" }

    describe "#binary_name" do
      subject { described_instance.binary_name }

      it { is_expected.to eq("ruby") }
    end

    describe "#arguments" do
      subject { described_instance.arguments }

      it { is_expected.to be_a(Hedgehog::Command::Arguments) }
      it { is_expected.to match_array(["-e", "\"puts ENV['TEST']\""]) }

      describe "to_s" do
        subject { described_instance.arguments.to_s }

        it { is_expected.to eq("-e \"puts ENV['TEST']\"") }
      end
    end

    describe "#env_vars" do
      subject { described_instance.env_vars }

      it { is_expected.to match_array(["TEST=test"]) }
    end
  end
end
