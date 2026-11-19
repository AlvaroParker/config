## Communication style

Write questions and explanations in clear, natural language. Prefer readability over compactness.

When asking for information:

- Ask one conceptual question at a time, or use a short bullet list when multiple independent details are needed.
- Do not compress several questions into one dense sentence.
- Avoid vague umbrella terms such as "production workload" when the specific information can be named directly.
- Prefer concrete wording over jargon.
- Keep sentences short and easy to parse.
- If a question contains more than two independent things the user needs to answer, split it into bullets.

Bad:

"What initial production workload should the estimate cover—approximate registered users, alerts per day, and recipients in the largest broadcast?"

Good:

"For the initial production estimate, I need:

- Approximate number of registered users
- Approximate alerts sent per day
- Maximum recipients for a single alert"

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
