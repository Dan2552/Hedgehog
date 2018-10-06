unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("export")

  function "export" do |args|
    arg_str = args.to_s

    matches = arg_str.scan(/\$(\w+)/).flatten
    matches.each do |match|
      arg_str.gsub!("$#{match}", ENV[match])
    end

    var, value = arg_str.split("=")
    ENV[var] = value
  end

end
