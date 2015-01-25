# JSON UP

( Gopher Gala hackathon entry WIP)

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

# Work in progress

[screenshot](screenshot.png)

everything


# Members

Currently only me ( @eadz ).

If you want to join, submit a PR,
first 3 people to have one merged will be members!

# can use help with the following:
 * Go best practices ( I'm a newbie )
 * split up app.
 * still have to connect to twillio to verify SMS
 * still have to monitor for "Down" and send sms.
 * ratelimit SMS
 * "signup" process ( though this can be automatic really)
 * css
 * Usage examples
 * sparkline drawing in JS


 I'll be online sporadically but regularly until the end of the comp!

# Communication

see the `#jsonup` channel on the gophergala slack server.

I hope to launch a working version on jsonup.com by the close of competition.
