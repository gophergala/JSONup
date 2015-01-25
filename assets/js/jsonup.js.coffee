# Boilerplate code borrowed from the internet to make react nice to use.
build_tag = (tag) ->
  (options...) ->
    options.unshift {} unless typeof options[0] is 'object'
    React.DOM[tag].apply @, options

DOM = (->
  object = {}
  for element in Object.keys(React.DOM)
    object[element] = build_tag element
  object
)()

{div, ul, li, label, select, option, p, a, img, textarea, table, tbody, thead, th, tr, td, form, h1, input, span} = DOM
# End Boilerplate

JSONUp = React.createClass
  render: ->
    div {id: 'wrap'},
      div {id: 'header'},
        h1 {}, 'JSON ➔ Up?'
      div {id: 'postbox'}, PostBox() # Box that demos a POST request
      div {id: 'demobox'}, DemoBox() # Box that shows how to post in ruby, curl etc
      div {id: 'upboxes'}, UpBoxes(ups: @props.ups) # the status and sparklines

# This will be the box that demos the post functionality
PostBox = React.createClass
  exampleJSON: '[
      {"name":"server1","value":300,"status":"UP"},
      {"name":"server2","value":300,"status":"UP2"}
    ]'

  onSubmit: (e) ->
    e.preventDefault()
    console.log 'submitted'
    console.log(e.target)

  render: ->
    form {id: 'postform', onSubmit: @onSubmit},
      div {}, "Demo: Post JSON to jsonup.com"
      textarea {id: 'textarea', value: @exampleJSON}
      div {},
        input {type: 'submit'}

DemoBox = React.createClass
  render: ->
    ul {},
      li {},
        div {}, 'Go'
        div {}, 'Todo: go example'
      li {},
        div {}, 'Ruby'
        div {}, 'Todo: Ruby example'
      li {},
        div {}, 'Javascript'
        div {}, 'Todo Javascript example'

UpBoxes = React.createClass
  render: ->
    div {id: 'upbox-rows'},
      for up in @props.ups
        UpBox(up)

UpBox = React.createClass
  render: ->
    div {className: 'upbox-row'},
      span {class: 'upbox-name'}, @props.name,
      span {class: 'upbox-status'}, @props.status,
      span {class: 'sparkline'}, @props.sparkline,
      label {},
        input {type: 'checkbox'}
        "Monitor"
      select {name: 'upbox'},
        option {}, "Dead Man Switch",
        option {value: '1'}, "1 Minute"
        option {value: '5'}, "5 Minute"
        option {value: '60'}, "1 Hour"


class JSONUpCollection
  constructor: () ->
    @data = []

  getData: () ->
    @data

  add: (d) ->
    d.key = d.name
    found = false
    for val, key in @data
      if val.name == d.name
        found = true
        @data[key] = d

    @data.unshift(d) if not found


collection = new JSONUpCollection

sockUrl = "ws://127.0.0.1:11112/foobar"

handleMessage = (msg) ->
  d = JSON.parse(msg.data)
  console.log d
  collection.add(d)
  render()

document.addEventListener "DOMContentLoaded", (event) ->
  window.sock = new SocketHandler(sockUrl, handleMessage)
  render()

render = ->
  target = document.body
  React.render JSONUp(ups: collection.getData()), target, null
