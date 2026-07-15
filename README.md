# omp-claude-hooks-bridge

> **Built on top of upstream.** This package reuses the `claude-hooks-bridge`
> implementation from [`Jonghakseo/pi-extension`](https://github.com/Jonghakseo/pi-extension)
> (originally published to npm as
> [`@ryan_nookpi/pi-extension-claude-hooks-bridge`](https://www.npmjs.com/package/@ryan_nookpi/pi-extension-claude-hooks-bridge))
> as its foundation, ports it to the omp runtime, and enhances it further.
> Full attribution and the list of enhancements are in [Origins](#origins)
> below — please credit the upstream authors if you reuse this code.

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

**This package is not a from-scratch implementation — it reuses and builds
on upstream work.** The entire hook-bridging design (settings discovery,
matcher logic, hook execution, decision extraction, transcript handling)
originates from the `claude-hooks-bridge` package in the
[`Jonghakseo/pi-extension`](https://github.com/Jonghakseo/pi-extension)
monorepo, originally published to npm as
[`@ryan_nookpi/pi-extension-claude-hooks-bridge`](https://www.npmjs.com/package/@ryan_nookpi/pi-extension-claude-hooks-bridge).
**All credit for the original design and implementation belongs to that
project's authors.**

### What was reused as-is

- The core hook lifecycle model (`SessionStart` / `UserPromptSubmit` /
  `PreToolUse` / `PostToolUse` / `Stop`) and its mapping onto extension
  events.
- Settings discovery and merge order across project and home
  `.claude/settings.json`.
- Matcher-pattern matching, tool-name aliasing, and hook decision extraction
  (`permissionDecision`, exit-code-2 blocking).
- Transcript-file generation for `Stop` hooks.

### What this fork ports and adds on top

- **Runtime port**: targets omp extension packaging (`omp.extensions`
  manifest, `omp plugin install`) and builds against the
  `@oh-my-pi/pi-coding-agent` extension SDK instead of `pi`'s.
- **`CLAUDE_CONFIG_DIR` support**: home-config resolution (`settings.json`,
  `installed_plugins.json`) now honors the `CLAUDE_CONFIG_DIR` environment
  variable, matching Claude Code's own documented config-dir override,
  instead of hardcoding `~/.claude`.
- **Security hardening**: transcript files and their directory are now
  created with restrictive `0600`/`0700` permissions instead of umask
  defaults, so session transcripts aren't world-readable on shared hosts;
  the plugin project-scope check is now path-boundary-safe instead of a
  raw prefix match, so a sibling directory can no longer inherit another
  project's plugin hooks.
- **Documentation**: a `Security` section spelling out exactly which hook
  events execute unconfirmed shell commands and when, plus this expanded
  attribution.

Naming and documentation are rebranded from `pi` to `omp` throughout, and
the package is republished under the `@drmikecrowe` namespace as
`@drmikecrowe/omp-claude-hooks-bridge`, **distributed under the same MIT
license as upstream** (see [`LICENSE`](./LICENSE), which carries forward
the original copyright notice).

If you fork or reuse this code further, please preserve this attribution
chain back to [`Jonghakseo/pi-extension`](https://github.com/Jonghakseo/pi-extension).
