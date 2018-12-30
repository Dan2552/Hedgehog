Pry.hooks.add_hook(:after_session, "silence") do |output, binding, pry|
  Hedgehog::Teletype.silence!
end

Hedgehog::Teletype.restore!
