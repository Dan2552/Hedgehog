Pry.hooks.add_hook(:after_session, "silence") do |output, binding, pry|
  Hedgehog::Teletype.silence!
end

Pry.hooks.add_hook(:when_started, "unsilence") do |output, binding, pry|
  Hedgehog::Teletype.restore!
end

Hedgehog::Teletype.restore!
