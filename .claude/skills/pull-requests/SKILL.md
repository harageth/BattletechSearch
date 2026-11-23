---
name: pull-requests
description: Use when opening, updating or merging a pull request for this repo, or replying to its review comments. Codex reviews the diff before a PR, then Claude models that didn't write it once Codex's limit is hit; don't request a Copilot review (user rules). Covers the order of git/gh commands, the PR body, and merging with a merge commit.
---

# Pull requests

## Opening one

Only when the user asks to commit, push or open a PR. Work happens on a branch off `master`, never on `master` itself.

1. **Get the diff reviewed by Sonnet and Codex (`xhigh`), side by side** (user rule, 2026-11-22, replacing the 2026-11-17 self-review and Codex-first). They find different things: on PR #31 Sonnet found concurrency and screen-reader problems that no Codex setting did, and Codex found UI races Sonnet missed. Start both at once with the same brief; neither sees the other's findings.
   - **Sonnet:** the Agent tool with `model: "sonnet"`, read-only: it may read files and run read-only git commands, and nothing else. If the code was written by Sonnet, use another Claude model that didn't write it (the session's model, or the commits' `Co-Authored-By`); Fable didn't start on 2026-11-22. Check its log is growing after a minute.
   - **Codex:** read-only, with its shell tool off so it sees only what it's sent (why: the codex-reviews memory). Put the brief, `git diff` (new files too) and the changed files with what they depend on in one prompt file in the scratchpad, and from the repo root run `codex exec -p review --disable shell_tool --disable unified_exec -s read-only -c 'approval_policy="never"' - < prompt.txt`. **`-p review` matters:** Codex's default reasoning effort is `none`; the user's `review` profile (`~/.codex/review.config.toml`) sets `xhigh` (about 4 minutes on PR #31). Run it from the repo so it reads `AGENTS.md`. Don't weaken its sandbox or change folder permissions without asking. **Read the output, not the exit code:** a `codex review` that couldn't read anything exited 0. If Codex reports its usage limit, go on with Sonnet and say so in the PR.
   - **The brief:** what changed, what's already decided (from the skills: Codex can't read them), and to trace each finding through the code before reporting it.
   - **Ask for** bugs, server/search-box mismatches, migrations that don't match what the importer writes, wasted work, missing tests and leftover comments.
   - **Check each finding against the code before acting on it** (run its example): on the first review, three of Codex's four were wrong. Fix the real ones. Say in the PR body who reviewed, what was real, and what was dismissed and why.
2. **Run the whole suite:** `./mvnw test` (Java and JS; the build fails on a JS failure). Say in the PR's test plan what ran and what was checked by hand.
   - **When the search box changed:** also `npm run test:browser` (`src/test/browser`), which drives the real box in Chrome. It needs the app running on the full data, on a throwaway Postgres, never the dev database: `docker run --rm -d --name bts-scratch -e POSTGRES_DB=scratch -e POSTGRES_USER=scratch -e POSTGRES_PASSWORD=scratch -p 127.0.0.1:55432:5432 postgres:16`, then the app with `DB_URL=jdbc:postgresql://127.0.0.1:55432/scratch DB_USER=scratch DB_PASSWORD=scratch SERVER_PORT=8090 MANAGEMENT_PORT=8091`, then `BASE_URL=http://localhost:8090 npm run test:browser` (Node 22 or later; Maven's is in `target/node`). Not part of `./mvnw test`.
   - **Fallback reviewer:** use Sonnet. A Fable subagent never started (2026-11-22); check that a reviewer's log grows after a minute.
3. **Commit, push, and open the PR as separate commands.** Auto mode denies them chained into one command.
   - `git add -A`, then check `git status --short` for stray files (scratch output belongs in the scratchpad, not the repo).
   - `git commit`, then `git push -u origin <branch>`.
   - `gh pr create --base master --head <branch> --title ... --body-file -`.
4. **Don't request a Copilot review** (user, 2026-11-17). PRs up to #26 had one; earlier review threads may still need the user to resolve them.

## The PR body

- **Summary:** what a user can now do (a table of example queries works well for search changes), importer or data changes, and anything shipped as a `db/data` migration.
- **Schema changes:** the exact DDL and a diagram of the changed tables and their connected tables, or "No DDL" plus what the data migrations touch (`schema-changes` skill).
- **Known issues** the PR leaves alone, so they aren't mistaken for oversights.
- **Test plan:** a checklist of the test run and the manual checks (scratch-database imports, searches and their counts).
- End with the attribution lines from the session's instructions.

## Review comments

- Posting a reply or resolving a thread speaks for the user on GitHub: show them the reply first and post only once they approve it.
- Resolving threads through the GraphQL `resolveReviewThread` mutation is denied in auto mode. Ask the user to resolve them on GitHub.
- Fixes for review comments go in a new commit on the branch, not an amend.

## Merging

Only when the user says to. Merge with a merge commit (`gh pr merge <n> --merge`), never squash or rebase. Then switch to `master` and pull.
