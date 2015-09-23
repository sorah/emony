# Glossary

- __Source:__ Data source, such as TCP, UDP, and tail.
- __Aggregator:__ Method to aggregate, summarize data. Such as standard, count, persec, count.
- __Sub aggregate:__ Aggregate within single aggregator node before forwarding to other, to reduce bandwidth
- __Grouping:__ Aggregate data again by group where divided by specified key. (Assume HTTP access log; Group and aggregate again for each URLs. You'll know what path experiecing slow response or receiving many requests.)
- __Forward:__ Forward data to other node. Data may be _sub aggregated._
- __Router:__ Used to determine where to send data. Data should be sent to one same server finally, to aggregate correctly. Router helps that. Some strategy may require additional process or server.
- __Output:__ where to send aggregated data (= result). Such as _Sink_, file, fluentd, zabbix...
- __Sink:__ Provides API and UI. It's implemented as _an output._
