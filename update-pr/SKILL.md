---
name: update-pr
description: Updates a pull request according to feedback. Use when asked to address pull request feedback.
argument-hint: Specify the pull request and any (optional) extra feedback
user-invocable: true
disable-model-invocation: false
---

Check the specified pull request for comments and feedback, as well as any extra specified feedback I have given you.

First, make sure you have checked out the correct branch for the pull request, and that you have the latest changes from the remote repository. Then, for each piece of feedback:

For each piece of feedback:
1. Determine if the feedback is valid, or should be challenged
2. If the feedback is valid, action the feedback with any necessary code changes, and leave a reply to the pull request comment describing the change you have made
3. If the feedback is invalid, leave a reply to the pull request comment with your counter-argument or any clarifying questions you might have
4. If the feedback came from this context instead of a pull request comment, action as above except leave your reply in the conversation instead of the pull request comment

Continue this process until you have addressed all feedback, and there are no outstanding comments on the pull request. If you have any questions or need clarification on any feedback, ask for it in the pull request comments.

Note that you should never just assume all feedback is valid.  It should be assessed on its merits on a case by case basis, and you should not be afraid to challenge feedback you think is incorrect or misguided.

Ensure tests, linting and build are passing locally, then commit your changes and push to update the pull request.
