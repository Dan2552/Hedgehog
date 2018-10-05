unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("ls")

  function "ls" do |args|
    Process.spawn("ls -G #{args}")
    Process.wait
  end

end
