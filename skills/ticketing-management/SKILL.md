---
name: ticketing-management
description: Manage tickets and issues across different ticketing systems with sync capabilities
---

# Ticketing Management Skill

Manage GitHub repo issues with structured Kanban labels, linked to the project board.

## Setup

Before using this skill, you need to:

1. **Authenticate with GitHub:**
   ```bash
   gh auth login
   gh auth refresh -h github.com -s project
   ```

2. **Configure the skill (optional):**

   Add to your project root `.env` file:
   ```bash
   # Ticketing Management Skill
   GITHUB_ORG=pawpair
   GITHUB_PROJECT_NUMBER=2
   GITHUB_PROJECT_NAME=Kanban
   ```

3. **Verify project access:**
   - Ensure you have access to the project: https://github.com/orgs/pawpair/projects/2
   - You must be a member of the `pawpair` organization

4. **Setup labels (one-time):**
   ```bash
   bash ./skills/ticketing-management/scripts/ticket.sh setup-labels --repo pawpair/main
   ```

## When to Use This Skill

- User requests "create a ticket" or "create an issue"
- User requests "create a GitHub issue"
- User asks to "track this task" or "file a bug"
- User wants to "update issue status" or "add labels"
- User needs to "list open tickets" or "check ticket status"

**Note**: All issues are created as proper repo issues in `pawpair/main` and automatically linked to project #2 (https://github.com/orgs/pawpair/projects/2).

## Kanban Label Structure

This skill uses a structured labeling system optimized for Kanban workflow:

### Type Labels (Required - Choose One)
- **`type:bug`** - Something isn't working
- **`type:feature`** - New feature or enhancement
- **`type:chore`** - Maintenance, refactoring, dependencies
- **`type:docs`** - Documentation improvements
- **`type:hotfix`** - Urgent production fix

### Priority Labels (Required - Choose One)
- **`priority:critical`** - Blocking issue, needs immediate attention
- **`priority:high`** - Important, should be done soon
- **`priority:medium`** - Normal priority
- **`priority:low`** - Nice to have, not urgent

### Size Labels (Optional - Effort Estimation)
- **`size:xs`** - < 1 hour
- **`size:small`** - 1-4 hours
- **`size:medium`** - 1-2 days
- **`size:large`** - 3-5 days
- **`size:xl`** - > 1 week

### Component Labels (Optional - Area of Work)
- **`component:backend`** - Backend/API changes
- **`component:frontend`** - UI/Client changes
- **`component:database`** - Database schema/migrations
- **`component:infrastructure`** - DevOps, K8s, deployment
- **`component:auth`** - Authentication/authorization
- **`component:api`** - API endpoints
- **`component:security`** - Security vulnerabilities, exploits
- **`component:documentation`** - Documentation, guides, tutorials
- **`component:investigation`** - Research, debugging, troubleshooting

### Status Labels (Automatic - Managed by Project Board)
- **`status:todo`** - In backlog
- **`status:in-progress`** - Currently being worked on
- **`status:review`** - Ready for code review
- **`status:blocked`** - Blocked by another issue
- **`status:done`** - Completed

## Commands

### Create Issue

Creates a proper repo issue with labels, automatically linked to the Kanban project board:
```bash
bash ./skills/ticketing-management/scripts/ticket.sh create \
  --title "Add OAuth token refresh" \
  --body "Implement automatic OAuth token refresh for expired sessions" \
  --type feature \
  --priority high \
  --component backend \
  --size medium
```

Or use raw labels:
```bash
bash ./skills/ticketing-management/scripts/ticket.sh create \
  --title "Fix login bug" \
  --labels "type:bug,priority:critical,component:auth"
```

