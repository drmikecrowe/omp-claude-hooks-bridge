# omp-claude-hooks-bridge

Bridge [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) (`.claude/settings.json`) into omp (Oh My Pi) extension lifecycle events.

## What it does

- Reads `.claude/settings.json` hooks configuration from the project root
- Executes hooks at matching lifecycle events:
  - **SessionStart** → `session_start`
  - **UserPromptSubmit** → `before_agent_start`
  - **PreToolUse** → `tool_call` (can block / ask for confirmation)
  - **PostToolUse** → `tool_result`
  - **Stop** → `agent_end` (can queue follow-up messages)
- Supports matcher patterns (regex or pipe-separated tool names)
- Maps omp tool names to Claude Code equivalents (`bash` → `Bash`, etc.)
- Handles hook JSON output with `permissionDecision` / exit code 2 for blocking
- Provides transcript files for Stop hooks

## Requirements

- **bash** is required — hooks are executed via `bash -lc`. Works on macOS and Linux. Not natively supported on Windows.

## Security

This extension executes shell commands found in **any** `.claude/settings.json`
it discovers — the current project's (`<cwd>/.claude/settings.json`), your
home config (`$CLAUDE_CONFIG_DIR/settings.json`, default `~/.claude/settings.json`),
`~/.claude.json`, and installed plugin `hooks.json` files — with the same
privileges as the omp process itself (`bash -lc <command>`, full environment).

**Only `PreToolUse` "ask"/"block" decisions go through a user confirmation
prompt.** `SessionStart`, `UserPromptSubmit`, `PostToolUse`, and `Stop` hooks
run immediately and unconditionally the moment their lifecycle event fires —
`SessionStart` hooks run before you've typed anything.

**Opening or `cd`-ing into a directory whose `.claude/settings.json` you do
not trust is equivalent to running its shell commands.** Treat an untrusted
repository containing hook configuration the same way you'd treat an
untrusted shell script — do not open it with this extension active unless
you've reviewed `.claude/settings.json` first.

## Install

```bash
omp plugin install @drmikecrowe/omp-claude-hooks-bridge
```

## Origins

Adapted from **pi** to **omp** (Oh My Pi).

This extension began life as the `claude-hooks-bridge` package in the
[`Jonghakseo/pi-extension`](https://github.com/Jonghakseo/pi-extension) monorepo,
originally published to npm as
[`@ryan_nookpi/pi-extension-claude-hooks-bridge`](https://www.npmjs.com/package/@ryan_nookpi/pi-extension-claude-hooks-bridge).

This fork ports it to the [omp (Oh My Pi)](https://github.com/oh-my-pi) extension
runtime and republishes it under the `@drmikecrowe` namespace as
`@drmikecrowe/omp-claude-hooks-bridge`. Changes from upstream:

- Targets omp extension packaging (`omp.extensions` manifest, `omp plugin install`).
- Builds against the `@oh-my-pi/pi-coding-agent` extension SDK.
- Naming and documentation rebranded from `pi` to `omp`.

The core hook-bridging behavior is unchanged. Credit for the original
implementation belongs to the upstream `pi-extension` authors; this package
is distributed under the same MIT license.
