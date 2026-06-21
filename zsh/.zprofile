# ~/.zprofile — sourced once per login shell, AFTER the text user/pass prompt.

# Make mlterm-fb the default terminal on the bare framebuffer console.
#
# Every one of these must hold, or we stay in the plain text console:
#   TERM=linux                  -> a real VT, not a graphical terminal
#   -t 0                        -> interactive tty
#   no DISPLAY/WAYLAND_DISPLAY  -> not inside a graphical session
#   no SSH_TTY/SSH_CONNECTION   -> never over SSH
#   no MLTERM                   -> not already inside mlterm (recursion guard)
#   /dev/fb0 writable           -> framebuffer/video driver actually up
#   in the `input` group        -> evdev access (else mlterm can't read the kbd)
#   mlterm-fb on PATH           -> it's actually installed
#
# Lockout-proof: press any key within 2s to skip; and it's *run, not exec'd*,
# so a crash / failed load / exit drops you back to this plain shell.
if [[ "$TERM" == "linux" && -t 0 ]] \
   && [[ -z "${DISPLAY}${WAYLAND_DISPLAY}${SSH_TTY}${SSH_CONNECTION}${MLTERM}" ]] \
   && [[ -w /dev/fb0 ]] \
   && id -Gn | grep -qw input \
   && command -v mlterm-fb >/dev/null 2>&1; then
  if read -t 2 -k 1 'k?Starting mlterm-fb — press any key to stay in the plain console… '; then
    print -- $'\nplain console.'
  else
    print
    mlterm-fb
    # returns here when mlterm-fb exits or crashes; type 'exit' again to log out
  fi
fi
