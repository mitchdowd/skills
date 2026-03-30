---
name: qa
description: Create and execute a manual QA test plan for a task, then record the evidence.
argument-hint: Specify the task source and any testing scope or credentials
---

Create and execute a manual QA test plan for the specified task.

### 1. Identify the Task Source

Determine where the task should be read from. Supported sources for this version are:

- Jira. Confirm the Jira issue key and verify that you have Jira access capable of reading the issue, adding a comment, and attaching evidence. If you do not, inform the user and halt.
- Local file. Confirm the file path and fetch the task content from the file.
- Inline task text. Use the task details already provided in the conversation.

Do not explore the repository for additional context in this version of the skill.

### 2. Build the Task Context

Extract the task into a consistent internal structure, including:

- Task ID
- Task title
- Source type
- Summary
- Acceptance criteria
- Environment hints
- Credentials hints
- Requested test mode, if the user has specified one

If key information is missing, identify the specific gap.

### 3. Choose the Test Mode

Determine whether this run should be browser testing or API testing.

- If the user has explicitly specified the test mode, use what they said.
- Otherwise, infer the test mode from the task details.
- If you cannot infer the mode, or the task does not contain enough information to produce an effective test plan, warn the user clearly and ask whether they still want to continue.
- If browser mode is selected, load the `/agent-browser` skill before validating tools or planning execution. Treat that skill as the authoritative instruction source for browser automation setup and command usage.

Each run must stay in a single mode only. Do not combine browser and API testing in the same run.

### 4. Validate Tools and Credentials

Before creating the final test plan, verify that the required tools and credentials are available.

Accepted credential sources are:

- Environment variables
- The source task text
- Direct user input

Required tooling by mode:

- Browser mode: The `/agent-browser` skill must be available and used as the browser testing capability reference. Follow that skill to determine whether the underlying `agent-browser` tooling is available and how it should be used.
- API mode: An HTTP execution capability able to make the required HTTPS or REST calls must be available.

If required credentials are missing, prompt the user once for them. If they are still unavailable after that prompt, mark the affected test steps as `BLOCKER` once execution begins.

If a required external capability is unavailable, inform the user and halt before execution. Typical prerequisites include:

- Atlassian Jira MCP or another Jira integration capable of reading issues, adding comments, and attaching artifacts
- The `/agent-browser` skill and any required underlying `agent-browser` browser automation tooling for browser tests
- An HTTP client capability for API tests

### 5. Create the Test Plan

Create a manual test plan based only on the task information and direct user answers. The plan should contain:

- The selected test mode
- Any assumptions
- Any warnings about insufficient task detail
- Numbered test steps
- The expected result for each step
- The evidence type to capture for each step, where relevant

Use the following status values when reporting test execution:

- `PASS`
- `FAIL`
- `BLOCKER`

Present the proposed test plan to the user and ask for approval before executing any tests.

### 6. Execute the Approved Test Plan

Once the user approves the plan, execute the tests until the run is complete or blocked.

- Browser mode: Execute the browser flow by following the `/agent-browser` skill instructions, capture screenshots, and record visible errors or console issues where available.
- API mode: Execute the relevant HTTP or REST requests and record the request and response evidence for each meaningful step.

If a test requires data creation or mutation, you may perform controlled changes and clean them up where practical.

If a step fails, continue with later relevant steps unless execution is blocked by missing access, missing credentials, missing tooling, or an earlier failure that makes the remaining steps invalid.

### 7. Record the Evidence

At the end of the run, prepare the evidence package. It must include a test plan summary with a status beside every executed or blocked test step.

The evidence may also include:

- Screenshots
- Console or error logs
- API requests and responses

For Jira tasks:

- Attach the evidence artifacts to the Jira issue where supported.
- Add exactly one comment to the Jira issue titled `Auto QA Report`.
- The comment should summarise the run, list each test step with `PASS`, `FAIL`, or `BLOCKER`, and reference any attached evidence.
- Screenshot evidence can be attached to the Jira issue as attachments

For non-Jira tasks:

- Create a local directory at `TestResults/<task-id>-<test-run-number>`.
- Auto-increment the test run number for the same task ID.
- Write a `summary.md` file containing the `Auto QA Report` content.
- Save any screenshots, logs, and API evidence files in the same directory.

### 8. Finish Cleanly

Tell the user whether the run completed successfully, failed, or ended with blockers.

Highlight:

- Any failed steps
- Any blocked steps
- Any missing capabilities or credentials that reduced coverage
- Any warnings about task quality that could affect confidence in the result
- Any error messages or console logs which could indicate the cause of a failure

Do not commit code changes or modify git history as part of this skill.