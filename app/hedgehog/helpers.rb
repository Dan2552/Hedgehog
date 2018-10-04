module Hedgehog
  def reload!
    exec(Bundler.root.join("bin", "hedgehog").to_s)
    exit 0
  end
  module_function :reload!
end
