# Omarchy extras

Optional, Omarchy-only: a top-bar button for TuxSpeak and a themed popup for the
last dictation and history. Nothing here is needed for dictation itself.

- `xhisper` — bar module output: status icon (idle / dictating / transcribing).
- `xhisper-last` — click action: opens the last dictation, or closes it if open.
- `xhisper-view` — the popup (GTK4 + gtk4-layer-shell, PyGObject). Pinned
  bottom-right as an overlay, so it is never tiled. Esc or a click outside
  closes it. `xhisper-view history` opens the full history; Copy / History /
  Close buttons. Colours come from the current Omarchy theme.

Needs: `python-gobject`, `gtk4`, `gtk4-layer-shell`, `wl-clipboard`, `jq`.

## Install

```bash
mkdir -p ~/.config/omarchy/bar/scripts
cp xhisper xhisper-last xhisper-view ~/.config/omarchy/bar/scripts/
chmod +x ~/.config/omarchy/bar/scripts/*
```

Add a module to the bar in `~/.config/omarchy/shell.json` (use your own home path):

```json
{
  "id": "xhisper",
  "type": "command",
  "exec": "/home/YOU/.config/omarchy/bar/scripts/xhisper",
  "interval": 2,
  "onClick": "/home/YOU/.config/omarchy/bar/scripts/xhisper-last",
  "onRightClick": "setsid -f /home/YOU/.config/omarchy/bar/scripts/xhisper-view history >/dev/null 2>&1",
  "tooltip": "xhisper — click: last transcription, right click: history"
}
```

## Keyboard shortcut (optional)

Open/close the last-dictation popup with Super+I. Add to `~/.config/hypr/bindings.lua`
(check `hyprctl binds` first; plain Super+I is unused on stock Omarchy, whereas Super+X
is "Universal cut"):

```lua
o.bind("SUPER + I", "TuxSpeak last dictation", "/home/YOU/.config/omarchy/bar/scripts/xhisper-last")
```

## No fade-in (optional)

Hyprland fades layer-shell surfaces in by default. To make the popup appear instantly,
add to `~/.config/hypr/looknfeel.lua`:

```lua
hl.layer_rule({ match = { namespace = "^xhisper(-catcher)?$" }, no_anim = true, animation = "none" })
```
