# Development Workflow and Iteration

## Evaluation-Driven Development

**Create evaluations BEFORE writing extensive documentation.**

This ensures your skill solves real problems rather than documenting imagined ones.

### Step 1: Identify Gaps

Run Claude on representative tasks **without** a skill:

```markdown
## Gap Analysis Template

Task: [Describe the task you tried]

What happened:
- [ ] Claude didn't know about [specific context]
- [ ] Claude used wrong approach for [specific scenario]
- [ ] Claude missed [important constraint]

What Claude needed:
- [Specific information or guidance]
```

### Step 2: Create Evaluations

Build 3+ test scenarios that exercise identified gaps:

```json
{
  "skills": ["my-skill"],
  "query": "Extract all text from this PDF",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Uses appropriate PDF library",
    "Extracts text from all pages",
    "Saves output in readable format"
  ]
}
```

### Step 3: Establish Baseline

Document Claude's performance without the skill:

| Scenario | Without Skill | Target |
|----------|--------------|--------|
| Basic extraction | 60% success | 95% |
| Form filling | 30% success | 90% |
| Complex layout | 10% success | 80% |

### Step 4: Write Minimal Instructions

Create just enough content to pass evaluations:

```markdown
---
name: my-skill
description: [What + When]
---

# [Title]

## Quick Start
[Minimal working example - just enough to address gaps]

## Key Constraints
[Only constraints that Claude missed in testing]
```

### Step 5: Iterate Based on Results

```
Run evaluation → Identify failures → Refine skill → Repeat
```

## Two-Claude Development Pattern

Work with one Claude instance ("Claude A") to create skills for another ("Claude B"):

### Creating New Skills

```
┌─────────────────────────────────────────────┐
│ 1. Complete task with Claude A (no skill)   │
│    - Notice what context you provide        │
│    - Document repeated explanations         │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 2. Ask Claude A to create skill             │
│    "Create a skill that captures the        │
│    [context/pattern] we just used"          │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 3. Review for conciseness                   │
│    "Remove explanation of X - Claude knows" │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 4. Test with Claude B (fresh instance)      │
│    - Does it find the right information?    │
│    - Does it apply rules correctly?         │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 5. Return to Claude A with observations     │
│    "Claude B forgot to filter by date..."   │
└─────────────────────────────────────────────┘
```

### Iterating Existing Skills

1. **Use skill in real workflows** with Claude B
2. **Observe behavior**: Where does it struggle?
3. **Return to Claude A**: "When I asked for X, Claude B did Y"
4. **Review suggestions**: Reorganize? Strengthen language?
5. **Apply and test**: Update skill, test again
6. **Repeat** as new scenarios emerge

## Workflow Patterns for Skills

### Simple Workflow (No Validation)

For low-risk, reversible operations:

```markdown
## Usage

1. Prepare input files
2. Run the operation
3. Review output
```

### Validated Workflow (Recommended)

For operations that benefit from verification:

````markdown
## Workflow

Copy this checklist:

```
Progress:
- [ ] Step 1: Analyze input
- [ ] Step 2: Create plan
- [ ] Step 3: Validate plan
- [ ] Step 4: Execute
- [ ] Step 5: Verify output
```

### Step 1: Analyze Input
[Instructions]

### Step 2: Create Plan
[Instructions]

### Step 3: Validate Plan
Run: `python scripts/validate.py plan.json`

**If validation fails**: Fix issues and repeat Step 3

### Step 4: Execute
[Instructions - only proceed after validation passes]

### Step 5: Verify Output
[Instructions]
````

### Feedback Loop Pattern

For quality-critical operations:

```markdown
## Process

1. Generate initial output
2. **Validate**: Run checker against output
3. **If errors found**:
   - Review error messages
   - Fix issues
   - Return to step 2
4. **Only proceed when validation passes**
5. Finalize output
```

## Testing Across Models

Skills work differently across Claude models. Test with all models you plan to use:

| Model | Testing Focus |
|-------|---------------|
| **Haiku** | Does skill provide enough guidance? |
| **Sonnet** | Is skill clear and efficient? |
| **Opus** | Does skill avoid over-explaining? |

### Model-Specific Adjustments

If skill works for Opus but not Haiku:
- Add more explicit step-by-step guidance
- Include more examples
- Reduce assumed knowledge

If skill works for Haiku but is verbose for Opus:
- Use conditional sections
- Put detailed explanations in reference files

## Observing Claude's Navigation

Watch how Claude actually uses the skill:

### Signs of Good Structure

- Claude reads SKILL.md, then relevant reference file
- Claude finds needed information quickly
- Claude follows workflows in order

### Signs of Problems

| Observation | Possible Issue | Fix |
|-------------|---------------|-----|
| Reads files in unexpected order | Structure not intuitive | Reorganize navigation |
| Misses important references | Links not prominent | Make links more visible |
| Repeatedly reads same file | Content should be in SKILL.md | Move to main file |
| Never accesses a file | File unnecessary or poorly signaled | Remove or improve reference |

## Common Iteration Patterns

### Pattern: Missing Context

**Observation**: Claude doesn't know about [X]
**Fix**: Add [X] to relevant section

### Pattern: Wrong Approach

**Observation**: Claude uses [wrong method] instead of [right method]
**Fix**: Make correct approach more prominent, add anti-pattern warning

### Pattern: Skipped Steps

**Observation**: Claude skips [critical step]
**Fix**: Add validation checkpoint, make step non-optional

### Pattern: Over-Explanation

**Observation**: Claude spends tokens explaining obvious things
**Fix**: Remove explanation, assume Claude's intelligence

## Team Feedback Integration

When sharing skills with teammates:

1. **Collect observations**:
   - Does skill activate when expected?
   - Are instructions clear?
   - What's missing?

2. **Identify patterns**:
   - Common confusion points
   - Frequently needed additions
   - Unused sections

3. **Incorporate feedback**:
   - Address blind spots
   - Simplify confusing sections
   - Remove unused content
