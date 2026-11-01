---
name: pull-requests
description: Use when opening, updating or merging a pull request for this repo, or replying to its review comments. Always request a Copilot review when opening a PR (user rule). Covers the order of git/gh commands, the PR body, and merging with a merge commit.
---

# Pull requests

## Opening one

Only when the user asks to commit, push or open a PR. Work happens on a branch off `master`, never on `master` itself.

1. **Run the whole suite first:** `./mvnw test` (Java and JS; the build fails on a JS failure). Say in the PR's test plan what ran and what was checked by hand.
2. **Commit, push, and open the PR as separate commands.** Auto mode denies them chained into one command.
   - `git add -A`, then check `git status --short` for stray files (scratch output belongs in the scratchpad, not the repo).
   - `git commit`, then `git push -u origin <branch>`.
   - `gh pr create --base master --head <branch> --title ... --body-file -`.
3. **Always request a Copilot review** (user rule, 2026-10-31). It isn't automatic on this repo:
   ```
   gh pr edit <number> --add-reviewer @copilot
   ```
   - `gh pr view --json reviewRequests` and `pulls/<n>/requested_reviewers` don't list Copilot. To check the request went through, look at the timeline:
     ```
     gh api repos/harageth/BattletechSearch/issues/<n>/timeline --jq '.[] | select(.event=="review_requested") | .requested_reviewer.login'
     ```
     It should print `Copilot`.

## The PR body

- **Summary:** what a user can now do (a table of example queries works well for search changes), importer or data changes, and anything shipped as a `db/data` migration.
- **Known issues** the PR leaves alone, so they aren't mistaken for oversights.
- **Test plan:** a checklist of the test run and the manual checks (scratch-database imports, searches and their counts).
- End with the attribution lines from the session's instructions.

## Review comments

- Posting a reply or resolving a thread speaks for the user on GitHub: show them the reply first and post only once they approve it.
- Resolving threads through the GraphQL `resolveReviewThread` mutation is denied in auto mode. Ask the user to resolve them on GitHub.
- Fixes for review comments go in a new commit on the branch, not an amend.

## Merging

Only when the user says to. Merge with a merge commit (`gh pr merge <n> --merge`), never squash or rebase. Then switch to `master` and pull.