**Options**:
- `--title` (required): Issue title
- `--body`: Detailed description
- `--repo`: Target repository (default: `pawpair/main`)
- `--type`: Type label (bug, feature, chore, docs, hotfix)
- `--priority`: Priority label (critical, high, medium, low)
- `--size`: Size label (xs, small, medium, large, xl)
- `--component`: Component label (backend, frontend, database, infrastructure, auth, api, security, documentation, investigation)
- `--labels`: Raw comma-separated labels (overrides structured labels)
- `--assignee`: GitHub username to assign
- `--milestone`: Milestone name
- `--no-auto`: Disable automatic label suggestion

**What this does**:
1. Auto-suggests type, priority, and component labels from title/body keywords
2. Creates a repo issue in `pawpair/main` (or specified repo) with labels applied
3. Links the issue to the Kanban project board via `--project`
4. Returns the issue URL and number

**Label Auto-Suggestion**:
Labels are automatically applied (not just suggested) based on keywords:
- Keywords like "fix", "bug", "broken" → `type:bug`
- Keywords like "add", "new", "implement" → `type:feature`
- Keywords like "urgent", "critical", "production" → `priority:critical`
- Keywords like "backend", "API", "database" → appropriate component labels
- Keywords like "security", "vulnerability", "exploit" → `component:security`
- Keywords like "docs", "documentation", "guide" → `component:documentation`
- Keywords like "investigate", "debug", "troubleshoot" → `component:investigation`

### List Issues

List repo issues with labels, assignees, and state:
```bash
bash ./skills/ticketing-management/scripts/ticket.sh list \
  --limit 50 \
  --format json
```

Filter by label:
```bash
bash ./skills/ticketing-management/scripts/ticket.sh list --label "type:bug" --state open
```

**Options**:
- `--limit`: Maximum number of items to return (default: 30)
- `--format`: Output format - `json` or `table` (default: json)
- `--state`: Issue state - `open`, `closed`, `all` (default: open)
- `--label`: Filter by label name
- `--repo`: Target repository (default: `pawpair/main`)

**JSON output includes**: number, title, state, labels, assignees, url, createdAt, updatedAt

### Update Issue

Update an issue's labels, assignees, project status, or close it:

```bash
# Update project board status
bash ./skills/ticketing-management/scripts/ticket.sh update \
  --item-id PVTI_xxx --status "In Progress"

# Add labels to an issue
bash ./skills/ticketing-management/scripts/ticket.sh update \
  --issue 13 --add-labels "priority:high,component:backend"

# Remove labels
bash ./skills/ticketing-management/scripts/ticket.sh update \
  --issue 13 --remove-labels "priority:low"

# Assign an issue
bash ./skills/ticketing-management/scripts/ticket.sh update \
  --issue 13 --assignee "danb"

# Close an issue
bash ./skills/ticketing-management/scripts/ticket.sh update \
  --issue 13 --close

# Update status to Done (auto-closes the issue)
bash ./skills/ticketing-management/scripts/ticket.sh update \
  --issue 13 --item-id PVTI_xxx --status "Done"
```

**Options**:
- `--issue`: Issue number (for label/assignee/close operations)
- `--item-id`: Project item ID (for project board status updates)
- `--status`: Update project board status (e.g., "Todo", "In Progress", "Done")
- `--add-labels`: Comma-separated labels to add
- `--remove-labels`: Comma-separated labels to remove
- `--assignee`: Assign to GitHub user
- `--close`: Close the issue
- `--repo`: Target repository (default: `pawpair/main`)
- `--field`: Custom project field name to update
- `--value`: Value for custom field

**Notes**:
- Setting `--status "Done"` with `--issue` automatically closes the issue
- You can combine `--item-id` and `--issue` to update both project status and issue properties in one command

## Worktree Integration

The ticketing skill integrates with the worktree skill for automatic status tracking via issue labels:

- **Creating a worktree with `--ticket <issue#>`** adds `status:in-progress` label and creates a draft PR with `Closes #N`
- **Removing a worktree** offers to close the linked issue and add `status:done` label

