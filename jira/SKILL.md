---
name: jira
description: Jira operations through a local Atlassian CLI installation. Use when the user needs to create, search, view, or update Jira work items, projects, boards, sprints, or filters using acli.
argument-hint: Describe the Jira task to perform
user-invocable: true
disable-model-invocation: false
---

# Jira via local ACLI

Use this skill for Jira work through a local Atlassian CLI installation. Prefer local `acli` for supported Jira tasks.

## Core workflow

1. Ensure a usable CLI is available. Start with `templates/setup-acli.sh` if needed.
2. Prefer `acli` from `PATH` when present.
3. On Windows, if `acli` is missing, download a managed copy to `bin/windows/acli.exe`.
4. On Windows, prefer invoking the managed binary directly from PowerShell: `& ".\\bin\\windows\\acli.exe" ...`.
5. Check authentication with plain `acli jira auth status`.
6. Do not assume auth commands support `--json`; inspect their plain-text exit status and output.
7. If authentication is missing, prefer `templates/auth-login.sh --quiet --site "<site>"` when the site is known. Otherwise run `acli jira auth login --web`, then wait for the interactive browser flow to complete before continuing.
8. After login completes, rerun `acli jira auth status` and only then run the original Jira command.
9. Prefer `--json` for commands whose output will be inspected or transformed.
10. Normalize Jira language internally: issue, ticket, story, bug, and epic should map onto ACLI `workitem` operations.
11. Default all mutation commands to a single explicit work item key unless the prompt clearly asks for bulk targeting.
12. Keep auth-related user updates minimal: one short note before login starts, then continue silently unless login fails or requires user action.
13. Avoid using a background terminal for normal auth unless there is a concrete need to keep working in parallel.

## Supported operations

### Work items

- `acli jira workitem assign`
- `acli jira workitem attachment list`
- `acli jira workitem clone`
- `acli jira workitem comment create`
- `acli jira workitem comment list`
- `acli jira workitem create`
- `acli jira workitem edit`
- `acli jira workitem link create`
- `acli jira workitem link list`
- `acli jira workitem search`
- `acli jira workitem transition`
- `acli jira workitem view`

### Projects

- `acli jira project create`
- `acli jira project list`
- `acli jira project view`

### Boards

- `acli jira board list-sprints`
- `acli jira board search`

### Sprints

- `acli jira sprint list-workitems`

### Filters

- `acli jira filter list`
- `acli jira filter search`

## Command guidance

Use direct ACLI commands for straightforward reads and single-step mutations.

```bash
acli jira workitem search --jql "project = TEAM AND status = 'To Do'" --json
acli jira workitem search --jql "assignee = currentUser() ORDER BY updated DESC" --json
acli jira workitem view TEAM-123 --json
acli jira workitem create --project TEAM --type Story --summary "Add API retries" --json
acli jira workitem assign --key TEAM-123 --assignee "@me" --json
acli jira board list-sprints --id 42 --json
acli jira sprint list-workitems --board 42 --sprint 7 --json
```

For complex create or edit requests, use `--from-json` instead of trying to force everything through simple flags.

## References

- See [references/install-and-auth.md](references/install-and-auth.md) for bootstrap, local binary management, and interactive login rules.
- See [references/commands.md](references/commands.md) for the supported command surface and example invocations.
- See [references/structured-output.md](references/structured-output.md) for JSON defaults, targeting rules, and complex payload handling.

## Templates

- `templates/setup-acli.sh`: resolves `acli`, installs a managed Windows copy if needed, and reports auth status without starting login unless `--login` is passed. Supports `--site` and `--quiet`.
- `templates/auth-login.sh`: explicit interactive login helper that starts browser auth and verifies success. Supports `--site` and `--quiet`.
- `templates/workitem-search.sh`: deterministic work item search wrapper with JSON output.
- `templates/workitem-create.sh`: deterministic create wrapper for common fields plus `--from-json`.
- `templates/workitem-update.sh`: deterministic single-work-item wrapper for view, assign, comment, attachment, edit, link, transition, and clone.
- `templates/resource-inspect.sh`: deterministic wrappers for projects, boards, sprints, and filters.

## Working style

- Use the documented commands and templates in this skill as the first choice for covered Jira work.
- Keep outputs structured unless the user explicitly asks for a quick human-readable command or browser view.
- Do not treat a pending interactive login as task completion. Resume the original Jira operation after auth succeeds.
- When a request needs a Jira object lookup before a mutation, search or view first, then mutate.
- Prefer known-site login to avoid an extra site-selection step.