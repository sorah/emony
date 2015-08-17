# Emony: Real-time log aggregation

__NOTE:__ Early Development phase!

Emony aggregates log from servers and provides statistics in real-time.

## Architecture

- emony-master: Receives per-host statistics from server, aggregates statistics from all hosts, then provides API to get statistics
- emony-collector: Aggregates log then send to emony-master. Configuration is downloaded from master.

## Installation

    $ gem install emony

## Usage

TBD

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/emony


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

