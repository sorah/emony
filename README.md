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

#### Master

``` yaml
# vim: ft=yaml

master:
  listen_tcp: [::]:9755
  listen_udp: [::]:9755

web:
  listen: [::]:9754
  cors: '*.local'
  # Specify directory of web ui, if you use awesome web ui
  ui: /path/to/ui/directory

templates:
  default:
    key: server_name

    items:
      reqtime:
        type: numeric
        options:
          key: reqtime
          multiply: 1000
      requests:
        type: count
      rps:
        type: count
        options:
          round: 1s
      status:
        type: valuecount
        options:
          key: status

    # Use time from log?
    time: time
    # or
    # realtime: true

    dashboard:
      type: generic_access_log

    window:
      - length: 4s
        wait: 1s
        retention: 12h

    # sub groups (e.g. status for each server separately)
    groups:
      - type: reqpath
        key: path
        level: 2
        replace_numbers: true
      - type: kv
        key: _hostname

outputs:
  - type: zabbix
  - type: fluentd
  - type: exec
    command: your-favorite-output
```

### Aggregator

``` yaml
# vim: ft=yaml

aggregator:
  hostname: (optional)

master:
  tcp: master:9755
  udp: master:9756

inputs:
  - type: udp
    listen: [::]:9800
  - type: tcp
    listen: [::]:9800
    default_template: webapp
  - type: tail
    file: /var/log/nginx/access.log
    format: ltsv
  - type: exec
    command: ...
    format: ltsv
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/emony


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

