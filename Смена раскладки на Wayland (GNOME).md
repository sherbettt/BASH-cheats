читай https://alt-gnome.wiki/keyboard-layouts.html

Смена раскладки по Caps кнопке:
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['grp:caps_toggle']"
```

Сброс раскладки для Caps кнопки:
```bash
gsettings reset org.gnome.desktop.input-sources xkb-options
```

Caps Lock как дополнительный Ctrl:
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"
```


Caps Lock как Escape (полезно для Vim/Emacs):
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
```


Смена раскладки по  Shift+Alt L
```bash
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
```

Смена раскладки по  Alt+Shift L
```bash
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>Shift_L']"
```
