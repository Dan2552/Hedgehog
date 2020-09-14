describe Hedgehog::Execution::Ruby::Binding do
  let(:described_instance) { described_class.shared_instance }

  describe ".shared_instance" do
    subject { -> { described_class.shared_instance } }

    it "always returns the same instance" do
      expect(subject.call).to equal(subject.call)
      expect(subject.call).to be_a(described_class)
    end
  end

  describe "#_run" do
    let(:str) { "self.inspect" }
    subject { -> { described_instance._run(str) } }

    it "executes the given string in binding" do
      expect_any_instance_of(Binding)
        .to receive(:eval)
        .with(str)

      subject.call
    end

    it "shares the same binding each time" do
      expect(subject.call).to eq(subject.call)
    end
  end
end

describe Hedgehog::Execution::Ruby do
  let(:described_instance) { described_class.new }
  it_behaves_like "execution"

  describe "#validate" do
    subject { described_instance.validate(command) }
    let(:command) { double }

    it { is_expected.to eq(true) }
  end

  describe "run" do
    subject { described_instance.run(command) }
    let(:command) { double(original: "'hi'") }

    it "runs the command in the binding" do
      expect(Hedgehog::Execution::Ruby::Binding.shared_instance)
        .to receive(:_run)
        .with(command.original)

      subject
    end

    it "prints the output" do
      output = "=> \e[31m\e[1;31m\"\e[0m\e[31mhi\e[1;31m\"\e[0m\e[31m\e[0m"

      expect(Hedgehog::StringExtensions.without_color(output)).to eq("=> \"hi\"")

      expect(STDOUT)
        .to receive(:puts)
        .with(output)

      subject
    end

    context "when the command raises an exception" do
      let(:command) { double(original: "raise 'hi'") }

      it "prints the exception" do
        expect(STDOUT)
          .to receive(:puts)
          .with(instance_of(RuntimeError))

        subject
      end
    end
  end
end
