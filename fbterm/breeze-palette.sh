# Apply Konsole "Breeze" 16-color palette to fbterm.
# fbterm palette-set escape: ESC [ 3 ; index ; r ; g ; b }   (RGB 0-255, decimal)
# Values copied verbatim from ~/.local/share/konsole/Breeze.colorscheme.
_fb_setpal() { printf '\033[3;%d;%d;%d;%d}' "$1" "$2" "$3" "$4"; }

# normal (0-7): Color0..Color7
# NOTE: index 0 is fbterm's default/erase background. Redefining it desyncs
# drawn cells from erased/padded cells -> "zebra stripes" in colored output
# (e.g. lsd). Leave it at fbterm's native black so erase and draw stay in sync.
# _fb_setpal 0   35  38  39    # black (Color0) -- intentionally NOT set
_fb_setpal 1  237  21  21    # red     (Color1)
_fb_setpal 2   17 209  22    # green   (Color2)
_fb_setpal 3  246 116   0    # yellow  (Color3)
_fb_setpal 4   29 153 243    # blue    (Color4)
_fb_setpal 5  155  89 182    # magenta (Color5)
_fb_setpal 6   26 188 156    # cyan    (Color6)
_fb_setpal 7  252 252 252    # white   (Color7)
# bright (8-15): Color0Intense..Color7Intense
_fb_setpal 8  127 140 141    # br black
_fb_setpal 9  192  57  43    # br red
_fb_setpal 10  28 220 154    # br green
_fb_setpal 11 253 188  75    # br yellow
_fb_setpal 12  61 174 233    # br blue
_fb_setpal 13 142  68 173    # br magenta
_fb_setpal 14  22 160 133    # br cyan
_fb_setpal 15 255 255 255    # br white

unset -f _fb_setpal
