unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("cd")

  function "cd" do |*args|
    Dir.chdir(args.join(" ").gsub("~", "#{ENV['HOME']}"))
  end

end
