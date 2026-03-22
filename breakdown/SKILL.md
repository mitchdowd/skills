---
name: breakdown
description: Break down a requirements document into individually executable Jira tasks, ready for execution. Use when the user wants to break down a document or feature into individual tasks.
argument-hint: Provide requirements documentation to break into tasks
user-invocable: true
disable-model-invocation: false
---

Break a requirements document into individually executab le Jira tasks.

### 1. Verify Access

Verify that you have Jira access via either Atlassian's MCP or CLI. If you do not, inform the user and halt.

### 2. Locate the Documentation

Ask the user for a link to the document to break down into tasks. If it is not already in your context window, fetch the document.

### 3. Explore the Codebase (Optional)

Explore the codebase to understand the current state of the code.

Skip this if you have already explored the codebase.

### 4. Task Breakdown

Break the document into individually executable tasks. Each task should be either:
- A thin vertical slice of work accomplishing a technical outcome. For example, an API call including adding the endpoint, implementing required business logic, and linking to the data layer. Prefer many thin slices over individual large ones where possible.
- A foundational technical requirement, such as a module creation, establishing a build pipeline or setting up infrastructure.
- A complex logic deep dive, which elaborates more complex functionality separately to allow other vertical slices to remain "thin".

Separate tasks should *not* be created for testing, verification or deployment activities. These are implied in all tasks by default.

### 5. Clarification

Clarify the breakdown with the user. Present the tasks as a numbered list. For each task, show:

- *Title*: A short descriptive name
- *Blockers*: A list of tasks blocked by this task
- *User Stories*: Which user stories are addressed by the task

Ask the user if the breakdown feels right. Should any tasks be merged or split? Are there any apparent gaps in the task breakdown?

Iterate until the user approves the proposed breakdown.

### 6. Create Jira Tasks

Check with the user which Jira Space and Epic to create the work under. Recommend a newly-created Epic, but allow the user to specify an existing Epic.

Then, for each approved task, create a Jira task in the given Jira Space with the nominated parent Epic. Each task should have:

- The task title (do not prefix with any sort of ID or code)
- A description of the work to be done
- A dot-point list of acceptance criteria
- A horizontal line at the bottom of the description, followed by a disclaimer stating that the task is AI generated based off requirements from <document-url>.

Specify blockers as linked Jira items, not as notes in the task description. The blocker should be created as a "blocks" link on the blocker itself (not on the "blocked" task).

Do *not* specify story points, priority labels, assignees or dates on the tasks.

### 7. Output Result

Output a link to the Jira Epic to the user for them to enter to see the results.
