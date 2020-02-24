unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("ls")

  function "ls" do |args|
    shell_run "ls -G #{args}"
  end

end
