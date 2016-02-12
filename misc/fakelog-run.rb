#!/usr/bin/env ruby
require 'sigdump/setup'
require 'emony/configuration'
require 'emony/engine'

config = Emony::Configuration.new(
  sources: [
    {
      type: :network,
    }
  ],
  filters: {
    '*' => [
      {
        type: :numeric,
        key: 'reqtime',
        float: true,
        result_in_float: false,
        op: [multiply: 1000],
      },
    ],
  },
  aggregations: {
    '*' => {
      time: 'time',
      time_format: '%Y-%m-%d %H:%M:%S',
      window: {duration: 5, wait: 1},
      sub_windows: [{duration: 10, wait: 2, allowed_gap: 3}, {duration: 60, wait: 2, allowed_gap: 3}],
      items: {
        count: {type: :count},
        rps: {type: :persec},
        n: {type: :standard, key: 'reqtime'},
        #histo: {type: :histogram, key: 'reqtime', width: 20},
      },
      groups: {
        #path: {type: :path, key: 'path', default_level: 2},
      },
    },
  },
  outputs: {
    '*' => {type: :copy, outputs: [{type: :stdout}, {type: :forward, host: 'localhost', port: 37867}]},
  },
)
engine = Emony::Engine.new(config)
engine.prepare
engine.run
