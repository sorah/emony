# Emony: Real-time log aggregation

__NOTE:__ Early Development phase!

Emony aggregates log from servers and provides statistics in real-time.

## Architecture

- emony-master: Receives per-host statistics from server, aggregates statistics from all hosts, then provides API to get statistics
- emony-collector: Aggregates log then send to emony-master. Configuration is downloaded from master.

## Installation

    $ gem install emony

## Usage

### Configuration

(this is a planned one)

#### Collector

``` yaml
# vim: ft=yaml

sources:
  - type: network
    listen: [::]:9800
  - type: tail
    file: /var/log/nginx/access.log
    format: ltsv
    tag: nginx.access_log
    filters:
      - tagger:
          operations:
            - append:
                key: server_name
  - type: exec
    command: ...
    format: ltsv

aggregations:
  $default:
    items:
      reqtime:
        # Aggregator type
        type: numeric
        key: reqtime
        multiply: 1000
      requests:
        type: count
      rps:
        type: persec
      status:
        type: valuecount
        key: status

    # Use time from log? Specify key name
    time: time

    window:
      duration: 5
      wait: 1
    sub_windows:
      - duration: 60
        wait: 5
      - duration: 3600
        wait: 60

    # sub groups (e.g. status for each server separately)
    groups:
      path:
        type: reqpath
        key: path
        level: 2
        replace_numbers: true
      host:
        type: kv
        key: _hostname

forwards:
  default:
    - aggregator-001

# outputs:
```

#### Aggregator

```
inputs:
  - type: udp
    listen: [::]:9800
  - type: tcp
    listen: [::]:9800

aggregations:
  # ...

forwards:
  default:
    - master-001
```

#### master

```
inputs:
  - type: udp
    listen: [::]:9800
  - type: tcp
    listen: [::]:9800

aggregations:
  # ...

outputs:
  default:
    - type: sink
      url: http://sink-001
    - type: fluentd
      tag: xxx
      server: localhost:24224
```

#### Sink

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/emony


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

