describe Hedgehog::BinaryInPathFinder::Ruby do
  let(:described_instance) { described_class.new }

  describe "#call" do
    subject { described_instance.call(binary) }

    before do
      allow(Hedgehog::Environment::Path)
        .to receive(:binaries)
        .and_return(["/tmp/banana"])
    end

    context "when the binary is in $PATH" do
      let(:binary) { "banana" }

      it "returns the absolute path" do
        expect(subject).to eq("/tmp/banana")
      end
    end

    context "when the binary is not in $PATH" do
      let(:binary) { "apple" }

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end
  end
end
