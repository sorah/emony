# Glossary

- __Source:__ Data source, such as TCP, UDP, and tail.
- __Record:__ Datam from _source._ (e.g. one line of access log)
- __Tag:__ identifier to determine data stream. e.g. `nginx.access_log`
- __Aggregator:__ Method to aggregate, summarize records. Such as standard, count, persec, count.
- __Sub aggregate:__ Aggregate within single aggregator node before forwarding to other, to reduce bandwidth. Subaggregation may occur multiple time.
- __Grouping:__ Aggregate records again by group where divided by specified key. (Assume HTTP access log; Group and aggregate again for each URLs. You'll know what path experiecing slow response or receiving many requests.)
- __Forward:__ Forward data to other node, where data is either _sub aggregated data_ or _record_
- __Router:__ Used to determine where to send data. Data should be sent to one same server finally, to aggregate correctly. Router helps that. Some strategy may require additional process or server.
- __Output:__ where to send aggregated data (= result). Such as _Sink_, file, fluentd, zabbix...
- __Sink:__ Provides API and UI. It's implemented as _an output._
- __Node:__
  - __Collector node:__ node where collects _records_ from _sources,_ then forwards _subaggregated data_ to _aggregator node_ or _master node._
  - __Aggregator node:__ node where only do _subaggregation_ and _forwarding._
  - __Master node:__ node where perform final aggregatation for single _tag,_ then send it to output.
