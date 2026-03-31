# Supported Commands

This skill intentionally keeps a narrow, predictable ACLI surface.

## Work items

Search work items by JQL:

```bash
acli jira workitem search --jql "project = TEAM ORDER BY created DESC" --json
```

View a work item:

```bash
acli jira workitem view TEAM-123 --json
acli jira workitem view TEAM-123 --fields "key,summary,status,assignee,description" --json
```

Create a work item:

```bash
acli jira workitem create --project TEAM --type Task --summary "Investigate flaky test" --json
acli jira workitem create --from-json workitem.json --json
```

Edit a work item:

```bash
acli jira workitem edit --key TEAM-123 --summary "Updated summary" --json
acli jira workitem edit --key TEAM-123 --from-json workitem.json --json
```

Assign a work item:

```bash
acli jira workitem assign --key TEAM-123 --assignee "@me" --json
```

Add a comment:

```bash
acli jira workitem comment create --key TEAM-123 --body "Please verify in staging." --json
```

List comments:

```bash
acli jira workitem comment list --key TEAM-123 --json
```

List attachments:

```bash
acli jira workitem attachment list --key TEAM-123 --json
```

Create a link:

```bash
acli jira workitem link create --out TEAM-123 --in TEAM-456 --type Blocks
```

List links:

```bash
acli jira workitem link list --key TEAM-123 --json
```

Transition a work item:

```bash
acli jira workitem transition --key TEAM-123 --status "In Progress" --json
```

Clone a work item:

```bash
acli jira workitem clone --key TEAM-123 --to-project TEAM2 --json
```

## Projects

List projects:

```bash
acli jira project list --json
acli jira project list --paginate --json
```

View a project:

```bash
acli jira project view --key TEAM --json
```

Create a project:

```bash
acli jira project create --from-project TEAM --key NEWTEAM --name "New Team" 
acli jira project create --from-json project.json
```

## Boards

Search boards:

```bash
acli jira board search --project TEAM --json
acli jira board search --name Platform --type scrum --json
```

List sprints on a board:

```bash
acli jira board list-sprints --id 42 --json
acli jira board list-sprints --id 42 --state active,closed --json
```

## Sprints

List sprint work items:

```bash
acli jira sprint list-workitems --board 42 --sprint 7 --json
```

## Filters

List personal or favourite filters:

```bash
acli jira filter list --my --json
acli jira filter list --favourite --json
```

Search filters:

```bash
acli jira filter search --name report --json
acli jira filter search --owner user@example.com --json
```