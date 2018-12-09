describe Hedgehog::Execution::Noop do
  let(:described_instance) { described_class.new }
  it_behaves_like "execution"

  describe "#validate" do
    subject { described_instance.validate(command) }

    context "when the command original is empty" do
      let(:command) { double(original: "") }

      it { is_expected.to eq(true) }
    end

    context "when the command original is not empty" do
      let(:command) { double(original: "a") }

      it { is_expected.to eq(false) }
    end
  end

  describe "run" do
    subject { described_instance.run(command) }
    let(:command) { double }

    it "does nothing" do
      # no idea how to spec that
    end
  end
end
