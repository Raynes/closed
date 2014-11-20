ClosedView = require './closed-view'

module.exports =
  closedView: null

  activate: (state) ->
    @closedView = new ClosedView()

  deactivate: ->
    @closedView.destroy()
