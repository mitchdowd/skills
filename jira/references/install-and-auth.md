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

If authentication is missing, start interactive login:

```bash
acli jira auth login
```

Wait for the user to complete the browser flow, then verify again:

```bash
acli jira auth status
```

## Version handling

For v1, download the managed Windows copy once when missing. Do not auto-update it.

## Recommended preflight

```bash
acli --version
acli jira auth status
```