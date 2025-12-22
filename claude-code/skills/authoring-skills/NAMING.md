# Naming Conventions and Descriptions

## Skill Name Requirements

### Technical Constraints

| Constraint | Requirement |
|-----------|-------------|
| Max length | 64 characters |
| Allowed chars | lowercase letters, numbers, hyphens |
| Forbidden | XML tags, spaces, underscores |
| Reserved words | "anthropic", "claude" |

### Naming Style: Gerund Form (Recommended)

Use verb + -ing form to clearly describe the activity:

| Good (Gerund) | Acceptable Alternative | Avoid |
|--------------|----------------------|-------|
| `processing-pdfs` | `pdf-processing` | `pdf-helper` |
| `analyzing-data` | `data-analysis` | `data-utils` |
| `testing-code` | `code-testing` | `test-tools` |
| `managing-databases` | `database-management` | `db` |
| `writing-documentation` | `doc-generator` | `docs` |

### Why Gerund Form?

1. **Action-oriented**: Clearly indicates what the skill does
2. **Consistent**: Easy to maintain naming pattern across skills
3. **Discoverable**: Search-friendly ("analyzing" matches "analyze")
4. **Self-documenting**: Name explains the capability

### Names to Avoid

```
# Too vague
helper, utils, tools, common, misc

# Too generic
documents, data, files, stuff

# Reserved words
anthropic-tools, claude-helper

# Technical violations
PDF_Processing    # underscores, uppercase
my skill          # spaces
processing.pdfs   # periods
```

## Writing Effective Descriptions

### Format Requirements

| Field | Constraint |
|-------|-----------|
| Max length | 1024 characters |
| Required | Non-empty |
| Forbidden | XML tags |

### The Two-Part Formula

Every description must answer:
1. **What does it do?** (capability)
2. **When to use it?** (trigger conditions)

```yaml
# Template
description: [What it does]. Use when [trigger conditions].

# Example
description: Extracts text and tables from PDF files. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

### Point of View: Always Third Person

**Critical**: Descriptions are injected into the system prompt. Inconsistent point-of-view causes discovery problems.

| Good (Third Person) | Avoid |
|--------------------|-------|
| "Processes Excel files and generates reports" | "I can help you process Excel files" |
| "Analyzes code for security vulnerabilities" | "You can use this to analyze code" |
| "Generates test cases from specifications" | "Use me to generate test cases" |

### Be Specific with Key Terms

Include terms users might search for:

```yaml
# Too vague
description: Helps with documents

# Better - includes key terms
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

### Include Trigger Conditions

Help Claude know when to activate the skill:

```yaml
# Without triggers - Claude may miss activation
description: Analyzes Excel spreadsheets

# With triggers - clear activation signals
description: Analyzes Excel spreadsheets, creates pivot tables, generates charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

## Examples by Category

### Data Processing Skills

```yaml
name: processing-pdfs
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

```yaml
name: analyzing-spreadsheets
description: Analyzes Excel and CSV files, creates pivot tables, generates charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx/.csv files.
```

### Development Skills

```yaml
name: testing-code
description: Generates unit tests and integration tests from code. Use when the user asks to create tests, improve test coverage, or validate functionality.
```

```yaml
name: reviewing-pull-requests
description: Reviews code changes for bugs, style issues, and best practices. Use when reviewing PRs, code diffs, or when asked to check code quality.
```

### Documentation Skills

```yaml
name: writing-api-docs
description: Generates API documentation from code and OpenAPI specs. Use when creating API docs, documenting endpoints, or generating SDK references.
```

### Infrastructure Skills

```yaml
name: managing-containers
description: Manages Docker containers and Compose stacks. Use when working with Docker, containers, or containerized deployments.
```

## Common Mistakes

### Mistake 1: No Trigger Conditions

```yaml
# Bad - no triggers
description: Processes images

# Good - clear triggers
description: Resizes, crops, and converts image files. Use when processing images, resizing photos, or converting image formats like PNG, JPG, WEBP.
```

### Mistake 2: Wrong Point of View

```yaml
# Bad - first/second person
description: I help you analyze data and create visualizations

# Good - third person
description: Analyzes data and creates visualizations. Use when exploring datasets or generating charts.
```

### Mistake 3: Too Long and Verbose

```yaml
# Bad - verbose explanation
description: This skill is designed to help with the process of analyzing various types of data files including but not limited to CSV, Excel, and JSON formats. It can perform statistical analysis, generate visualizations, and create reports. The skill is particularly useful when...

# Good - concise
description: Analyzes CSV, Excel, and JSON data with statistics and visualizations. Use when exploring data or generating analytical reports.
```

## Checklist

Before finalizing your skill name and description:

- [ ] Name uses gerund form (verb + -ing)
- [ ] Name is lowercase with hyphens only
- [ ] Name is under 64 characters
- [ ] Name avoids reserved words
- [ ] Description uses third person
- [ ] Description explains what it does
- [ ] Description includes trigger conditions
- [ ] Description includes key search terms
- [ ] Description is under 1024 characters
