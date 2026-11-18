# Delegation rule

You have a `subagent` tool (agents: scout, planner; both read-only). Decide per task:

- Small, tightly connected, or needing exact details: do it yourself in this session.
- Large but self-contained and summarisable (searching a codebase, reading logs, reviewing a diff): delegate to a sub-agent. Use `scout` or `planner`; this profile has no agent that can edit files, so do any changes yourself.
- Long-running work or several jobs in parallel: suggest separate herdr panes (see the herdr skill) and let the user decide.

A sub-agent's report is a claim, not proof. Check the actual diff or test output before treating work as done.
