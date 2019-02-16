describe Hedgehog::Execution::Runner do
  let(:is_history_enabled) { false }
  let(:described_instance) do
    described_class.new(is_history_enabled: is_history_enabled)
  end

  before do
    Hedgehog::Settings.configure do |config|
      config.execution_order = [
        Hedgehog::Execution::Noop.new,
        Hedgehog::Execution::Alias.new,
        Hedgehog::Execution::Binary.new,
        Hedgehog::Execution::Ruby.new,
      ]
      config.input_history = Hedgehog::Input::History.new
    end
  end

  describe "#run" do
    let(:command_string) { "echo hello" }
    subject { described_instance.run(command_string) }

    it "builds a command from the string" do
      allow_any_instance_of(Hedgehog::Command)
        .to receive(:incomplete?)
        .and_return(true)

      expect(Hedgehog::Command)
        .to receive(:new)
        .with(command_string)
        .and_call_original

      subject
    end

    before do
      Hedgehog::Settings.shared_instance.execution_order.each do |adapter|
        allow(adapter)
          .to receive(:validate)
          .and_return(false)
      end
    end

    it "executes each strategy in order" do
      Hedgehog::Settings.shared_instance.execution_order.each do |adapter|
        expect(adapter)
          .to receive(:validate)
          .ordered
      end

      subject
    end

    context "when history is not enabled" do
      let(:is_history_enabled) { false }

      let(:history) do
        double.tap { |h| Hedgehog::Settings.shared_instance.input_history = h }
      end

      it "does not add the command to history" do
        expect(history)
          .to_not receive(:<<)

        subject
      end
    end

    context "when history is enabled" do
      let(:is_history_enabled) { true }

      let(:history) do
        double.tap { |h| Hedgehog::Settings.shared_instance.input_history = h }
      end

      it "adds the command to history" do
        expect(history)
          .to receive(:<<)
          .with(command_string)

        subject
      end
    end

    context "when a stategy validates" do
      before do
        Hedgehog::Settings.shared_instance.execution_order.each.with_index do |adapter, index|
          if index < 2
            allow(adapter)
              .to receive(:validate)
              .and_return(index == 1)
          end
        end
      end

      it "executes the strategy with the command" do
        expect(Hedgehog::Settings.shared_instance.execution_order[1])
          .to receive(:run)
          .with(instance_of(Hedgehog::Command))

        subject
      end
    end
  end
end
