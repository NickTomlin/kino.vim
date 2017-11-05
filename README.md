kino.vim ([kino?](https://www.wired.com/2011/11/1107wireless-remote-control/))
---

This is a Vim plugin for [kino](https://github.com/nicktomlin/kino) that allows you to perform browser actions from the comfort of the best text editor.

Installation
---

1. Follow the [kino installation instructions](https://github.com/nicktomlin/kino) (install the kino client/server and extension)
2. Add this to your favorite plugin manager `Plug 'nicktomlin/remote.vim'` (or manually clone this repo and add it to your vim runtime path)

Usage
---

`kino.vim` exposes the `:KAction` command which takes one argument, the name of the action configured in the Kino extension. E.g. to dispatch the `toggle` action to the currently active tab:

```viml
:Kaction toggle
```

To bind this to a shortcut, you can use a simple mapping:

```
nmap <silent> <LocalLeader>kt :KAction toggle<CR>
" repeat last kino action
nmap <silent> <LocalLeader>kl :KLastAction<CR>
```
