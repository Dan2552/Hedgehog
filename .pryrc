Pry.hooks.add_hook(:after_session, "raw") do |output, binding, pry|
  Hedgehog::Terminal.raw!
end

Pry.hooks.add_hook(:when_started, "cooked") do |output, binding, pry|
  Hedgehog::Terminal.cooked!
end

Hedgehog::Terminal.cooked!
