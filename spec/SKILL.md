---
name: spec
description: Create a requirements-level project specification or "spec" outlining module design, feature requirements and codebase decisions, then create the spec as a single document. Use when the user wants to create project documentation, write a "spec", or plan a new feature.
argument-hint: Give detailed project requirement information
user-invocable: true
disable-model-invocation: false
---

This skill will be invoked when the user wants to create a project requirements specification. You may skip steps if you don't consider them necessary.

1. Ask the user where they would prefer the document be saved, with suggested options of:
  - `.specs` folder in the root of the repo (recommended)
  - Confluence. If selected, confirm the Confluence location, and verify either MCP or CLI access to Confluence. If no access, inform the user and halt.
  - Github Issues. If selected, verify access via either MCP or CLI. If no access, inform the user and halt.
  - Other. Allow the user to specify where and how they would like the document saved.
2. Ask the user for a detailed description of the problem or feature they wish to develop, and any potential ideas for solutions. Use existing conversation context if available.
3. Explore the repo to verify their assertions and understand the current state of the codebase.
4. If you have not already done so, interview the user about every aspect of this plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.
5. Sketch out the major areas or modules you will need to build or modify to complete the implementation. Actively look for opportunities to improve modularisation and decoupling of the codebase. Check with the user that these modules match their expectations.
6. Once you have a complete understanding of the problem and solution, use the template below to write the document.

<document-template>

## Overview

The problem that the user is facing, from the user's perspective.

### Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As a <user-role>, I want <feature>, so that <benefit>

<user-story-example>
1. As a worker, I want to see my leave balances, so that I can plan my upcoming holiday plans
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Technical Decisions

A list of technical decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Database/schema changes
- API contracts

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Out of Scope

A description of the things that are out of scope for this deliverable.

## Further Notes

Any further notes about the feature.

</document-template>