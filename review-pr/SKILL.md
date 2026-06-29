---
name: review-pr
description: Reviews a pull request and provides constructive feedback
argument-hint: Specify the pull request
user-invocable: true
disable-model-invocation: false
---

You are to do a comprehensive code review on the requested pull request. If no pull request is explicitly specified in the command, and it cannot be easily inferred from current context, then prompt the user for the pull request to review.

With the pull request identified, do a full code review. You may check out the branch if it helps. The code review should go beyond just syntactic checking, but should also look for opportunities for improvement with regards to structure and architecture (think "SOLID principle" refactors).

Unless otherwise specified, all feedback and suggestions should be posted as inline review comments on the pull request, at the appropriate file/line locations.

When leaving comments, include a "Reviewed by <agent-name>" footnote in the comment, so it is clear that this was an agent-driven review.
