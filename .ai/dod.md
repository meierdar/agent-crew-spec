# Definition of Done

Every story must satisfy both sections before it can be marked `done`.

## Automated Checks (Agent Self-Verify)

The agent MUST verify these before declaring work complete:

- [ ] Code compiles / builds without errors
- [ ] All existing tests still pass (no regressions)
- [ ] New tests written for new functionality
- [ ] Linter passes with zero warnings (project linter config applies)
- [ ] No `// TODO`, `// FIXME`, or `// HACK` without a story reference
- [ ] No hardcoded secrets, API keys, or credentials
- [ ] No unrelated changes (stay within story scope)

### Executable DoD

Add a `verify-always` block below to make these checks runnable via
`ai-verify`. These run after every story regardless of content.
Role-specific checks go in the role file under `.ai/roles/`.

<!-- To enable, add a verify-always block like this:

    ```verify-always
    RUN npm run build
    RUN npm test
    RUN npm run lint
    GREP_FAIL src/ "(api_key|secret_key|password)\s*=\s*['\"]"
    FILE_NOT_EXISTS .env
    FILE_NOT_EXISTS .env.local
    ```
-->

## Manual Checks (Human Operator Review)

The human operator verifies these during review:

- [ ] Acceptance criteria from the story are met
- [ ] Code is readable and follows project conventions
- [ ] No unnecessary complexity introduced
- [ ] Documentation updated if public API or behavior changed
- [ ] Edge cases considered

## Project-Specific Additions

<!-- Add project-specific DoD items here, e.g.: -->
<!-- - [ ] Supabase RLS policies tested -->
<!-- - [ ] Flutter widget tests include golden tests -->
<!-- - [ ] API endpoints documented in OpenAPI spec -->
