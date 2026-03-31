# Structured Output

Prefer JSON output whenever the result needs to be inspected, filtered, or reused.

Exception: `acli jira auth status` is plain text and should be handled by exit code plus human-readable output.

## Default output mode

Use `--json` by default for:

- search commands
- view commands
- list commands
- create and edit commands whose output will be inspected
- transition, assign, comment, clone, and similar mutation commands

Use plain text only when the user explicitly wants a quick human-readable command or wants to open Jira in the browser.

## Targeting rules

- Default mutations to a single explicit work item key.
- Use JQL, filter IDs, or file-based targeting only when the request clearly asks for bulk behavior.
- Search first when the target key is not yet known.

## Complex create and edit requests

Common fields should use direct flags:

- `--project`
- `--type`
- `--summary`
- `--description`
- `--description-file`
- `--assignee`
- `--label` or `--labels`
- `--parent`

When a request needs a richer payload, use JSON input instead:

```bash
acli jira workitem create --from-json workitem.json --json
acli jira workitem edit --key TEAM-123 --from-json workitem.json --json
acli jira project create --from-json project.json
```

## Terminology normalization

Normalize user language internally:

- issue -> work item
- ticket -> work item
- story -> work item type
- bug -> work item type
- epic -> work item type or parent, depending on context

Keep user-facing explanations natural, but map the execution path onto ACLI `workitem` commands.