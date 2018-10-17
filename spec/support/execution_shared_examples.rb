shared_examples_for "execution" do
  it "responds to validate" do
    expect(described_instance).to respond_to(:validate)
  end

  it "responds to run" do
    expect(described_instance).to respond_to(:run)
  end
end
