# Output (Internal)

## Audit

Audit is intended for development use to enable systematic event logging.

These logs are designed to be one-per-event. Each test may have multiple events, and multiple events will likely share similar event types. Events will overwrite _within_ each test, however, to ensure that only one event type is logged per test.

### Usage

A new AuditLog context should be created each time `probr` is run:

```
o := new(output.AuditLog)
```

Adding entries to the EventLogs requires the name of the test and a key-value pair to be inserted:

Currently `Audit()` only accepts strings for each of these arguments. 

```
n := "name-of-the-current-test"
k = "pods_created"
v = "1"
o.Audit(n, k, v)
```

Events and logs may be introspected:

```
r := o.Events["name-of-the-current-test"]["pods_created"]
fmt.Println(r) // "1"
```

Logs may be formatted to JSON for user-friendly output:

```
logs, _ := json.Marshal(o)
fmt.Println(logs) // {"Events":{"name-of-the-current-test":{"pods_created":"1"}}}
```