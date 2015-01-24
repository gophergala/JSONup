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

{div, p, a, img, textarea, table, tbody, thead, th, tr, td, form, h1, input, span} = DOM
# End Boilerplate


JSONUp = React.createClass
  render: ->
    div {id: 'wrap'},
      div {id: 'header'}, 'JSON ➔ Up?'
      div {id: 'postbox'}, PostBox()

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
      textarea {id: 'textarea', value: @exampleJSON, rows: 3, cols: 80}
      div {},
        input {type: 'submit'}

document.addEventListener "DOMContentLoaded", (event) ->
  render()

render = ->
  target = document.body
  React.render JSONUp(), target, null
