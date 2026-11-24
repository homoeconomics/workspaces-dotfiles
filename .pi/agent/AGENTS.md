# Project Guidelines

## Worktrees

**Never** make changes directly in a repo checkout. Before making any changes, use herdr to create a worktree and do all the work there:

```
herdr worktree create --branch <branch-name>
```

The checkout path is in the JSON output under `result.worktree.path` (e.g. `~/.herdr/worktrees/<repo>/<branch>`). `cd` into it before making changes.

## Git Branch Naming

When creating a new git branch, use the format:

```
daniel.zhou/<JIRA-ticket-ID>-<branch-name>
```

Example: `daniel.zhou/CWS-6211-signature-update`

## Pull Request

1. When creating a PR, you **may** include a flowchart or a sequence diagram in the PR description to help reviewers understand the changes. You can use Mermaid or other tools supported by GitHub.
1. **Always** follow the PR template if there is one.
1. **Never** commit PROMPT.md, PLAN.md, or similar working-document .md files that you use to communicate with me while working on the PR. Instead, you **may** include them in the PR description and hide them by default.
1. After publishing a new PR, **always** make sure CI passes. Watch the checks (e.g. `gh pr checks <PR-number> --watch`). If a check fails, investigate the cause, push a fix, and repeat until all checks are green. Don't consider the PR done while CI is failing or still running.

## Code Style

1. Prefer short functions with a unique purpose. If a function does more than one thing (e.g. both validation and data transformation) or is too long (60+ lines), extract some logic into smaller functions. This applies to both existing and new functions.
1. **Do NOT add comments gratuitously.** Only add comments to explain surprising or **NON-OBVIOUS** intent behind a block of code. Prefer self-documenting code (clear variable names, well-named functions, simple logic) over explanatory comments.
