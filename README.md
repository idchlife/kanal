# Kanal

Welcome to kanal!

TODO: Delete this and the text above, and describe your gem

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add kanal

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install kanal

## Usage

TODO: Write usage instructions here

## TODO

- [DONE] ~provide default response for branch with subbranches because default response could be handy~
    Provided with the :flow condition pack with condition :any
- [DONE] ~rework hooks storage, make hooks without arguments validation~
- provide default logger with base class. this logger service should be used by every other service/plugin etc
- provide default response on error, when router node fails with error
- [DONE] ~provide :source condition for :source~
    Created :source condition pack
- Allow to "append" conditions to condition packs


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kanal.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).