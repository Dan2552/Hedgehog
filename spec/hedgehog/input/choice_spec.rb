describe Hedgehog::Input::Choice do
  def stub_home_directory
    allow(Dir).to receive(:entries) do |with|
      if with == ENV['HOME'] || with == ENV['HOME'] + "/"
        ["Banana", "Doc1.txt", "Documents", "Downloads"]
      else
        []
      end
    end

    allow(File)
      .to receive(:directory?)
      .with("#{ENV['HOME']}/")
      .and_return(true)

    allow(File)
      .to receive(:directory?)
      .with("#{ENV['HOME']}")
      .and_return(true)

    ["Banana", "Documents", "Downloads"].each do |f|
      allow(File)
        .to receive(:directory?)
        .with("#{ENV['HOME']}/#{f}")
        .and_return(true)

      allow(File)
        .to receive(:file?)
        .with("#{ENV['HOME']}/#{f}")
        .and_return(false)
    end

    allow(File)
      .to receive(:directory?)
      .with("#{ENV['HOME']}/Doc1.txt")
      .and_return(false)

    allow(File)
      .to receive(:file?)
      .with("#{ENV['HOME']}/Doc1.txt")
      .and_return(true)
  end

  def stub_path
    instance_double = double

    allow(Hedgehog::Environment::Path)
      .to receive(:binaries)
      .and_return(["/bin/ls", "/bin/cd"])
  end

  let(:described_instance) do
    described_class.new(handle_teletype: false)
  end

  describe "#read_choice" do
    let(:spacing) { 0 }
    subject { -> { described_instance.read_choice(current_word, spacing) } }

    context "~" do
      let(:current_word) { "~" }

      context "when enter is pressed" do
        before do
          stub_characters(:enter)
        end

        it "returns the text to autofill" do
          expect(subject.call).to eq("~/")
        end
      end
    end

    context "~/" do
      let(:current_word) { "~/" }

      before { stub_home_directory }

      context "when enter is pressed" do
        before do
          stub_characters(:enter)
        end

        it "returns the text to autofill" do
          expect(subject.call).to eq("~/Banana/")
        end
      end
    end

    context "~/D" do
      let(:current_word) { "~/D" }

      before { stub_home_directory }

      context "when enter is pressed" do
        before do
          stub_characters(:enter)
        end

        it "returns the text to autofill" do
          expect(subject.call).to eq("~/Documents/")
        end
      end

      context "when down, enter is pressed" do
        before do
          stub_characters(:down, :enter)
        end

        it "returns the text to autofill" do
          expect(subject.call).to eq("~/Downloads/")
        end
      end

      context "when down, down, enter is pressed" do
        before do
          stub_characters(:down, :down, :enter)
        end

        it "returns the text to autofill" do
          expect(subject.call).to eq("~/Doc1.txt")
        end
      end

      context "when ctrl_c is pressed" do
        before do
          stub_characters(:ctrl_c)
        end

        it "raises Interupt" do
          expect(&subject).to raise_error(Interrupt)
        end
      end

      context "when esc is pressed" do
        before do
          stub_characters(:escape)
        end

        it "returns nil" do
          expect(subject.call).to eq(nil)
        end
      end
    end

    context "D" do
      let(:current_word) { "D" }

      it "immediately returns empty" do
        expect(subject.call).to eq(nil)
      end
    end

    context "using the binary completion proc" do
      let(:described_instance) do
        described_class.new(
          handle_teletype: false,
          completion_proc: Hedgehog::Input::Choice::PATH_BINARY_PROC
        )
      end

      before { stub_path }

      context "when l is word and enter is pressed" do
        let(:current_word) { "l" }

        before do
          stub_characters(:enter)
        end

        it "returns the text to autofill" do
          expect(subject.call).to eq("ls")
        end
      end

      context "when c is word and enter is pressed" do
        let(:current_word) { "c" }

        before do
          stub_characters(:enter)
        end

        it "returns the text to autofill" do
          expect(subject.call).to eq("cd")
        end
      end
    end
  end
end
