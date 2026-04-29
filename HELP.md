# dotfiles

A simple symlink-based dotfiles manager backed by a manifest file. The repo at
`~/.dotfiles/` is a git repo that you `push` and `pull` like a save-point
between machines — no review process, just bytes traveling.

## Quick start

```sh
dotfiles status              # what's deployed?
dotfiles deploy --dry-run    # preview deploy actions
dotfiles deploy              # create symlinks
dotfiles diff --details      # see what's local vs origin
dotfiles push -m "msg"       # commit + push in one shot
dotfiles pull                # fast-forward pull
```

## Commands

### `status`

Show deployment state of every managed entry. Statuses:

| Status                | Meaning                                                  |
|-----------------------|----------------------------------------------------------|
| `DEPLOYED`            | symlink/copy is in place                                 |
| `DEPLOYED (git)`      | copy-mode entry deployed as a tracked git repo           |
| `NOT DEPLOYED`        | entry has no target on disk                              |
| `WRONG SYMLINK`       | target points elsewhere — run `deploy --force`           |
| `EXISTS (not managed)`| a real file is at the target — `--force` to back it up   |
| `DISABLED`            | manifest entry is turned off                             |
| `SOURCE MISSING`      | the source path inside the repo doesn't exist            |

### `deploy [--dry-run] [--force]`

Create symlinks (or recursive copies for `copy`-mode entries) per the manifest.

- `--dry-run` / `-n` — preview without making changes
- `--force` / `-f` — back up existing files to `~/.dotfiles-backup/<name>.<timestamp>` then overwrite

### `add <app> <system-path> [repo-path] [deploy-type]`

Register a new config in the manifest. After adding, drop the actual file/dir
into the repo path and run `deploy`.

- `<system-path>` — where the file lives in `$HOME` (e.g. `.config/foo`)
- `<repo-path>` — where it lives in the repo (default: `<app>/<basename>`)
- `<deploy-type>` — `symlink` (default) or `copy` (recursive, for nested git repos)

```sh
dotfiles add nvim .config/nvim                          # symlink mode
dotfiles add awesome .config/awesome awesome copy        # copy mode
```

### `enable <app>` / `disable <app>`

Flip the manifest's enabled flag. Disabling also removes the live symlink.

### `list`

Tabular dump of every manifest entry.

### `diff [--branch <b>] [--details]`

Preview local state vs `origin/<branch>` (default `main`). Shows uncommitted
changes, commits ahead, commits behind.

- `--branch` / `-b` — target a different branch (default `main`)
- `--details` / `-d` — expand to full colored diffs (like `git diff`)

### `pull [--branch <b>]`

Fetch and fast-forward pull from `origin/<branch>`. Requires being checked out
on the target branch. Prints what was pulled (commits + file stat).

### `push [--branch <b>] [--message <msg>]`

Commit (with prompt) and push to `origin/<branch>`.

If the working tree is dirty:
1. Prompts `Commit these? [y/N]`
2. Then `What changed?` for the message
3. Stages everything (`git add -A`) and commits

Then prompts to confirm the push.

- `--branch` / `-b` — push to a different remote branch
- `--message` / `-m <msg>` — skip all prompts (commit message + push confirm); one-shot mode

### `help`

This page.

## Manifest format

Pipe-delimited entries at `.dotfiles-manifest`:

```
<app>|<repo-path>|<target-path>|<enabled>|<deploy-type>
```

| Field         | Meaning                                                            |
|---------------|--------------------------------------------------------------------|
| `app`         | display name (`tmux`, `nvim`, ...)                                 |
| `repo-path`   | where the source lives in this repo (`tmux/.tmux.conf`)            |
| `target-path` | where to symlink/copy in `$HOME` (`.tmux.conf`)                    |
| `enabled`     | `true` or `false`                                                  |
| `deploy-type` | `symlink` (default) or `copy`                                      |

Lines starting with `#` are comments.

## Per-host overrides

Each machine can carry tracked customizations in `zsh/.zsh/host.d/<hostname>/`.
Files there are sourced after `conf.d/` based on `$HOST`. The default fragment
just sets `DOTFILES_HOST=<name>` so other code can branch on host.

To opt a host into background auto-update (runs `dotfiles pull && deploy` once
per N days on shell start), set this in its host fragment:

```sh
DOTFILES_AUTO_UPDATE_DAYS=7
```

Auto-update output lands in `~/.cache/dotfiles/auto-update.log`.

## Backups

When `deploy --force` overwrites an existing file, the original is moved to
`~/.dotfiles-backup/<name>.<timestamp>`. Recover by copying back, then
`disable` the entry if you don't want it managed.
