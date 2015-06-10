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
        @file = file
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

    @addClass('overlay closed-editor')
    atom.workspace.addTopPanel item: this

    atom.commands.add 'atom-workspace', 'closed:Open File': @show
    atom.commands.add '.closed-editor', 'closed:Open Current': @justOpen
    atom.commands.add '.closed-editor', 'closed:Delete Filename': @deleteFileName
  destroy: ->
    @remove()

  cancel: ->
    super
    @panel.hide()

  viewForItem: ({basename}) ->
    "<li>#{basename}</li>"

  existsAndIsDir: (file) ->
    if fs.existsSync(file)
      fs.lstatSync(file).isDirectory()

  justOpen: =>
    if @existsAndIsDir(@file)
      atom.open pathsToOpen: [@file] #, newWindow: true
    else
      atom.workspace.open(@file)
    @cancel()
    @panel.hide()

  # Remove the last level, file or directory, from the filter path

  deleteFileName: =>
    currentPath = @editor.getText()
    newPath = path.normalize(path.dirname(currentPath) + path.sep)
    @editor.setText(newPath)



  confirmed: ({basename, dir}) =>
    file = path.join(dir, basename)
    if @existsAndIsDir(file)
      @editor.setText(file + path.sep)
    else
      atom.workspace.open(file)
      @cancel()
      @panel.hide()

  show: =>
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    currentPath = atom.workspace.getActiveTextEditor()?.buffer?.file?.path;
    if currentPath?
      @editor.setText(path.dirname(currentPath) + path.sep)
    else
      tilde '~', (home) =>
        @editor.setText(home + path.sep)
    @storeFocusedElement()
    @focusFilterEditor()
