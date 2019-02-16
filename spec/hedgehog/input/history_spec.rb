describe Hedgehog::Input::History do
  let(:persistence_filepath) { nil }
  let(:described_instance) { described_class.new(persistence_filepath: persistence_filepath) }

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

    context "when persisting" do
      let(:persistence_filepath) { "/tmp/hedgehog.yaml" }

      context "if the file doesn't exist" do
        before do
          expect(File)
            .to receive(:exists?)
            .with(persistence_filepath)
            .and_return(false)
        end

        it "returns nil" do
          expect(subject).to eq(nil)
        end
      end

      context "if the file exists" do
        before do
          allow(File)
            .to receive(:exists?)
            .with(persistence_filepath)
            .and_return(true)

          allow(YAML)
            .to receive(:load_file)
            .with(persistence_filepath)
            .and_return(["one", "two", "three"])
        end

        it "reads the history from the file" do
          expect(subject).to eq("three")
        end

        context "and it's empty" do
          before do
            allow(YAML)
              .to receive(:load_file)
              .with(persistence_filepath)
              .and_return(false)
          end

          it "returns nil" do
            expect(subject).to eq(nil)
          end
        end
      end
    end
  end

  describe "#down" do
    subject { described_instance.down }

    it "returns nil" do
      expect(subject).to eq(nil)
    end

    context "with matching argument" do
      subject { described_instance.down(matching: "a") }

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when persisting" do
      let(:persistence_filepath) { "/tmp/hedgehog.yaml" }

      context "if the file doesn't exist" do
        before do
          expect(File)
            .to receive(:exists?)
            .with(persistence_filepath)
            .and_return(false)
        end

        it "returns nil" do
          expect(subject).to eq(nil)
        end
      end

      context "if the file exists" do
        before do
          expect(File)
            .to receive(:exists?)
            .with(persistence_filepath)
            .and_return(true)

          expect(YAML)
            .to receive(:load_file)
            .with(persistence_filepath)
            .and_return(["one", "two", "three"])
        end

        it "still returns nil" do
          expect(subject).to eq(nil)
        end
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
      let(:described_instance) { described_class.new(limit: 2, persistence_filepath: persistence_filepath) }

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

    context "when adding an element with whitespace" do
      before do
        described_instance << " hello "
      end

      it "strips the whitespace" do
        expect(described_instance.up).to eq("hello")
      end
    end

    context "when persisting" do
      let(:persistence_filepath) { "/tmp/hedgehog.yaml" }

      before do
        allow(FileUtils).to receive(:mkpath)
        allow(File).to receive(:write)
      end

      it "writes to the file" do
        expect(FileUtils)
          .to receive(:mkpath)
          .with("/tmp")

        expect(File)
          .to receive(:write)
          .with(persistence_filepath, "---\n- element\n")

        subject
      end

      context "when using ~ for home directory" do
        let(:persistence_filepath) { "~/tmp/hedgehog.yaml" }

        it "substitutes for home" do
          expect(FileUtils)
            .to receive(:mkpath)
            .with("~/tmp".sub("~", ENV['HOME']))

          expect(File)
            .to receive(:write)
            .with(persistence_filepath.sub("~", ENV['HOME']), anything)

          subject
        end
      end

      context "and there are duplicate elements" do
        before do
          allow(FileUtils).to receive(:mkpath).exactly(3).times
          allow(File).to receive(:write).exactly(3).times

          described_instance << "element"
          described_instance << "blah"
        end

        it "only saves the latest" do
          expect(File)
            .to receive(:write)
            .with(persistence_filepath, "---\n- blah\n- element\n")

          described_instance << "element"
        end
      end
    end
  end

  context "with elements" do
    before do
      described_instance << "one"
      described_instance << "two"
      described_instance << "three"
    end

    describe "#up and #down and #reset_index!" do
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

      it "can be reset" do
        expect(described_instance.up).to eq("three")
        expect(described_instance.up).to eq("two")
        described_instance.reset_index!
        expect(described_instance.up).to eq("three")
        expect(described_instance.up).to eq("two")
      end
    end

    describe "#up and #down with matching" do
      it "only results in matching history items" do
        expect(described_instance.up(matching: "e")).to eq("three")
        expect(described_instance.up(matching: "e")).to eq("one")
        expect(described_instance.up(matching: "e")).to eq("one")
        expect(described_instance.up(matching: "z")).to eq(nil)
        expect(described_instance.down(matching: "e")).to eq("three")
        expect(described_instance.down(matching: "e")).to eq(nil)
        expect(described_instance.down(matching: "e")).to eq(nil)
        expect(described_instance.up(matching: "e")).to eq("three")
        expect(described_instance.down).to eq(nil)
        expect(described_instance.up(matching: "w")).to eq("two")
      end
    end
  end

  describe "#suggestion_for" do
    let(:start) { "ech" }
    subject { described_instance.suggestion_for(start) }

    context "when there is no matching history" do
      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when there is matching history" do
      before do
        described_instance << "echo 1"
        described_instance << "echo 2"
      end

      it "returns the most recently executed one" do
        expect(subject).to eq("echo 2")
      end
    end
  end
end
