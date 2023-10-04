# Selectable

Selectable aims to help match dynamic input to modular code that was written to handle specific use cases. In a nutshell, you can think of Selectable as a more powerful and dynamic case statement where functionality can be added without having to curate a list of when clauses.

Please use caution when using this gem. While it should be safe in most cases, there is inherently risk associated with accepting somewhat arbitrary user input.

## Installation

Pull down the repo from github. In the project root execute the following commands to install dependencies, build the gem, and install it:

```
bundle install
gem build
gem install <gemfilefrombuild>
```

## Usage

Basic usage:

```
s = Selectable.new(namespace: MyModules)
selected_module = s.for('input_string')
```

### Complete Example

Create a YAML file with the following contents:

```
---
services:
  service_1:
    config:
      option1: value1
  service_2:
    config:
      option2: value2
  service_3:
    config:
      option3: value3
```



```
#!/usr/bin/env ruby
# frozen_string_literal: true

require "selectable"
require "yaml"

module MyModules
  module ModuleHandler
    def self.selectable_for
      ["service_1"]
    end

    def self.process(config)
      puts "Processing #{config}"
    end
  end
end

module MyModules
  class ClassHandler
    def self.selectable_for
      ["service_2"]
    end

    def process(config)
      puts "Processing #{config}"
    end
  end
end

services = YAML.safe_load(File.read('service_config.yml'))

s = Selectable.new(namespace: MyModules)
puts "The following inputs are selectable:"
puts s.selectors.inspect
puts

services["services"].each do |service, config|
  puts "Is #{service} selectable: #{s.selectable?(service)}"
  if s.selectable?(service)
    processor = s.for(service).respond_to?(:new) ? s.for(service).new : s.for(service)
    processor.process(config)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `selectable.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/erickcantwell/selectable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/erickcantwell/selectable/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Selectable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/erickcantwell/selectable/blob/main/CODE_OF_CONDUCT.md).
