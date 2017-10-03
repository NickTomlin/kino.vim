[Telekino](https://www.wired.com/2011/11/1107wireless-remote-control/))
---

This is a vim plugin for [remote](https://github.com/nicktomlin/telekino) that allows you to control video playback on some sites chrome through a Vim binding.

Installation
---

1. Follow the  [remote installation instructions](https://github.com/nicktomlin/remote)
2. Add this to your favorite plugin manager `Plug 'nicktomlin/remote.vim'` (or manually clone this repo and add it to your vim runtime path)

Usage
---

Vim remote exposes the following commands:

```
VRToggle - play
```


Optionally: use the following bindings:

```
nmap <silent> <LocalLeader>vt :VRToggle<CR>
```