```bash
# Create an issue, then start working with a linked worktree
bash ./skills/ticketing-management/scripts/ticket.sh create --title "Add OAuth refresh"
bash ./skills/ticketing-management/scripts/ticket.sh list --format json  # get issue number

# Create worktree linked to issue #34 (adds status:in-progress, creates draft PR)
./skills/worktree/scripts/worktree.sh new feature/oauth-refresh --ticket 34

# When done, remove worktree (offers to close issue and add status:done)
./skills/worktree/scripts/worktree.sh remove feature/oauth-refresh
```

See the [worktree SKILL.md](../worktree/SKILL.md) for more details on the integration.

## Typical Workflows

### Bug Report Workflow
```bash
# Create bug issue (auto-labeled, linked to project)
bash ./skills/ticketing-management/scripts/ticket.sh create \
  --title "Fix cookie expiration handling" \
  --body "Cookies are not being refreshed properly" \
  --type bug \
  --priority high

# Issue created at https://github.com/pawpair/main/issues/XX
# Automatically linked to Kanban project board

# List issues to get the issue number
bash ./skills/ticketing-management/scripts/ticket.sh list --limit 5

# Start working on it
bash ./skills/ticketing-management/scripts/ticket.sh update \
  --issue 13 --item-id PVTI_xxx --status "In Progress"

# Fix the bug, commit, create PR...

# Mark as done (auto-closes the issue)
bash ./skills/ticketing-management/scripts/ticket.sh update \
  --issue 13 --item-id PVTI_xxx --status "Done"
```

### Feature Planning Workflow
```bash
# Create feature request
bash ./skills/ticketing-management/scripts/ticket.sh create \
  --title "Add dark mode support" \
  --body "Implement dark mode toggle in settings" \
  --type feature \
  --component frontend \
  --milestone "v2.0"

# Break down into subtasks
bash ./skills/ticketing-management/scripts/ticket.sh create \
  --title "Add theme context provider" \
  --body "Create React context for theme state. Related to #46" \
  --type feature \
  --component frontend
```

### Sprint Review Workflow
```bash
# List all open issues
bash ./skills/ticketing-management/scripts/ticket.sh list \
  --limit 100 --format json

# Filter by label
bash ./skills/ticketing-management/scripts/ticket.sh list \
  --label "type:bug" --state open

# View project board
# Visit: https://github.com/orgs/pawpair/projects/2
```

## Configuration

### Environment Variables

Configure the skill by adding these variables to your project root `.env` file:

```bash
# Ticketing Management Skill
GITHUB_ORG=pawpair
GITHUB_PROJECT_NUMBER=2
GITHUB_PROJECT_NAME=Kanban
```

**Configuration options:**
- `GITHUB_ORG`: GitHub organization name (default: `pawpair`)
- `GITHUB_PROJECT_NUMBER`: GitHub project number from URL (default: `2`)
  - Find in URL: `https://github.com/orgs/pawpair/projects/2`
- `GITHUB_PROJECT_NAME`: Project display name (default: `Kanban`)

**Note:** You can also create a skill-specific `.env` file at `skills/ticketing-management/.env` to override project-level settings.

## Troubleshooting

### "Not authenticated with GitHub"
**Fix**: Run `gh auth login` and follow prompts

### "Permission denied" or "Project not found"
**Reason**: Not a member of pawpair organization, or project #2 doesn't exist
**Fix**:
1. Request access to the pawpair organization from an admin
2. Verify project #2 exists: https://github.com/orgs/pawpair/projects/2
3. If project doesn't exist, an org admin needs to create it manually

### "Rate limit exceeded"
**Reason**: Too many API requests
**Fix**: Wait for rate limit to reset (check: `gh api rate_limit`)

## Related Commands

### GitHub CLI
```bash
# View issue details
gh issue view 13 --repo pawpair/main

# Create issue interactively
gh issue create --repo pawpair/main

# List projects
gh project list --org pawpair

# View project board
gh project view 2 --org pawpair
```

### Git Integration
```bash
# Reference issue in commit
git commit -m "Fix bug (#13)"

# Create branch from issue
gh issue develop 13 --checkout
```
