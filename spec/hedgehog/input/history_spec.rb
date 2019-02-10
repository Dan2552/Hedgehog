describe Hedgehog::Input::History do
  let(:described_instance) { described_class.new }

  describe "#up" do
    subject { described_instance.up }

    it "returns nil" do
      expect(subject).to eq(nil)
    end

    context "with matching argument" do
      subject { described_instance.up(matching: "a") }

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#down" do
    subject { described_instance.up }

    it "returns nil" do
      expect(subject).to eq(nil)
    end

    context "with matching argument" do
      subject { described_instance.down(matching: "a") }

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#<<" do
    let(:new_element) { "element" }

    subject { described_instance << new_element }

    it "adds an element" do
      subject
      expect(described_instance.up).to eq(new_element)
    end

    context "adding the same thing twice in a row" do
      before do
        described_instance << "one"
        described_instance << new_element
      end

      it "doesn't add it again" do
        subject
        expect(described_instance.up).to eq(new_element)
        expect(described_instance.up).to eq("one")
      end
    end

    context "when there is an empty input" do
      before do
        described_instance << "one"
        described_instance << ""
        described_instance << "two"
        described_instance << "three"
      end

      it "doesn't record the empty input" do
        expect(described_instance.up).to eq("three")
        expect(described_instance.up).to eq("two")
        expect(described_instance.up).to eq("one")
      end
    end

    context "when there are more elements than the limit" do
      let(:described_instance) { described_class.new(limit: 2) }

      before do
        described_instance << "one"
        described_instance << "two"
        described_instance << "three"
      end

      it "removes the oldest element" do
        expect(described_instance.up).to eq("three")
        expect(described_instance.up).to eq("two")
        expect(described_instance.up).to eq("two")
      end
    end
  end

  context "with elements" do
    before do
      described_instance << "one"
      described_instance << "two"
      described_instance << "three"
    end

    describe "#up and #down" do
      it "behaves like history" do
        expect(described_instance.up).to eq("three")
        expect(described_instance.up).to eq("two")
        expect(described_instance.up).to eq("one")
        expect(described_instance.up).to eq("one")
        expect(described_instance.down).to eq("two")
        expect(described_instance.down).to eq("three")
        expect(described_instance.down).to eq(nil)
        expect(described_instance.down).to eq(nil)
        expect(described_instance.up).to eq("three")
      end
    end

    describe "#up and #down with matching" do
      it "only results in matching history items" do
        expect(described_instance.up(matching: "e")).to eq("three")
        expect(described_instance.up(matching: "e")).to eq("one")
        expect(described_instance.up(matching: "e")).to eq("one")
        expect(described_instance.down(matching: "e")).to eq("three")
        expect(described_instance.down(matching: "e")).to eq(nil)
        expect(described_instance.down(matching: "e")).to eq(nil)
        expect(described_instance.up(matching: "e")).to eq("three")
        expect(described_instance.down).to eq(nil)
        expect(described_instance.up(matching: "w")).to eq("two")
      end
    end
  end
end
