# Evidence Guidelines

Use these rules when populating `artifacts/` and writing `summary.md`.

## General Rules

- Never store raw credentials, session tokens, or secrets in any artifact.
- Redact sensitive values in logs, URLs, headers, and request bodies before saving them.
- Every `FAIL` and `BLOCKER` must have either a supporting artifact or a written explanation in `summary.md`.
- `PASS` steps should include enough evidence to prove the step was executed. A short written note is acceptable when a separate artifact adds no value.

## Browser Mode

- Capture at least one screenshot for each major browser flow.
- Capture a screenshot for every visible failure state.
- Record console errors, network failures, or browser-visible warnings when they appear and are relevant to the failed step.
- If navigation or page state is part of the assertion, record the resulting URL or page title in `summary.md` or an artifact.

Suggested artifact names:

- `step-01-home.png`
- `step-03-validation-error.png`
- `step-03-console.log`

## API Mode

- Save the method, endpoint, and relevant request payload for each meaningful API assertion.
- Save the response status code, relevant headers, and the body or body excerpt needed to justify the result.
- Redact secrets from headers, cookies, tokens, and payloads before saving them.
- If response timing is part of the assertion, record it in `summary.md`.

Suggested artifact names:

- `step-02-request.txt`
- `step-02-response.json`
- `step-04-response.txt`

## Summary Expectations

`summary.md` should reference artifact filenames directly so the reader can match each failure or blocker to its evidence.