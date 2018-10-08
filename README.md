# Hedgehog - interactive shell

Hedgehog is a Ruby/Bash hybrid command line shell for macOS (it may work on other unix systems but is untested at this time).

Note: this project is probably not yet ready to be a daily-driver. Only set as your shell if you know how to recover.

## Installation

- Clone this repository
- Run `bundle install`
- Run `bin/hedgehog` or `bundle exec ruby app/app.rb`

## Usage

A `.hedgehog` file is read from your home directory on startup. This file is written in Ruby. Here you can set environment variables, define aliases, and customize and expand Hedgehog as you wish.

Here's an example:

```ruby
# Variables
run "export PATH=/usr/local/bin:$PATH"

# Customize Ruby objects
class String
  def magenta;        "\e[35m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end
end

# Define methods
def cwd
  `pwd`.chomp.split("/").last
end

# Customize the prompt
prompt { cwd.magenta + " > ".gray }

# Define aliases. Unlike `def` methods, these will take
# precedent over bash commands.
function "my_alias" do |args|
  puts "hello #{args}"
end

# Override builtins to customize behavior.
original_cd = function "cd"
function "cd" do |args|
  original_cd.call(args)
  # Your extra behavior here.
end
```

## Primary design goals

### Ruby console

You can execute Ruby code interactively (similarly to IRB) straight in the interactive shell. The Ruby programming language is a perfect compliment - full dynamic, minimal syntactical baggage and heavily expandable. All of the benefits of the Ruby language that you would expect, including the huge collaboration of the Ruby community (gems) are available to be used.

Here's some examples:

```ruby
> 3.times { puts "hello world" }
hello world
hello world
hello world
=> 3
```

```ruby
> ENV["PATH"]
=> "/usr/local/sbin:/usr/local/bin:/Users/dan2552/.gem/ruby/2.5.1/bin:/Users/dan2552/.rubies/ruby-2.5.1/lib/ruby/gems/2.5.0/bin:/Users/dan2552/.rubies/ruby-2.5.1/bin:/usr/bin:/bin"
```

### High compatability with bash

Inputs that are automatically recognized as bash commands will be delegated to bash itself. This is an easy means to achieving good compatibility for the most common usages for an interactive shell.

Here's some examples of commands that are compatible:

```bash
export PATH=/usr/local/bin:$PATH
```

```bash
echo $PATH
```

```bash
RAILS_ENV=test bundle exec rails c
```
