---
scope: user
settings:
  attribution:
    commit: ""
    pr: ""
    sessionUrl: false
---
# attribution

Suppresses the three things Claude Code appends to commits and PRs on the
operator's behalf: the `Co-Authored-By` trailer (`commit`), the "Generated with
Claude Code" footer (`pr`), and the `Claude-Session: https://claude.ai/code/session_…`
transcript link (`sessionUrl`).

The first two are attribution preference. The third is a disclosure control. That
link resolves to the **full session transcript** — file contents, environment
values, tokens, internal paths — so publishing it on a public repo puts one click
between a commit and whatever happened to scroll through the session. ADR-162
carries the reasoning.

## Why the key set is split across two concerns

`commit` and `pr` govern only the footers; they never governed the session link.
The key that does, `sessionUrl`, was added in **v2.1.183** ("Added
`attribution.sessionUrl` setting to omit the claude.ai session link from commits
and PRs in web and Remote Control sessions"). It is **absent from the official
settings documentation** — upstream
[#69614](https://github.com/anthropics/claude-code/issues/69614) tracks that gap —
which is why it went unset here long after it shipped.

ADR-162 concluded no setting could govern the link and made a PreToolUse deny hook
the sole defense. That conclusion rested on
[#41873](https://github.com/anthropics/claude-code/issues/41873) (closed
*not planned*, April), which `sessionUrl` superseded in June. The ADR was written
in July, against a fact that had already changed. This fragment is the correction;
ADR-162's amendment records it.

## The hook stays

`sessionUrl` is scoped to "web and Remote Control sessions" — this operator runs
`remoteControlAtStartup: true`, which is the likely reason the link was reaching
commits at all. But a setting that is scope-qualified upstream, undocumented, and
whose default is *on* is not a control to stand behind alone. The ADR-162 hook
remains as the backstop; this key demotes it from sole defense to second line.

## Why this fragment is hand-authored

`ways settings new attribution.sessionUrl` refuses it, correctly. The community
SchemaStore copy defines `attribution` with `additionalProperties: false` and only
`commit` / `pr` — so `sessionUrl` is invalid *per the schema*, which predates the
v2.1.183 key and has not caught up (the same lag ADR-147 anticipated when it chose
SchemaStore as a de-facto, non-authoritative shape source).

The key is real; the schema is stale. So the fragment is written by hand rather
than scaffolded. `lint` passes it clean because schema-valid (ADR-147 check (a))
validates top-level keys and does not descend into nested object properties — an
unknown *top-level* key warns, an unknown *sub-key* is silent. That asymmetry is
what lets this fragment through, and it is a known gap rather than a licence.

The durable fix is upstream: SchemaStore should carry `attribution.sessionUrl`.
Once it does, this fragment scaffolds and validates like any other.
