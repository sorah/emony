## Tag format

### Record tag

Examples:

```
nginx.access_log
app.errors
```

- can't contain characters `:` `@` `$` `+` `/`

### Window label

Format: `{record_tag}(@{window})(:{group_name}/{group_key})`

Examples:

- `nginx.access_log`: primary window 
- `nginx.access_log@60`: subwindow for `nginx.access_log` where duration is 60 seconds
- `nginx.access_log:path//foo/bar`: Group window for `path` of `nginx.access_log` where key is `/foo/bar`
- `nginx.access_log@60:path//foo/bar`: Group subwindow for `path` of `nginx.access_log` where key is `/foo/bar` and duration is 60 seconds
