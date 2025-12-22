---
name: authoring-skills
description: Guides the creation of effective Claude Agent Skills. Use when creating new skills, improving existing skills, or reviewing skill quality. Covers naming conventions, file structure, progressive disclosure, and evaluation-driven development.
---

# Claude Skills Authoring Guide

## Overview

This skill provides best practices for creating effective Claude Agent Skills that are discoverable, concise, and well-tested.

## When to Use

- **Creating new skills**: Before writing a new SKILL.md
- **Improving existing skills**: When refactoring or enhancing skills
- **Reviewing skill quality**: For code review of skill files
- **Learning skill authoring**: Understanding the skill architecture

## Core Principles

### 1. Concise is Key

The context window is a shared resource. Challenge each piece of information:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

**Default assumption**: Claude is already very smart. Only add context Claude doesn't already have.

### 2. Progressive Disclosure

SKILL.md serves as an overview that points to detailed materials as needed:
- Keep SKILL.md body under **500 lines**
- Split content into separate files when approaching this limit
- Claude loads additional files only when needed

### 3. Appropriate Degrees of Freedom

Match specificity to task fragility:

| Freedom Level | Use When | Example |
|--------------|----------|---------|
| **High** (text instructions) | Multiple approaches valid | Code review guidelines |
| **Medium** (pseudocode) | Preferred pattern exists | Report templates |
| **Low** (specific scripts) | Operations are fragile | Database migrations |

## Quick Reference

### YAML Frontmatter Requirements

```yaml
---
name: skill-name        # lowercase, hyphens, max 64 chars
description: Describes what it does and when to use it.  # max 1024 chars
---
```

**Naming convention**: Use gerund form (verb + -ing)
- Good: `processing-pdfs`, `analyzing-data`, `testing-code`
- Avoid: `helper`, `utils`, `tools`

**Description rules**:
- Always write in **third person**
- Include what the skill does AND when to use it
- Be specific and include key terms for discovery

See [NAMING.md](NAMING.md) for detailed naming guidelines.

### File Structure

```
my-skill/
├── SKILL.md              # Main instructions (loaded when triggered)
├── REFERENCE.md          # API reference (loaded as needed)
├── EXAMPLES.md           # Usage examples (loaded as needed)
└── scripts/
    └── utility.py        # Executed, not loaded into context
```

See [STRUCTURE.md](STRUCTURE.md) for progressive disclosure patterns.

## Skill Creation Workflow

### Step 1: Identify the Gap

Before writing documentation, identify what Claude struggles with:
1. Run Claude on representative tasks without a skill
2. Document specific failures or missing context
3. Create 3+ evaluation scenarios

### Step 2: Write Minimal Instructions

Create just enough content to address the gaps:
```markdown
---
name: my-skill
description: [What it does]. Use when [trigger conditions].
---

# [Skill Title]

## Quick Start
[Minimal working example]

## Advanced Features
See [REFERENCE.md](REFERENCE.md) for details.
```

### Step 3: Test and Iterate

1. Test with real usage scenarios
2. Observe Claude's navigation patterns
3. Refine based on failures

See [WORKFLOWS.md](WORKFLOWS.md) for detailed development workflow.

## Common Patterns

### Template Pattern

Provide output format templates:

````markdown
## Report Structure

Use this template:

```markdown
# [Title]

## Summary
[One-paragraph overview]

## Key Findings
- Finding 1
- Finding 2
```
````

### Examples Pattern

Show input/output pairs:

````markdown
## Commit Message Format

**Input**: Added user authentication
**Output**:
```
feat(auth): implement authentication

Add login endpoint and token validation
```
````

### Conditional Workflow Pattern

Guide through decision points:

```markdown
## Workflow

1. Determine task type:
   - **Creating new?** → See "Creation workflow"
   - **Editing existing?** → See "Editing workflow"
```

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Too verbose | Wastes context tokens | Assume Claude's intelligence |
| Time-sensitive info | Becomes outdated | Use "old patterns" section |
| Inconsistent terms | Confuses Claude | Pick one term, use consistently |
| Too many options | Decision paralysis | Provide default with escape hatch |
| Deep nesting | Partial file reads | Keep references one level deep |
| Windows paths | Cross-platform errors | Use forward slashes only |

## Detailed Documentation

- **[NAMING.md](NAMING.md)**: Naming conventions and description guidelines
- **[STRUCTURE.md](STRUCTURE.md)**: File organization and progressive disclosure
- **[WORKFLOWS.md](WORKFLOWS.md)**: Development workflow and iteration
- **[CHECKLIST.md](CHECKLIST.md)**: Quality checklist before sharing

## Related Skills

- **writing-technical-docs**: General documentation principles
- **applying-solid-principles**: Code quality for utility scripts
