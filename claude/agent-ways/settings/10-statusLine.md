---
scope: user
settings:
  statusLine:
    type: command
    command: ${HOME}/.claude/statusline.sh
---
# statusLine

Points Claude Code's status line at the operator's own script, which renders
directory · git branch (with dirty marker) · `owner/repo` · time. The script
itself is a **file artifact**, not a settings key, so it is not projected by this
fragment store — it is owned by dotfiles and installed to `~/.claude/statusline.sh`
on each host. This fragment owns only the *pointer*; dotfiles owns the *target*.

This key previously lived, inert, in the agent-ways repo-tracked `settings.json`,
where `ways reconcile` never projected it (reconcile co-owns only `hooks` and
`permissions`). The stale pointer that appeared in `~/.claude/settings.json` on
existing hosts is residue from the pre-1.0 in-place-clone topology, not an active
projection. Moving it here makes the fragment store the single owner of the key,
per ADR-147's "framework stops force-claiming user-scoped keys."
