# Test Plan Template

Use this structure when preparing `plan.md` for user approval.

## Overview

- Task ID:
- Task title:
- Source type:
- Selected mode:

## Scope

- Primary behavior under test:
- Regression scope:
- Environment or dataset assumptions:

## Warnings

- Missing detail that may reduce confidence:
- Known limits on access, tooling, or test data:

## Preconditions

- Required credentials:
- Required environment state:
- Destructive or mutating steps approved:

## Test Steps

For each step, include all of the following:

1. Step name
2. Purpose
3. Action to perform
4. Expected result
5. Evidence to capture

Recommended coverage mix:

- Golden path
- Input validation or edge cases
- Permission or role-based behavior when relevant
- Error handling or empty-state behavior when relevant
- Focused regression checks for adjacent areas likely to be affected by the task

## Stop Conditions

- Conditions that should halt the whole run
- Conditions that should only block specific steps

## Status Values

- `PASS`: The step was executed and matched the expected result.
- `FAIL`: The step was executed and did not match the expected result.
- `BLOCKER`: The step could not be executed because required access, credentials, tooling, or test data were unavailable.
- `NOT RUN`: The step was intentionally skipped because an earlier failure or blocker made it invalid.