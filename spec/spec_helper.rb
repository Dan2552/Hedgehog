require 'bundler/setup'
Bundler.require(:default, :test)

Dir[Bundler.root.join("app", "hedgehog", "**", "*")].each do |f|
  require f if File.file?(f)
end

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.filter_run_when_matching :focus

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
