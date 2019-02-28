describe Hedgehog::Environment::Path do
  before do
    @old = ENV["PATH"].dup
  end

  after do
    ENV["PATH"] = @old
  end

  describe ".all" do
    subject { described_class.all }

    before do
      ENV["PATH"] = "/bin:/usr/bin"
    end

    it "returns each path in $PATH" do
      expect(subject).to eq(["/bin", "/usr/bin"])
    end
  end

  describe ".binaries" do
    subject { described_class.binaries }

    let(:bin_path) { Bundler.root.join("bin") }

    before do
      ENV["PATH"] = bin_path.to_s
    end

    it "returns each binary in each path in $PATH" do
      expect(subject).to eq([bin_path.join("chruby_hedgehog").to_s, bin_path.join("hedgehog").to_s])
    end
  end
end
