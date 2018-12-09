describe Hedgehog::Execution::Runner do
  let(:described_instance) { described_class.new }

  describe "#run" do
    let(:command_string) { "echo hello" }
    subject { described_instance.run(command_string) }

    it "builds a command from the string" do
      allow_any_instance_of(Hedgehog::Command)
        .to receive(:incomplete?)
        .and_return(true)

      expect_any_instance_of(Hedgehog::Command)
        .to receive(:<<)
        .with(command_string)

      subject
    end

    context "when the command is complete" do
      before do
        allow_any_instance_of(Hedgehog::Command)
          .to receive(:incomplete?)
          .and_return(false)

        Hedgehog::Settings.configure do |config|
          config.execution_order = [
            Hedgehog::Execution::Noop.new,
            Hedgehog::Execution::Alias.new,
            Hedgehog::Execution::Binary.new,
            Hedgehog::Execution::Ruby.new,
          ]
          config.input_history = Hedgehog::Input::History.new
        end

        Hedgehog::Settings.shared_instance.execution_order.each do |adapter|
          allow(adapter)
            .to receive(:validate)
            .and_return(false)
        end
      end

      it "returns true" do
        expect(subject).to eq(true)
      end

      it "executes each strategy in order" do
        Hedgehog::Settings.shared_instance.execution_order.each do |adapter|
          expect(adapter)
            .to receive(:validate)
            .ordered
        end

        subject
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

    context "when the command is not complete" do
      before do
        allow_any_instance_of(Hedgehog::Command)
          .to receive(:incomplete?)
          .and_return(true)
      end

      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end
end
