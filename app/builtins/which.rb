unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("which")

  function "which" do |args|
    binary = Hedgehog::Settings
      .shared_instance
      .binary_in_path_finder
      .call(args.first)

    puts binary
  end

end
