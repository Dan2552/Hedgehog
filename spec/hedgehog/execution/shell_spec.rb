describe Hedgehog::Execution::Shell do
  let(:described_instance) { described_class.new }
  it_behaves_like "execution"

  describe "#validate" do
    subject { described_instance.validate(command) }

    context "when the command is #treat_as_shell? as true" do
      let(:command) { double(treat_as_shell?: true) }

      it { is_expected.to eq(true) }
    end

    context "when the command is #treat_as_shell? as true" do
      let(:command) { double(treat_as_shell?: false) }

      it { is_expected.to eq(false) }
    end
  end

  describe "run" do
    subject { described_instance.run(command) }
    let(:command) { double(expanded: "abcdefg") }

    it "spawns a pty with with_binary_path" do
      rehyrate = Bundler.root.join("bin", "rehydrate_stdin.rb").to_s + " $?"

      expect(PTY)
        .to receive(:spawn)
        .with("$(exit 0); " + command.expanded + "; " + rehyrate)

      subject
    end

    context "when a previous process has returned a exit code" do
      before do
        `$(exit 123)`
      end

      it "spawns a process with that exit code" do
        rehyrate = Bundler.root.join("bin", "rehydrate_stdin.rb").to_s + " $?"

        expect(PTY)
          .to receive(:spawn)
          .with("$(exit 123); " + command.expanded + "; " + rehyrate)

        subject
      end
    end
  end
end
