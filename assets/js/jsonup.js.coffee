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

{div, p, a, img, table, tbody, thead, th, tr, td, form, h1, input, span} = DOM
# End Boilerplate

JSONUp = React.createClass
  render: ->
    div {id: 'wrap'},
      div {id: 'main'}, 'Hello World'

document.addEventListener "DOMContentLoaded", (event) ->
  render()

render = ->
  target = document.body
  React.render JSONUp(), target, null
