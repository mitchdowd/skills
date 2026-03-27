---
name: tech-spec
description: Create a technical specification document for a given deliverable. Use this when we need specific technical-level requirements, beyond just user-level requirements.
argument-hint: Give detailed project requirement information
---

This skill will be invoked when the user wants to create a technical specification which covers project requirements. You may skip steps if you don't consider them necessary.

1. Ask the user where they would prefer the document be saved, with suggested options of:
  - `docs` folder in the root of the repo (recommended)
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

The solution to the problem, from a technical perspective.

## Technical Design

A high-level description of any architectural decisions and documentation of affected systems and modules.  Include things such as:

* Changes to key domain entities
* Data model updates
* API endpoint definitions

## Requirements

### Functional Requirements

A LONG, table of functional requirements. The table should have:

* Requirement ID: A unique identifier for the requirement (unique to this document)
* Description: A description of the requirement and a functional level
* Category: A broad categorisation, based on either the domain entity or module, whichever is appropriate.

For example:

> FR-101  The system must lock user account after 10 consecutive failed attempts  Auth

This list of functional requirements should be extremely extensive and cover all aspects of the feature. Each requirement should be atomic, and concretely testable.

### Non-Functional Requirements

A table of non-functional requirements, in the same format as the functional requirements table.

A non-functional requirement is more of a quality attribute than a specific logical requirement for the system. It could be related to things like performance, uptime, maintainability, etc. These are things that act as constraints upon how the functional requirements are delivered.

For example:

> NFR-200  API calls must return in under 500ms  Performance

## Out of Scope

A description of the things that are out of scope for this deliverable.

## Further Notes

Any further notes about the feature.

</document-template>