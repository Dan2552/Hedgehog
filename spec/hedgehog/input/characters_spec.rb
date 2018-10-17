describe Hedgehog::Input::Characters::Character do
  let(:string) { "a" }
  let(:described_instance) { described_class.new(string) }

  describe "#is?" do
    let(:string) { "\e[A" }
    let(:value) { :up }
    subject { described_instance.is?(value) }

    context "when the value matches the character" do
      it { is_expected.to eq(true) }
    end

    context "when the value does not match the character" do
      let(:value) { :down }
      it { is_expected.to eq(false) }
    end
  end

  describe "#known_special?" do
    subject { described_instance.known_special? }

    context "if the character is a known special character" do
      let(:string) { "\e[A" }
      it { is_expected.to eq(true) }
    end

    context "if the character is not special" do
      let(:string) { "a" }
      it { is_expected.to eq(false) }
    end
  end

  describe "#unknown?" do
    subject { described_instance.unknown? }

    context "character is unknown" do
      let(:string) { "\enjdjs" }
      it { is_expected.to eq(true) }
    end

    context "if the character is a known special character" do
      let(:string) { "\e[A" }
      it { is_expected.to eq(false) }
    end

    context "character is a non-special character" do
      let(:string) { "a" }
      it { is_expected.to eq(false) }
    end
  end

  describe "#to_s" do
    subject { described_instance.to_s }
    let(:string) { double(to_s: "hello") }

    it "returns the to_s value of the given string" do
      expect(subject).to eq("hello")
    end
  end

  describe "#method_missing" do
    subject { described_instance.length }

    it "calls the method on the string" do
      expect(string)
        .to receive(:length)

      subject
    end
  end
end

describe Hedgehog::Input::Characters do
  let(:described_instance) { described_class.new }

  describe "#get_next" do
    subject { described_instance.get_next }

    let(:char) { "a" }

    before do
      allow(STDIN)
        .to receive(:getc)
        .and_return(char)
    end

    it "reads from STDIN.getc" do
      expect(STDIN)
        .to receive(:getc)

      subject
    end

    it "returns a Character representing STDIN" do
      expect(subject).to be_a(Hedgehog::Input::Characters::Character)
      expect(subject.to_s).to eq(char)
    end
  end
end
