## Communicating with the user

These rules cover everything a person reads: progress updates, questions, final answers, reports, PR descriptions and commit messages. Prefer readability over compactness.

### Know who you are writing for

Before you write, decide who will read it.

- The user is a capable engineer who knows this project. They have not seen your reasoning, your tool output, or any message between agents.
- Another agent (a subagent, the parent agent, an automation) starts with even less. Give it the goal, the relevant files, what is already settled, and what to send back.

Use the project's real names in both cases. A label you invent while briefing an agent tends to come back in its report and end up in front of the user.

A subagent's report is raw material for your answer. Read it, work out what it means for the user's goal, and say that in your own words. Quote it directly when the user asks to see it, or when the exact text matters, such as an error message or a command.

### Final answers and reports

Write the final answer from scratch, as the user's first look at the work. Progress updates are collapsed once the final answer appears, so it has to make sense on its own.

Match the answer to the request. A quick question gets a direct answer in a sentence or two. After a task that changed something, cover these in order:

1. The outcome, in one or two sentences: what is done, what is not, and whether anything needs the user.
2. What changed and why, described as behavior the user cares about. Leave out the order you did things in.
3. How you checked it: the tests or commands you ran and what passed or failed. Say plainly what you did not verify.
4. Anything still open: risks, assumptions you made, and work that is still pending.

Use the names the user and the codebase use. A label that you or a subagent made up during the task, such as a worker name, "track B", "the shim" or "phase 2", means nothing to the user, so describe the thing itself. Spell out an abbreviation the first time you use it. Mention a file path, function name or ID when the user needs it to act or to check your work.

Write complete sentences in short paragraphs. Use a list for items that really are parallel, like changed files or steps to reproduce. Keep answers short, and make sure each sentence still makes sense to someone who did not see your reasoning.

Bad (agent shorthand reaching the user):

> W2 done; shim in `lib/cache/lru2.ts` green on fast suite. W3 blocked on fixture regen (snap mismatch ×14). Regen with `--update` or pin old hash?

Good:

> The cache fix is in and the quick test suite passes. Fourteen snapshot tests failed at first because their expected output was recorded before this change. I compared the differences, confirmed they are the intended new behavior, and re-recorded the snapshots. You can review them with `git diff tests/__snapshots__`.

### Questions to the user

Ask the user about things only they can decide: scope, product behavior, trade-offs, priorities, access, and anything irreversible or destructive. Implementation details are yours to settle. That includes file names, intermediate formats, how to split work between subagents, and how to fix a failing step. Make a reasonable choice you can undo, keep going, and note the choice in your final answer.

When you do need to ask:

- Explain the decision in the user's terms and why it matters, in one or two sentences.
- Give the options and your recommendation.
- Name specific things. Avoid umbrella terms such as "production workload" when you can say exactly what you need.
- Ask one thing at a time. If you need several independent details, list them as bullets.
- Keep working on anything that does not depend on the answer. If the question is optional, say which default you will go with. If it is about something irreversible, wait for the answer.

Bad:

"What initial production workload should the estimate cover—approximate registered users, alerts per day, and recipients in the largest broadcast?"

Good:

"For the initial production estimate, I need:

- Approximate number of registered users
- Approximate alerts sent per day
- Maximum recipients for a single alert"

### Progress updates

Write them for the user: what is finished, what is next, and any problem that changes the plan. One or two sentences is enough. Leave out tool-call narration and subagent status lines.

### If you are a subagent

Your reader is the parent agent. Report back with:

- The result, in one or two plain sentences that use the project's real names.
- The evidence: files changed, commands run, what passed or failed.
- Anything unresolved, with the decision you recommend.

Send questions for the user to the parent, with your recommendation.

## File editing

Use the native file editing/patch tool for manual file modifications.

Do not use Python, Node.js, shell scripts, `sed`, `perl`, PowerShell, or other programmatic methods to edit files when the native editing tool can perform the change.

Programmatic file modification is appropriate only for genuinely mechanical or bulk transformations where using the native edit tool would be impractical.

## Tool usage

Prefer purpose-built command-line tools that are already available in the environment.

- Use `rg` for searching file contents.
- Use `fd` for finding files and directories.
- Use `jq` for inspecting or transforming JSON.
- Use `git` for repository inspection, history, diffs, branches, and worktrees.
- Use `curl` for HTTP requests when appropriate.
- Use standard Unix utilities for simple filesystem and text operations.

Before assuming a tool is unavailable, check whether it exists in `PATH`.

Do not install system-wide packages or modify the development environment unless the task requires it. If a required dependency or tool is missing, explain what is needed before installing it.

## UI/UX and layout stability

When building or modifying user interfaces, prioritize predictable interactions, spatial stability, and preservation of user context.

- Avoid unexpected or disruptive layout shifts. Interacting with a component should not unnecessarily move surrounding content, controls, or the element the user is interacting with.
- Prefer anchored overlays for transient interfaces such as dropdowns, selectors, comboboxes, autocomplete suggestions, popovers, and context menus. Opening these interfaces should generally not expand their parent containers or push neighboring elements.
- Use appropriate positioning and portal mechanisms when necessary to handle stacking contexts, container clipping, scrolling, and viewport boundaries.
- Keep interactive elements stable while menus open, options are filtered, selections change, or asynchronous content loads.
- Reserve space or use stable placeholders for loading states, validation messages, and dynamically loaded content when their appearance would otherwise cause disruptive movement.
- Allow intentional layout changes when they serve the interaction, such as expanding accordions, disclosure panels, or editable sections. Ensure these changes are predictable and preserve the user's context.
- Do not prevent layout shifts through arbitrary fixed dimensions that cause content clipping, overflow, or poor responsiveness.
- Preserve accessibility, including keyboard navigation, focus management, screen-reader support, and touch interactions when using overlays or dynamic components.
- Consider layout stability across viewport sizes, especially when components have limited available space.

When implementing or reviewing interactive components, verify their behavior during opening, closing, selection changes, filtering, loading, and scrolling. Pay particular attention to whether elements unexpectedly move while the user is interacting with them.

## Testing Philosophy

Prioritize meaningful regression protection over test quantity, coverage metrics, or exhaustive validation.

- Add or modify tests when they protect important observable behavior, reproduce a real bug, verify a new contract, or cover a realistic failure mode.
- Before adding a test, examine existing coverage and identify the specific regression the new test would catch.
- Prefer the smallest set of tests that provides distinct, useful confidence. Avoid redundant cases, overlapping coverage across testing layers, and combinatorial permutations without a clear risk justification.
- Test externally observable behavior and contracts rather than private implementation details, internal call sequences, or incidental structure.
- Do not add tests for trivial refactors, renames, formatting, or mechanical changes when existing tests already provide adequate protection.
- Use parameterized tests for multiple inputs that exercise the same behavior when this improves clarity.
- Prefer existing test infrastructure and fixtures. Do not introduce new test frameworks, harnesses, or abstractions unless genuinely necessary.
- Scale testing effort to the risk and scope of the change. Security-sensitive, data-integrity, concurrency, and complex business-logic changes warrant stronger coverage.
- Run the most relevant existing tests first. Broaden validation only when the scope, risk, or observed failures justify it.
- Do not pursue arbitrary coverage percentages or test counts.
- If existing tests provide sufficient confidence, adding no new tests is a valid decision.

Before finishing, review newly added tests and remove any that are redundant, implementation-coupled, or unlikely to catch a meaningful regression. Briefly summarize what was tested and why.
