source "https://rubygems.org"

gem "activesupport"
gem "pry"

# This is used to override behavior of `$?`, to ensure the correct pid and
# exitstatus are returned.
#
gem "rspec-mocks"

group :test do
  gem "rspec"
end

home_gemfile = "#{ENV["HOME"]}/.hedgehog.Gemfile"
instance_eval File.read(home_gemfile) if File.exists?(home_gemfile)
