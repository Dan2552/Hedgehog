unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("export")

  function "export" do |args|
    var, value = args.to_s.split("=")
    Hedgehog::State.shared_instance.env[var] = value
  end

end
