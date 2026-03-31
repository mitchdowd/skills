# Install and Auth

This skill assumes Jira work should go through a local `acli` binary.

## Resolution order

1. Prefer `acli` from `PATH`.
2. On Windows, if `acli` is not on `PATH`, use the managed copy at `bin/windows/acli.exe`.
3. If the managed Windows copy does not exist yet, download it into the skill directory.
4. On non-Windows systems, if `acli` is missing, stop and ask the user before any machine-level install step.

## Managed Windows binary

Store the managed Windows binary here:

```text
jira/bin/windows/acli.exe
```

Download URLs:

```text
https://acli.atlassian.com/windows/latest/acli_windows_amd64/acli.exe
https://acli.atlassian.com/windows/latest/acli_windows_arm64/acli.exe
```

PowerShell download example:

```powershell
Invoke-WebRequest -Uri https://acli.atlassian.com/windows/latest/acli_windows_amd64/acli.exe -OutFile acli.exe
```

## Authentication flow

Check auth first:

```bash
acli jira auth status
```

`jira auth status` is plain text in ACLI v1.3.15 and does not support `--json`.

If authentication is missing, start interactive login explicitly:

```bash
acli jira auth login --web
```

If the Jira site is already known, prefer specifying it to avoid an extra site-selection prompt:

```bash
acli jira auth login --site "mysite.atlassian.net" --web
```

Wait for the user to complete the browser flow, then verify again:

```bash
acli jira auth status
```

Do not hide this inside a generic setup step for normal read operations. A failed auth check should either:

1. stop with a clear message telling the caller to run login, or
2. use an explicit login helper/template and then resume the original Jira command.

For this skill, prefer the helper with quiet mode so the auth step stays low-noise:

```bash
./templates/auth-login.sh --quiet --site "mysite.atlassian.net"
```

In agent responses, keep auth updates to a single brief note unless the flow fails or needs user intervention.

On Windows PowerShell, prefer invoking the managed binary directly:

```powershell
& ".\jira\bin\windows\acli.exe" jira auth status
& ".\jira\bin\windows\acli.exe" jira auth login --site "mysite.atlassian.net" --web
```

## Version handling

For v1, download the managed Windows copy once when missing. Do not auto-update it.

## Recommended preflight

```bash
acli jira auth status
```

Only print `acli --version` when debugging installation problems.

For requests like "list work items assigned to me", authenticate first, then run:

```bash
acli jira workitem search --jql "assignee = currentUser() ORDER BY updated DESC" --json
```