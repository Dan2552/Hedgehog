require_relative "hedgehog/teletype"

begin
  require 'active_support/all'
  require_relative "hedgehog/dsl"
  require 'shellwords'
  require 'readline'
  require 'io/console'
  require 'yaml'
  require 'fileutils'

  include Hedgehog::DSL

  # Load Hedgehog library
  #
  Dir[Bundler.root.join("app", "hedgehog", "**", "*")].each do |f|
    require f if File.file?(f)
  end

  # Default settings
  #
  Hedgehog::Settings.configure do |config|
    config.binary_in_path_finder = Hedgehog::BinaryInPathFinder::Ruby.new
    config.disabled_built_ins = []
    config.execution_order = [
      Hedgehog::Execution::Noop.new,
      Hedgehog::Execution::Alias.new,
      Hedgehog::Execution::Binary.new,
      Hedgehog::Execution::Ruby.new,
    ]
    config.input_history = Hedgehog::Input::History.new
  end

  # Load builtins
  #
  Dir[Bundler.root.join("app", "builtins", "**")].each do |f|
    require f
  end

  Bundler.send(:with_env, Hedgehog::State.shared_instance.env) do
    # Load ~/.hedgehog
    #
    dot_hedgehog = "#{ENV['HOME']}/.hedgehog"
    load dot_hedgehog if File.exists?(dot_hedgehog)

    # Start
    #
    unless Hedgehog::Settings.shared_instance.disable_interaction
      Hedgehog::Input::Loop.new.await_user_input
    end
  end
ensure
  Hedgehog::Teletype.restore!
end
