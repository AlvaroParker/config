## Communication style

Write questions and explanations in clear, natural language. Prefer readability over compactness.

When asking for information:

- Ask one conceptual question at a time. If a question contains more than two independent things the user needs to answer, split it into bullets instead of compressing them into one dense sentence.
- Avoid vague umbrella terms such as "production workload" when the specific information can be named directly.
- Prefer concrete wording over jargon.
- Keep sentences short and easy to parse.

Bad:

"What initial production workload should the estimate cover—approximate registered users, alerts per day, and recipients in the largest broadcast?"

Good:

"For the initial production estimate, I need:

- Approximate number of registered users
- Approximate alerts sent per day
- Maximum recipients for a single alert"

## File editing

Make file changes with the file editing tool, not with `sed -i`, `perl -pi`, inline Python or Node scripts, or heredoc redirects. Tool edits show a reviewable diff and can be undone with rewind. Shell edits often cannot.

Scripted edits are fine for mechanical bulk changes, such as a rename across many files.

## Tool usage

`rg`, `fd`, and `jq` are installed. Use `rg` instead of `grep` and `fd` instead of `find`, including for quick one-off searches.

Before assuming another tool is unavailable, check whether it exists in `PATH`.

Do not install system-wide packages or modify the development environment unless the task requires it. If a tool is missing, explain what is needed before installing it.

## UI/UX and layout stability

When building or changing UI, keep the layout stable while the user interacts. Dropdowns, comboboxes, popovers, and menus should overlay the page. They should not push neighboring content or resize their parent. Use anchored positioning or a portal when clipping or stacking gets in the way. Reserve space for loading states and validation messages that would otherwise shift content.

Expanding accordions and disclosure panels are fine, because the movement is the point. Do not get stability from fixed sizes that clip content or break small screens. Keep keyboard, focus, and screen-reader behavior working.

Before finishing an interactive component, check it while opening, closing, filtering, loading, and scrolling. Look for anything that moves under the user.

## Testing philosophy

Tests exist to catch regressions in behavior that matters, not to raise test counts or coverage numbers.

- Add or change a test when it protects important observable behavior, reproduces a real bug, or pins a new contract. First check existing coverage and name the regression the test would catch. If existing tests already cover the change, adding none is a valid outcome.
- Test observable behavior and contracts, not private implementation details.
- Keep the set small. Avoid redundant cases and permutations without a specific risk. Use parameterized tests when inputs exercise the same behavior.
- Scale with risk. Security, data-integrity, concurrency, and complex business-logic changes warrant stronger coverage.
- Use the project's existing test framework and fixtures.
- Verify your work however you like, but do not turn scratch scripts or one-off checks into permanent test files.
- Run the most relevant existing tests first. Broaden only when scope, risk, or failures justify it.

Before finishing, remove any new test that is redundant or coupled to the implementation. When you added or changed tests, say briefly what they cover and why.
