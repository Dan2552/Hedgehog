unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("which")

  function "which" do |first_word|
    binary = Hedgehog::Settings
      .shared_instance
      .binary_in_path_finder
      .call(first_word)

    puts binary
  end

end
