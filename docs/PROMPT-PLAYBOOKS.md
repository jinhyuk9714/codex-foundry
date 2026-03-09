# Prompt Playbooks

Use these playbooks when you want copy-paste prompts instead of translating the kit into your own wording. Paste the blocks one at a time and let Codex answer before you move to the next block.

If you have already applied a stack overlay from [Stack Profiles](STACK-PROFILES.md), tell Codex to use `docs/STACK-PROFILE.md` while you follow the same flow.

## Bootstrap Playbook

Use this when you just created a repo from the template or finished injecting `codex-foundry` into an existing repository. The goal is to confirm the repo-local setup before you ask Codex to build or fix anything.

Copy and run the setup entrypoint first:

```text
$codex-setup-check
This repository is using codex-foundry. Confirm the repo-local setup and tell me what to verify next.
```

Then run the executable doctor:

```bash
bash scripts/codex-doctor.sh
```

PowerShell works too:

```powershell
pwsh -File scripts/codex-doctor.ps1
```

Expected Codex response direction:
- confirms the required repo-local files are in place
- points at the next useful command, such as `/status`, `/debug-config`, or `/mcp`
- tells you whether to continue with the feature or bugfix flow

Next steps:
- If the repo is ready, continue with [Feature Playbook](#feature-playbook) or [Bugfix Playbook](#bugfix-playbook).
- If the doctor warns about config or MCP, fix that first and run it again.

Common mistakes to avoid:
- Asking Codex to build features before running `$codex-setup-check`.
- Editing `.codex/config.toml` blindly before the doctor tells you what is wrong.
- Ignoring a `FAIL` line and moving on anyway.

## Feature Playbook

Use this when you are adding a new capability and want Codex to stay on the default design-first path with `feature-design`, `implementation-plan`, and `tdd-implement`. Paste the blocks in order.

Start with the design request:

```text
$feature-design
I want to add <feature>. Constraints: <key constraints>. Success means <user-visible outcome>.
```

After the design is approved, ask for the implementation plan:

```text
$implementation-plan
Turn the approved design for <feature> into a decision-complete implementation plan.
```

Then start the implementation path:

```text
$tdd-implement
Implement the approved plan for <feature> with a strict red-green-refactor flow.
```

Review and verify before you treat the work as finished:

```text
$request-code-review
Review the completed <feature> work for bugs, regressions, and missing coverage.
```

```text
$verification-gate
Run the commands that prove <feature> is complete and show the results.
```

```text
$finish-branch
Summarize the finished <feature> change, remaining risks, and the next integration step.
```

Expected Codex response direction:
- turns the feature idea into an approved design before implementation
- gives you a concrete plan instead of jumping straight to code
- implements through tests, then reviews risks, then runs fresh verification commands

Next steps:
- Narrow the feature description if the design comes back too broad.
- Keep the same `<feature>` wording across the whole flow so the context stays stable.

Common mistakes to avoid:
- Starting with “just implement it” instead of using `feature-design`.
- Combining multiple unrelated features into one request.
- Skipping `request-code-review` or `verification-gate` because the code already looks right.

## Bugfix Playbook

Use this when behavior is broken, flaky, or unclear. The point is to make Codex use `systematic-debug` to reproduce the problem before it changes code.

Start with the bug report:

```text
$systematic-debug
The bug is: <symptom>. Expected behavior: <expected result>. How to reproduce: <steps or failing command>.
```

Once the bug is reproduced, move into the fix path:

```text
$tdd-implement
Add the regression test for <bug>, watch it fail for the right reason, then implement the fix.
```

Review and verify after the fix:

```text
$request-code-review
Review the <bug> fix for root-cause coverage, regressions, and missing tests.
```

```text
$verification-gate
Run the commands that prove the <bug> fix works and show the results.
```

```text
$finish-branch
Summarize the <bug> fix, remaining risks, and the next integration step.
```

Expected Codex response direction:
- reproduces the bug before proposing a fix
- adds the regression test before production code changes
- re-runs the exact verification commands that prove the fix worked

Next steps:
- If the reproduction is vague, add a failing command, stack trace, or input example.
- If the fix reveals a wider problem, split the first bugfix from the follow-up cleanup.

Common mistakes to avoid:
- Starting with the fix you think is right instead of the symptom you observed.
- Treating a flaky issue as “probably fixed” without a reproducible check.
- Skipping the final verification pass after the code change.
