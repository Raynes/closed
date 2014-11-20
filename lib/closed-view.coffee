tilde = require 'tilde-expansion'
fs = require 'fs'
{$, View} = require 'space-pen'

module.exports =
class ClosedView extends View
  @content: ->
    @div class: 'closed', =>
      @div outlet: 'open'

  good: ->
    @canOpen = true
    @input.removeClass('bad')
    @input.addClass('good')

  bad: ->
    @canOpen = false
    @input.removeClass('good')
    @input.addClass('bad')

  okay: ->
    @canOpen = false
    @input.removeClass('good')
    @input.removeClass('bad')

  onChange: =>
    text = @editor.getText()
    if text
      tilde text, (file) =>
        if fs.existsSync(file) && fs.lstatSync(file).isFile()
          @good()
        else
          @bad()
    else
      @okay()

  initialize: ->
    editor = document.createElement('atom-text-editor')
    editor.setAttribute('mini', true)
    @editorElement = editor
    @open.append(editor)
    @input = @open.find('atom-text-editor')
    @editor = editor.getModel()

    @panel = atom.workspace.addModalPanel({
      visible: false,
      item: this
    })

    @editor.onDidChange @onChange

    @command 'core:confirmed', =>
      if @canOpen
        text = @editor.getText()
        tilde text, (file) -> atom.workspaceView.open(file)
        @panel.hide()
      else
        console.log "File didn't exist."

    @command 'core:cancel', =>
      @panel.hide()

    atom.commands.add 'atom-workspace', 'closed:Open File': @show

  destroy: ->
    @panel.remove()

  show: =>
    @editor.setText('')
    @panel.show()
    @open.find('atom-text-editor').focus()
