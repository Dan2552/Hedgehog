Pry.hooks.add_hook(:after_session, "silence") do |output, binding, pry|
  Hedgehog::Terminal.silence!
end

Pry.hooks.add_hook(:when_started, "unsilence") do |output, binding, pry|
  Hedgehog::Terminal.restore!
end

Hedgehog::Terminal.restore!
