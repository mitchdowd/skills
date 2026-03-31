---
name: qa
description: Create, execute, and document a manual QA run for a task.
argument-hint: Specify the task source, testing scope, and any credentials
---

Create and execute a single-mode manual QA run for the specified task, then save the evidence to the supported output destination.

### 1. Confirm the Task Source

Supported task sources for this version are:

- Jira. Confirm the Jira issue key and verify that you have read access to the issue and any task details needed to plan the run.
- Local file. Confirm the file path and fetch the task content from the file.
- Inline task text. Use the task details already provided in the conversation.

If the task source is Jira, read the issue content needed to build the test plan, but do not write results back to Jira.

If the user wants you to test work that is only described in another external tracker, ask them to provide the task details as inline text or a local file. This skill does not write to external trackers.

### 2. Confirm the Output Destination

Confirm where the evidence package will be written.

For this version of the skill, the supported destination is the local filesystem.

- If the user asks for another destination, explain that it is not supported in this version and ask whether local output is acceptable.
- If the user does not specify a destination, use local output by default.

- Save every run under `TestResults/<task-id>/run-###/`.
- Auto-increment `run-###` for each repeated run of the same task ID, using three digits starting at `run-001`.
- Always create `plan.md`, `summary.md`, and `artifacts/` inside the run directory.

If the user wants a different local base directory, confirm it before planning. Otherwise default to `TestResults/` in the current workspace.

### 3. Build the Task Context

Extract the task into a consistent internal structure, including:

- Task ID
- Task title
- Source type
- Summary
- Acceptance criteria
- Environment hints
- Credentials hints
- Requested test mode, if the user has specified one

Also derive the initial regression scope:

- The primary user flow or API behavior under test
- Likely adjacent flows that could regress
- Any high-risk areas implied by the task, such as authentication, navigation, validation, permissions, data mutation, or performance-sensitive behavior

If key information is missing, identify the specific gap.

You may inspect the repository only when it is necessary to derive edge cases or regression coverage. Keep that inspection narrow: inspect only files, routes, modules, or changed areas directly implicated by the task. Do not do broad repository discovery.

### 4. Choose the Test Mode

Determine whether this run should be browser testing or API testing.

- If the user has explicitly specified the test mode, use what they said.
- Otherwise, infer the test mode from the task details.
- If you cannot infer the mode, or the task does not contain enough information to produce an effective test plan, warn the user clearly and ask whether they still want to continue.
- If browser mode is selected, follow the installed `/agent-browser` skill as the execution reference. That skill is the authoritative source for browser automation setup and command usage.

Each run must stay in a single mode only. Do not combine browser and API testing in the same run.

Use [references/mode-guidance.md](references/mode-guidance.md) as the mode-selection and stop-condition reference.

### 5. Validate Tools and Credentials

Before creating the final test plan, verify that the required tools and credentials are available.

Accepted credential sources are:

- Environment variables
- Direct user input

Do not persist raw credentials into any output artifact.

Required tooling by mode:

- Browser mode: The `/agent-browser` skill must be available and usable as the browser execution reference.
- API mode: An HTTP execution capability able to make the required HTTPS or REST calls must be available.

Required source access:

- Jira source: A Jira capability able to read the issue content must be available.

If a mandatory capability for the selected mode is unavailable, inform the user and halt before planning execution.

If the selected task source cannot be read, inform the user and halt before planning execution.

If required credentials are missing:

- Ask the user once for the missing credentials before execution.
- If the missing credentials are required for the entire run, halt before execution.
- If the missing credentials only affect specific planned steps, execute the unaffected steps and mark the credential-dependent steps as `BLOCKER`.

### 6. Create the Test Plan

Create a manual test plan based only on the task information and direct user answers. The plan should contain:

- The selected test mode
- The regression scope
- Any assumptions
- Any warnings about insufficient task detail
- Any required credentials or environment preconditions
- Numbered test steps
- The expected result for each step
- The evidence to capture for each step

Some good guidelines for creating effective test plans are:

- Use concise bullet points for each test plan step
- Include information on particular user roles needed (credentials may need requesting for those user types)
- Include both golden path and edge case tests
- Include non-functional checks such as page load time or response time when the task claims a performance improvement or when performance risk is part of the change
- Spend more time on higher-risk areas
- Include targeted regression coverage for larger or riskier tasks

Use the following status values when reporting test execution:

- `PASS`
- `FAIL`
- `BLOCKER`
- `NOT RUN`

Use [references/test-plan-template.md](references/test-plan-template.md) as the required plan structure.

### 7. Require Approval Before Execution

Present the proposed test plan to the user and ask for approval before executing any tests.

Do not execute the plan until the user approves it.

### 8. Execute the Approved Test Plan

Once the user approves the plan, execute the tests until the run is complete or blocked.

- Browser mode: Execute the browser flow by following the `/agent-browser` skill instructions. Capture evidence according to [references/evidence-guidelines.md](references/evidence-guidelines.md).
- API mode: Execute the relevant HTTP or REST requests and record request and response evidence according to [references/evidence-guidelines.md](references/evidence-guidelines.md).

If a planned step requires data creation or mutation, only perform controlled changes that are consistent with the task and safe for the target environment. Clean them up where practical.

If a step fails, continue with later relevant steps unless:

- Missing access, credentials, or tooling blocks execution
- An earlier failure makes a later step invalid
- The user-approved plan explicitly identifies a stop condition

Mark later invalidated steps as `NOT RUN`.

### 9. Package the Evidence

At the end of the run, create the evidence package in the approved output destination.

For this version of the skill, that destination is the approved local output directory.

The package must contain:

- `plan.md`: the approved plan that was executed
- `summary.md`: the `Auto QA Report`
- `artifacts/`: screenshots, logs, request and response captures, or other supporting files referenced by `summary.md`

The `Auto QA Report` in `summary.md` must include:

- Task ID and title
- Run directory
- Date and time of execution
- Selected mode
- Assumptions and warnings that affected confidence
- Missing capabilities or credentials that reduced coverage
- A numbered result list for every planned step using `PASS`, `FAIL`, `BLOCKER`, or `NOT RUN`
- A short findings section describing each failure or blocker and the likely cause when known
- A list of artifact filenames referenced by the report

The evidence may also include:

- Screenshots
- Console or error logs
- API requests and responses

Use [references/evidence-guidelines.md](references/evidence-guidelines.md) to decide what evidence is mandatory for each result type.

### 10. Finish Cleanly

Tell the user whether the run completed successfully, failed, or ended with blockers.

Highlight:

- Any failed steps
- Any blocked steps
- Any missing capabilities or credentials that reduced coverage
- Any warnings about task quality that could affect confidence in the result
- Any error messages or console logs which could indicate the cause of a failure

Do not commit code changes or modify git history as part of this skill.
