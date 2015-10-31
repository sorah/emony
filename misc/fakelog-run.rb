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
  aggregations: {
    '*' => {
      time: 'time',
      window: {duration: 5, wait: 1},
      sub_windows: [{duration: 10, wait: 2, allowed_gap: 3}, {duration: 60, wait: 2, allowed_gap: 3}],
      items: {
        count: {type: :count},
        n: {type: :standard, key: 'reqtime'},
        histo: {type: :histogram, key: 'reqtime', width: 20},
      },
      groups: {
        path: {type: :path, key: 'path', default_level: 2},
      },
    },
  },
  outputs: {
    '*' => {type: :stdout},
  },
)
engine = Emony::Engine.new(config)
engine.prepare
engine.run
