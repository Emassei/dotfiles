# Pi sub-agent extension (personal profile only)

Copied from pi 1.5.2's `examples/extensions/subagent/` and pinned here so upgrades
cannot change it. Each sub-agent is a separate `pi --mode json -p --no-session`
process; it inherits the parent's environment, so it stays on the same profile.

Changes from upstream:
- Removed the hardcoded `model:` lines so sub-agents use the session's model.
- `scout` no longer has `bash` (read-only: read, grep, find, ls).

`worker` has every tool and `reviewer` has `bash`. Treat both as full-permission agents.
Not enabled for the work profile.
