# closed

Closed is a basic approximation of Emacs's ido-mode for opening files and
directories. It'll pop open a panel similar to the command palette and will
give you possible completions as you type paths. It'll also expand ~ for you.

**Opening Closed**
* `cmd-ctrl-p` (`alt-ctrl-p` on Linux): Open a file.

**While In Closed**
* `enter` (or `tab`): If the current selection is a file then open it otherwise complete
  the current path.
* `cmd-enter` (`ctrl-enter` on Linux): Open current path. If it's an existing
  directory, open in a new atom window, otherwise create a file.

![Closed](http://raynes.me/hfiles/goodclosed2.png)
