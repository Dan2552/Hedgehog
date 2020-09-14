describe Hedgehog::Execution::Alias do
  let(:described_instance) { described_class.new }
  it_behaves_like "execution"

  describe "#validate" do
    subject { described_instance.validate(command) }

    let(:cd_proc) { double(call: nil, present?: true) }

    before do
      allow(Hedgehog::State.shared_instance)
        .to receive(:aliases)
        .and_return({ "cd" => cd_proc })
    end

    context "when the command binary_name is an alias" do
      let(:command) { double(binary_name: "cd") }

      it { is_expected.to eq(true) }
    end

    context "when the command binary_name is not an alias" do
      let(:command) { double(binary_name: "bash") }

      it { is_expected.to eq(false) }
    end
  end

  describe "run" do
    subject { described_instance.run(command) }

    let(:cd_proc) { double(:cd_proc, call: nil, present?: true) }

    before do
      allow(Hedgehog::State.shared_instance)
        .to receive(:aliases)
        .and_return({ "cd" => cd_proc })
    end

    context "when the command binary_name is an alias" do
      let(:command) { Hedgehog::Command.new("cd ~/somewhere/over.the/rainbow one two") }

      it "runs the alias proc" do
        expect(cd_proc)
          .to receive(:call)
          .with("~/somewhere/over.the/rainbow one two")

        subject
      end
    end
  end
end
