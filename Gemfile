source "https://rubygems.org"

gem "activesupport"
gem "pry"
gem "rouge"

group :test do
  gem "rspec"
end

home_gemfile = "#{ENV["HOME"]}/.hedgehog.Gemfile"
instance_eval File.read(home_gemfile) if File.exists?(home_gemfile)
