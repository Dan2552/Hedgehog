describe Hedgehog::Execution::Binary do
  let(:described_instance) { described_class.new }
  it_behaves_like "execution"

  describe "#validate" do
    subject { described_instance.validate(command) }

    context "when binary_path is present" do
      let(:command) { double(binary_path: double(present?: true)) }

      it { is_expected.to eq(true) }
    end

    context "when binary_path is not present" do
      let(:command) { double(binary_path: double(present?: false)) }

      it { is_expected.to eq(false) }
    end
  end

  describe "run" do
    subject { described_instance.run(command) }
    let(:command) { double(with_binary_path: "abcdefg") }

    before do
      allow(Process).to receive(:spawn)
      allow(Process).to receive(:wait)
      allow(Process).to receive(:kill)
    end

    it "spawns a process with with_binary_path" do
      expect(Process)
        .to receive(:spawn)
        .with("$(exit 0); script -q -t 0 /dev/null " + command.with_binary_path,
              anything)

      subject
    end

    context "when a previous process has returned a exit code" do
      before do
        `$(exit 123)`
      end

      it "spawns a process with that exit code" do
        expect(Process)
          .to receive(:spawn)
          .with("$(exit 123); script -q -t 0 /dev/null " + command.with_binary_path,
                anything)

        subject
      end
    end
  end
end
