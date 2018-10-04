unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("exit")

  function "exit" do |*args|
    exit(*args)
  end

end
