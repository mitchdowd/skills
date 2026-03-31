# Mode Guidance

Use this document to decide whether the run is browser mode or API mode and to determine when to halt versus when to mark steps as blocked.

## Browser Mode

Choose browser mode when the task is primarily about user-visible behavior in a web application, such as:

- Navigation or page flow
- Forms, validation, or user interaction
- Layout or visual state
- Authentication or role-based UI behavior
- Browser-visible regressions in an existing feature

Requirements:

- The installed `/agent-browser` skill must be available.
- The underlying browser automation capability described by that skill must be usable.
- Any credentials needed to reach the target flow must be available.

Halt before execution if browser mode is required and the browser capability is unavailable.

## API Mode

Choose API mode when the task is primarily about programmatic behavior, such as:

- REST or HTTP endpoint behavior
- Response payloads, status codes, or headers
- Validation, authorization, or error responses
- Service-side regressions that do not require browser interaction

Requirements:

- An HTTP execution capability must be available.
- Any credentials, tokens, or environment-specific headers required by the API must be available.

Halt before execution if API mode is required and no HTTP execution capability is available.

## Single-Mode Rule

One run uses exactly one mode.

- If both browser and API coverage are needed, create separate runs.
- Do not mix browser and API evidence into the same run directory.

## Credential Rules

- Ask once for missing credentials before execution.
- If missing credentials prevent the entire run, halt before execution.
- If missing credentials only affect some steps, execute the unaffected steps and mark the affected steps as `BLOCKER`.

## Stop Conditions

Halt the run before execution when:

- The task is too incomplete to derive a responsible plan
- The selected mode cannot be supported with available tooling
- The whole run depends on credentials or access that are not available

Continue the run with partial coverage when:

- Only some steps lack credentials, test data, or access
- A failed step does not invalidate later independent checks

Mark later invalid steps as `NOT RUN` when an earlier failure or blocker makes them meaningless.