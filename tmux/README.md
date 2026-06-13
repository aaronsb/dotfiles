# tmux — CUA menu bar, persistent, remote-friendly

A tmux config built around one goal: **a familiar, discoverable interface so I
actually _use_ persistent shells** — especially on remote machines. DOS / Turbo
Vision muscle memory, in plain tmux, everywhere.

## Design intent (the "why")

- **tmux, not zellij.** zellij was evaluated seriously — its WASM plugin system
  can render an integrated top menu bar (no overlay, no launch latency) and it
  ships a session-manager for free. But the whole driver here is _familiarity_,
  and zellij's different paradigm fights that. tmux is where the muscle memory
  lives, it's installed everywhere, and it's deeply scriptable. **Familiarity
  beat the nicer tech.**
- **Native `display-menu`, not a custom popup.** A Python/curses popup menu bar
  was prototyped — it could do live Left/Right cycling between menus. Rejected:
  ~75–100 ms launch latency per open, and it painted over the screen as an
  overlay. Native `display-menu` is instant and only covers its own dropdown.
  Trade-off: no arrow-cycling between open menus — **accepted**. (Prototype lives
  at `~/Projects/apps/tmux-menu`, shelved.)
- **CUA semantics.** File owns New / Close / Exit. "Detach — exit, sessions stay
  alive" is the safe exit; "Quit — kill ALL sessions" is the real one (confirmed).
  Destructive closes confirm first; resurrect can recover regardless. Shortcuts
  are deduplicated — each action has exactly one home, one key.
- **Discoverability _is_ the feature.** The menu bar, status buttons, and the
  live mouse on/off indicator exist so the persistence layer is _visible_ — not a
  command you must remember. That visibility is what gets it used. It's a human
  thing.

## What's here

- **Menu bar** (status-left): File / Edit / View / Window / Session.
  Click a label, or **F12 / Shift-F10** then the mnemonic (`f` `e` `v` `w` `s`).
- **Action buttons** (status-right): split `║`/`═`, `+tab`, switch `‹ ›`, resize,
  and a clickable **`mouse:on`/`mouse:off`** indicator (green/red, live).
- **Session menu → Attach/List** = `choose-tree -Zs` (the visual resume picker).
- **Persistence**: tmux-resurrect + tmux-continuum (auto-save every 15 min,
  auto-restore on server start → survives reboot). `prefix Ctrl-s` save,
  `prefix Ctrl-r` restore. Requires TPM:
  `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm` then `prefix I`.
- **Mouse toggle**: `prefix m` / `Shift-F12` / click the indicator. When off,
  re-enable via **F12 → View → Mouse On** (pure keyboard, works with no mouse).
  Mouse off = native terminal copy/paste; mouse on = clickable menus.
- **Remote resume**: `smux user@host` (zsh function — see
  `zsh/.zsh/conf.d/70-aliases`) = ssh + attach/create a persistent session, with
  a UTF-8 `LANG` so nerd glyphs render.

## Gotchas (hard-won — don't rediscover these)

- **Reload after every edit.** A running tmux keeps the OLD bindings until
  reloaded — this caused hours of "but I changed it" confusion. Use **View →
  Reload Config** or `prefix R`. Same for the `smux` zsh function: open a fresh
  terminal or `source ~/.zsh/conf.d/70-aliases`.
- **Remote nerd glyphs need a UTF-8 locale on the tmux _server_.** ssh doesn't
  forward `$LANG` and command-exec skips `/etc/locale.conf`, so tmux starts in
  C/POSIX and mangles Private-Use glyphs into `_` (plain ssh looks fine because
  it doesn't reprocess the bytes). `smux` prefixes `LANG=en_US.UTF-8`. The server
  locks its charset at _startup_ — so to change it you must **kill + restart the
  remote server** (reattaching keeps the old mode).
- **Quote `#{...}` formats inside `{ }` blocks.** tmux's block parser counts the
  `{` in a bare `#{?...}` as a block brace → "unclosed block / syntax error at
  EOF". Always `"#{?mouse,off,on}"`, never bare, inside `if … { … }`.
- **Commas inside `#{?a,b,c}` are branch delimiters.** A literal comma in a
  branch (e.g. `#[bg=colour22,fg=colour231]`) breaks the conditional. Split the
  style: `#[bg=colour22]#[fg=colour231]`.
- **Block separator is `;`, not `\;`.** `\;` is for _outside_ blocks
  (`bind k a \; b`); inside `{ … }` use a plain `;`.

## Related

- `zsh/.zsh/conf.d/70-aliases` — `smux` / `sshmux` remote-resume functions.
- `~/Projects/apps/tmux-menu` — shelved Python/curses popup-menu prototype with
  declarative TOML menus; revisit if a Rust (cursive) port is ever wanted.
