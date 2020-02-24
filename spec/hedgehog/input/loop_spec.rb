describe Hedgehog::Input::Loop do
  let(:described_instance) { described_class.new }

  describe "await_user_input" do
    subject { described_instance.await_user_input }

    let(:editor) { double }
    let(:responses) { [nil] }

    before do
      allow(Hedgehog::Input::LineEditor)
        .to receive(:new)
        .and_return(editor)

      allow(editor)
        .to receive(:readline)
        .and_return(*responses)
    end

    it "uses the LineEditor to get a line" do
      Hedgehog::State.shared_instance.prompt = -> { "hello" }

      expect(editor)
        .to receive(:readline)
        .with("hello")

      subject
    end

    context "when LineEditor returns nil" do
      let(:responses) { [nil] }

      it "doesn't reloop" do
        expect(editor)
          .to receive(:readline)
          .once

        subject
      end
    end

    context "when LineEditor returns a line" do
      let(:line) { "hello world" }
      let(:responses) { [line, nil] }

      it "runs the command with Execution::Runner" do
        expect(Hedgehog::Execution::Runner)
          .to receive(:run)
          .with(line)

        subject
      end
    end

    context "when LineEditor returns a line multiple times" do
      let(:line) { "hello world" }
      let(:responses) { [line, line, nil] }

      it "runs each command with Execution::Runner" do
        expect(Hedgehog::Execution::Runner)
          .to receive(:run)
          .with(line)
          .twice

        subject
      end
    end
  end
end
