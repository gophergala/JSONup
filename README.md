# JSON UP

## What is it?

Post JSON to JSON UP.

Get alerted when json is BAD via:
 - SMS ( MVP )
 - Push notifications

View all status on a mobile friendly site
with sparklines of the posted values.


## Example JSON

```javascript
[
  {
    "name": "email.queue-count",
    "status": "OK",
    "value": 20
  },
  {
    "name": "servers.3.free-disk", # Domain label format
    "status": "OK", # OK,UP = GOOD. DOWN,FAIL = BAD.
    "value": 300,
    "value_label": "megabytes" # OPTIONAL
  },
]
```

# Development

JSON Up is written in `Go` on the backend,
uses `Redis` for data persistance and messaging,
 and `React.js (coffee)` on the frontend.


To run:
`foreman start`
