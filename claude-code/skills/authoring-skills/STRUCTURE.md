# File Structure and Progressive Disclosure

## How Skills are Loaded

Understanding the loading mechanism helps you structure skills efficiently:

1. **At startup**: Only `name` and `description` from all skills are pre-loaded
2. **When triggered**: Claude reads SKILL.md
3. **As needed**: Claude reads additional referenced files
4. **Script execution**: Scripts are executed, not loaded into context

This means large reference files have **zero context cost** until actually read.

## Recommended Directory Structure

### Simple Skill (Single File)

For straightforward skills under 200 lines:

```
my-skill/
└── SKILL.md
```

### Standard Skill (Multiple Files)

For skills with detailed documentation:

```
my-skill/
├── SKILL.md              # Overview and quick start (~100-300 lines)
├── REFERENCE.md          # API reference / detailed docs
├── EXAMPLES.md           # Usage examples
└── ANTI-PATTERNS.md      # Common mistakes to avoid
```

### Complex Skill (Domain-Organized)

For skills covering multiple domains:

```
bigquery-skill/
├── SKILL.md              # Overview with navigation
└── reference/
    ├── finance.md        # Revenue, billing metrics
    ├── sales.md          # Pipeline, opportunities
    ├── product.md        # API usage, features
    └── marketing.md      # Campaigns, attribution
```

### Skill with Scripts

For skills that include utility scripts:

```
pdf-processing/
├── SKILL.md              # Instructions and workflow
├── FORMS.md              # Form-filling guide
├── REFERENCE.md          # API reference
└── scripts/
    ├── analyze_form.py   # Extract form fields
    ├── fill_form.py      # Fill form values
    └── validate.py       # Validate output
```

## Progressive Disclosure Patterns

### Pattern 1: High-Level Guide with References

SKILL.md provides overview, links to details:

````markdown
# PDF Processing

## Quick Start

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced Features

- **Form filling**: See [FORMS.md](FORMS.md)
- **API reference**: See [REFERENCE.md](REFERENCE.md)
- **Examples**: See [EXAMPLES.md](EXAMPLES.md)
````

### Pattern 2: Domain-Specific Organization

Navigate users to relevant domain files:

````markdown
# BigQuery Analysis

## Available Datasets

| Domain | Description | Reference |
|--------|-------------|-----------|
| Finance | Revenue, ARR, billing | [finance.md](reference/finance.md) |
| Sales | Opportunities, pipeline | [reference/sales.md](reference/sales.md) |
| Product | API usage, features | [reference/product.md](reference/product.md) |

## Quick Search

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
```
````

### Pattern 3: Conditional Details

Basic content inline, advanced in separate files:

```markdown
# Document Processing

## Creating Documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing Documents

For simple edits, modify XML directly.

- **For tracked changes**: See [REDLINING.md](REDLINING.md)
- **For OOXML details**: See [OOXML.md](OOXML.md)
```

## Reference File Best Practices

### Keep References One Level Deep

Claude may partially read deeply nested files. Keep all references directly accessible from SKILL.md.

```
# Bad - Too deep
SKILL.md → advanced.md → details.md → actual-info.md

# Good - One level
SKILL.md → advanced.md
SKILL.md → reference.md
SKILL.md → examples.md
```

### Add Table of Contents for Long Files

For files over 100 lines, include a TOC at the top:

```markdown
# API Reference

## Contents

- [Authentication](#authentication)
- [Core Methods](#core-methods)
- [Error Handling](#error-handling)
- [Examples](#examples)

## Authentication
...
```

### Use Descriptive File Names

Names should indicate content:

```
# Good - Self-documenting
form_validation_rules.md
api_authentication.md
error_handling_patterns.md

# Bad - Unclear
doc1.md
notes.md
stuff.md
```

## SKILL.md Body Guidelines

### Target Length

| Complexity | Recommended Lines |
|-----------|------------------|
| Simple | 50-150 |
| Standard | 150-300 |
| Complex | 300-500 |
| Maximum | 500 (hard limit) |

### Essential Sections

Every SKILL.md should include:

1. **Overview**: What the skill does (1-2 paragraphs)
2. **Quick Start**: Minimal working example
3. **Navigation**: Links to detailed docs
4. **Related Skills**: Cross-references

### Optional Sections

Include if relevant:

- **Prerequisites**: Required tools or setup
- **Common Patterns**: Frequently used approaches
- **Anti-Patterns**: What to avoid
- **Troubleshooting**: Common issues

## Scripts Organization

### When to Use Scripts

- **Deterministic operations**: Validation, formatting
- **Complex calculations**: Better than generated code
- **Repeated tasks**: Consistency across uses

### Script Documentation

````markdown
## Utility Scripts

### analyze_form.py

Extract form fields from PDF:

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

**Output format**:
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200}
}
```

### validate_fields.py

Check field mappings:

```bash
python scripts/validate_fields.py fields.json
# Returns: "OK" or lists errors
```
````

### Execution vs Reading

Make intent clear:

```markdown
# Execute the script (most common)
Run `analyze_form.py` to extract fields

# Read as reference (for understanding logic)
See `analyze_form.py` for the extraction algorithm
```

## File Size Guidelines

| File Type | Recommended Size |
|-----------|-----------------|
| SKILL.md | < 500 lines |
| Reference files | < 300 lines each |
| Example files | < 200 lines each |
| Script files | As needed |

If a file exceeds these limits, consider splitting by subtopic.
