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
    let(:command) { double(with_binary_path: double) }

    before do
      allow(Process).to receive(:spawn)
      allow(Process).to receive(:wait)
      allow(Process).to receive(:kill)
    end

    it "spawns a process with with_binary_path" do
      expect(Process)
        .to receive(:spawn)
        .with(command.with_binary_path)

      subject
    end

    it "waits for the process to finish" do
      expect(Process)
        .to receive(:wait)

      subject
    end

    context "when the process is interrupted" do
      let(:pid) { double }

      before do
        allow(Process)
          .to receive(:spawn)
          .and_return(pid)

        expect(Process)
          .to receive(:wait)
          .and_raise(Interrupt)

        expect(Process)
          .to receive(:wait)
          .and_return(nil)
      end

      it "kills the process" do
        expect(Process)
          .to receive(:kill)
          .with("INT", pid)

        subject
      end

      it "puts a funny arrow thing" do
        expect(STDOUT)
          .to receive(:puts)
          .with("⏎")

        subject
      end
    end
  end
end
