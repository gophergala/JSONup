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

{div, embed, ul, svg, li, label, select, option, p, a, img, textarea, table, tbody, thead, th, tr, td, form, h1, h2, h3, h4, input, span} = DOM
# End Boilerplate

JSONUp = React.createClass
  render: ->
    div {id: 'wrap'},
      div {id: 'header'},
        h1 {}, 'JSON ➔ Up?'
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
    console.log(@exampleJSON)
    http = new XMLHttpRequest()
    http.open("POST", "/push/foobar", true);
    http.send(@exampleJSON)

  render: ->
    form {id: 'postform', onSubmit: @onSubmit},
      div {className: 'demoform'},
        span {}, '[{ "name": "'
        input {id: 'demo-name', defaultValue: 'server.redis'},
        span {}, '", "status": "'
        input {id: 'demo-status', defaultValue: 'UP', className: 'sm'},
        span {}, '", "value": '
        input {id: 'demo-value', defaultValue: 200, className: 'sm'},
        span {}, '}]'

      div {className: 'submit-div'},
        input {type: 'submit', className: 'submitbutton', value: 'POST to jsonup.com/push/$userid'}

DemoBox = React.createClass

  getInitialState: ->
    {selected: 'menu-livedemo'}

  handleClick: (e) ->
    e.preventDefault()
    @state.selected = e.target.id
    render()

  classNameFor: (menuname) ->
    if @state.selected == "menu-" + menuname
      "selected"
    else
      ""

  render: ->
    div {id: 'menu-wrap'},
      ul {id: 'menu'},
        li {},
          a {href: '#', id: 'menu-livedemo', onClick: @handleClick, className: @classNameFor('livedemo')}, 'Live Demo'
        li {},
          a {href: '#', id: 'menu-ruby', onClick: @handleClick, className: @classNameFor('ruby')}, 'Ruby'
        li {},
          a {href: '#', id: 'menu-go', onClick: @handleClick, className: @classNameFor('go')}, 'Go'
        li {},
          a {href: '#', id: 'menu-javascript', onClick: @handleClick, className: @classNameFor('javascript')}, 'Javascript'

      div {className: 'menu-content'}, PostBox() if @state.selected == 'menu-livedemo'
      div {className: 'menu-content'}, 'Todo: go example' if @state.selected == 'menu-go'
      div {className: 'menu-content'}, 'Todo: Ruby example' if @state.selected == 'menu-ruby'
      div {className: 'menu-content'}, 'Todo Javascript example'  if @state.selected == 'menu-javascript'

UpBoxes = React.createClass
  render: ->
    div {id: 'upbox-rows'},
      for up in @props.ups
        UpBox(up)

UpBox = React.createClass
  render: ->
    div {className: 'upbox-row'},
      span {className: 'upbox-name'}, @props.name
      span {className: 'upbox-status'}, @props.status
      Sparkline({sparkline: @props.sparkline})
      label {},
        input {type: 'checkbox'}
        "Monitor"
      select {name: 'upbox'},
        option {}, "Dead Man Switch",
        option {value: '1'}, "1 Minute"
        option {value: '5'}, "5 Minute"
        option {value: '60'}, "1 Hour"

Sparkline = React.createClass
  render: ->
    console.log @props
    if @props.sparkline && @props.sparkline.length > 0
      img {src: "http://chart.apis.google.com/chart?cht=lc" +
        "&chs=100x30&chd=t:#{@props.sparkline}&chco=666666" +
        "&chls=1,1,0" +
        "&chxt=r,x,y" +
        "&chxs=0,990000,11,0,_|1,990000,1,0,_|2,990000,1,0,_" +
        "&chxl=0:||1:||2:||" }

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
