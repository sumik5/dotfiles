# Quality Checklist

Use this checklist before sharing a skill. Copy and check off items as you verify each requirement.

## Pre-Release Checklist

```
Skill Quality Checklist:

CORE QUALITY
- [ ] Name uses gerund form (verb + -ing)
- [ ] Name is lowercase with hyphens only (max 64 chars)
- [ ] Name avoids reserved words (anthropic, claude)
- [ ] Description uses third person voice
- [ ] Description explains what skill does
- [ ] Description includes trigger conditions
- [ ] Description is specific with key terms
- [ ] SKILL.md body is under 500 lines

STRUCTURE
- [ ] Additional details in separate files (if needed)
- [ ] File references are one level deep
- [ ] Long reference files have table of contents
- [ ] File names are descriptive
- [ ] Uses forward slashes for paths (not backslashes)

CONTENT
- [ ] No time-sensitive information (or in "old patterns" section)
- [ ] Consistent terminology throughout
- [ ] Examples are concrete, not abstract
- [ ] Workflows have clear steps
- [ ] Progressive disclosure used appropriately

CODE/SCRIPTS (if applicable)
- [ ] Scripts solve problems rather than punt to Claude
- [ ] Error handling is explicit and helpful
- [ ] No "voodoo constants" (all values justified)
- [ ] Required packages listed and verified
- [ ] Scripts have clear documentation
- [ ] Validation steps for critical operations
- [ ] Feedback loops for quality-critical tasks

TESTING
- [ ] At least 3 evaluation scenarios created
- [ ] Tested with intended model(s)
- [ ] Tested with real usage scenarios
- [ ] Team feedback incorporated (if applicable)
```

## Detailed Requirements

### Naming Requirements

| Requirement | Check |
|-------------|-------|
| Lowercase only | `processing-pdfs` not `Processing-PDFs` |
| Hyphens for separators | `processing-pdfs` not `processing_pdfs` |
| Gerund form | `processing-pdfs` not `pdf-processor` |
| Under 64 characters | Count your characters |
| No reserved words | Avoid `anthropic`, `claude` |

### Description Requirements

| Requirement | Example |
|-------------|---------|
| Third person | "Processes files" not "I process files" |
| What it does | "Extracts text from PDFs" |
| When to use | "Use when working with PDF files" |
| Key terms | Include searchable terms |
| Under 1024 chars | Keep it focused |

### Content Requirements

| Requirement | Verification |
|-------------|--------------|
| Under 500 lines | `wc -l SKILL.md` |
| No outdated info | Search for dates, versions |
| Consistent terms | One term per concept |
| Concrete examples | Input/output pairs |
| Clear workflows | Numbered steps |

### Code Requirements (if applicable)

| Requirement | Verification |
|-------------|--------------|
| Explicit error handling | Try/except with helpful messages |
| Documented constants | Comments explain magic numbers |
| Package dependencies | Listed in SKILL.md |
| Cross-platform paths | Forward slashes only |

## Common Issues

### Issue: Description Too Vague

```yaml
# Bad
description: Helps with documents

# Good
description: Extracts text and tables from PDF files. Use when working with PDFs or document extraction.
```

### Issue: Wrong Point of View

```yaml
# Bad
description: I can help you process Excel files

# Good
description: Processes Excel files and generates reports. Use when analyzing spreadsheets.
```

### Issue: Time-Sensitive Information

```markdown
# Bad
If you're doing this before August 2025, use the old API.

# Good
## Current Method
Use the v2 API endpoint.

## Legacy Method (Deprecated)
<details>
<summary>v1 API (deprecated)</summary>
The v1 API used different endpoints...
</details>
```

### Issue: Inconsistent Terminology

```markdown
# Bad - mixing terms
Use the "API endpoint" to...
Then call the "URL" with...
Access the "route" at...

# Good - consistent
Use the API endpoint to...
Then call the endpoint with...
Access the endpoint at...
```

### Issue: Deep File Nesting

```markdown
# Bad
SKILL.md → advanced.md → details.md → info.md

# Good
SKILL.md → advanced.md
SKILL.md → details.md
SKILL.md → info.md
```

### Issue: Too Many Options

````markdown
# Bad
You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image...

# Good
Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract.
````

## Quick Validation Commands

```bash
# Check SKILL.md line count
wc -l SKILL.md

# Check for time-sensitive patterns
grep -i "202[0-9]\|before\|after\|latest" SKILL.md

# Check for Windows paths
grep -r "\\\\" .

# Check name format
head -5 SKILL.md | grep "^name:"

# Check description format
head -10 SKILL.md | grep "^description:"
```

## Final Review Questions

Before sharing, ask yourself:

1. **Discoverability**: Will Claude find this skill when needed?
2. **Conciseness**: Is every line earning its place?
3. **Clarity**: Can Claude follow the instructions without confusion?
4. **Completeness**: Is anything critical missing?
5. **Testability**: Have I verified this works in practice?

If any answer is "no" or "unsure," iterate before sharing.
