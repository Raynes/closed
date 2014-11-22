tilde = require 'tilde-expansion'
_s = require 'underscore.string'
fs = require 'fs'
path = require 'path'
{SelectListView} = require 'atom-space-pen-views'

module.exports =
class ClosedView extends SelectListView

  setFiles: (dir) ->
    @lastDir = dir
    files = ({'basename': f, 'dir': dir} for f in fs.readdirSync(dir))
    @setItems(files)

  onChange: =>
    text = @editor.getText()
    if text
      tilde text, (file) =>
        dir = if _s.endsWith(file, path.sep) then file else path.dirname(file)
        if fs.existsSync(dir)
          # Resolved to remove any trailing slashes.
          dir = path.resolve(dir)
          if not @lastDir? or @lastDir != dir
            @setFiles(dir)
        else
          @setItems([])

  getFilterQuery: ->
    text = @editor.getText()
    if _s.endsWith(text, path.sep)
      ''
    else
      path.basename(text)

  getFilterKey: -> 'basename'

  initialize: ->
    super

    @editor = @filterEditorView.getModel()
    @editor.onDidChange @onChange

    @addClass('overlay from-top')
    atom.workspaceView.append(this)

    atom.commands.add 'atom-workspace', 'closed:Open File': @show

  destroy: ->
    @remove()

  @restoreFocus: ->

  viewForItem: ({basename}) ->
    "<li>#{basename}</li>"

  confirmed: ({basename, dir}) =>
    file = path.join(dir, basename)
    stat = fs.lstatSync(file)
    if stat.isFile()
      atom.workspace.open(file)
      @cancel()
      @panel.hide()
    if stat.isDirectory()
      @editor.setText(file + path.sep)

  show: =>
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()
    @focusFilterEditor()
