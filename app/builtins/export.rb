unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("export")

  function "export" do |variable_assignment|
    var, value = variable_assignment.split("=")
    Hedgehog::State.shared_instance.env[var] = value
  end

end
