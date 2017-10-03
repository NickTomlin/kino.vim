kino.vim ([kino?](https://www.wired.com/2011/11/1107wireless-remote-control/)))
---

This is a vim plugin for [kino](https://github.com/nicktomlin/kino) that allows you to control video playback on some sites chrome through a Vim binding.

Installation
---

1. Follow the [kino installation instructions](https://github.com/nicktomlin/kino)
2. Add this to your favorite plugin manager `Plug 'nicktomlin/remote.vim'` (or manually clone this repo and add it to your vim runtime path)

Usage
---

Vim remote exposes the following commands:

```
KToggle - play
```


Optionally: use the following bindings:

```
nmap <silent> <LocalLeader>vt :KToggle<CR>
```
