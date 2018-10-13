# TODO:
# - delegate assignment to ruby (e.g. b = "hello")
# - keep binding between ruby commands (e.g. `a = "hello"` and then `puts a`)
#
require 'pry'
require 'active_support/all'
require "readline"

require_relative "hedgehog/dsl"
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
end

# Load builtins
#
Dir[Bundler.root.join("app", "builtins", "**")].each do |f|
  require f
end

function("cd").call("~")

Bundler.send(:with_env, Hedgehog::State.shared_instance.env) do
  # Load ~/.hedgehog
  #
  begin
    load "#{ENV['HOME']}/.hedgehog"
  rescue LoadError
    puts "No .hedgehog file found, so using default configuration."
    puts
  end

  # Start
  #
  Hedgehog::Input.new.await_user_input
end
