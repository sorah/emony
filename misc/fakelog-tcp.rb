#!/usr/bin/env ruby
require 'json'
require 'socket'

sock = TCPSocket.new(ARGV[0], ARGV[1])
Thread.new do 
  nil while sock.gets
end
IO.popen([File.join(__dir__, 'fakelog.rb')], 'r') do |io|
  while line = io.gets
    data = JSON.parse(line)
    payload = {id: "%.5f" % Time.now.to_f, tag: 'log', data: data}.to_json
    puts payload
    sock.puts payload
  end
end
