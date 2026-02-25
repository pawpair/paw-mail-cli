---
name: worktree
description: Manage parallel feature development using git worktrees for working on multiple branches simultaneously
---

# Worktree Management Skill

Manage parallel feature development using git worktrees. Create separate working directories for different branches to work on multiple features simultaneously without stashing or branch switching.

## When to Use This Skill

- User wants to "work on multiple features in parallel"
- User says "create a new feature branch"
- User requests "set up a worktree for feature X"
- User needs to "switch to a different feature without losing changes"
- User wants to "work on feature A while also working on feature B"
- User asks "how do I work on multiple branches at once"

## What Are Git Worktrees?

Git worktrees allow you to check out multiple branches simultaneously in separate directories. Instead of switching branches (and having to stash/commit changes), you have a separate directory for each branch.

### Benefits
- **No stashing needed**: Each worktree has its own working directory
- **Parallel development**: Work on multiple features simultaneously
- **Separate builds**: Each worktree has its own `node_modules/`, `target/`, etc.
- **Multiple VS Code windows**: Open different worktrees in separate windows
- **Instant context switching**: Just `cd` to different directory

### Directory Structure
```
/home/dan/Code/
├── mail-client-mcp/           # Main repository (on 'main' branch)
└── mail-worktrees/            # Worktree parent directory
    ├── feature-oauth-refresh/ # Worktree for feature/oauth-refresh
    ├── feature-new-api/       # Worktree for feature/new-api
    └── bugfix-cookie-issue/   # Worktree for bugfix/cookie-issue
```

## Commands

### Create New Worktree

Create a new feature branch and worktree from `main`:
```bash
./skills/worktree/scripts/worktree.sh new feature/oauth-refresh
```

Create from a specific base branch:
```bash
./skills/worktree/scripts/worktree.sh new feature/new-api develop
```

Create without copying untracked files:
```bash
./skills/worktree/scripts/worktree.sh new feature/test-branch --no-copy
```

Create linked to a ticket (auto-moves ticket to "In Progress"):
```bash
./skills/worktree/scripts/worktree.sh new feature/my-feature --ticket PVTI_lADOCNCT9M4BPP61zglfMjk
```

**What this does**:
1. Creates new branch from base (defaults to `main`)
2. Creates worktree directory at `../mail-worktrees/feature-oauth-refresh/`
3. Checks out the new branch in the worktree
4. **Copies essential untracked files** (`.env`, `*.local`, etc.) to the worktree
5. **Installs skills** — symlinks `.agents/skills/*` into `.claude/skills/`
6. If `--ticket` provided:
   - Stores ticket ID in worktree and moves ticket to "In Progress"
   - Pushes the branch to origin
   - Creates a **draft PR** with the ticket title, linked to the project board
   - Stores the PR URL in `<worktree>/.pr-url`
6. Tells you how to `cd` into it

**Files automatically copied**:
- `.env` - Project configuration (GitHub tokens, API keys, etc.)
- `.bazelrc.user` - User-specific Bazel config (if exists)
- `credentials.json` - Credentials file (if exists)
- `*.local` - Any local configuration files (if exist)

### List All Worktrees

See all active worktrees and their branches:
```bash
./skills/worktree/scripts/worktree.sh list
```

**Output shows**:
- Worktree path
- Current commit SHA
- Branch name

### Remove Worktree

Remove a worktree when done with a feature:
```bash
./skills/worktree/scripts/worktree.sh remove feature/oauth-refresh
```

**What this does**:
1. Checks for uncommitted changes (warns if found)
2. Removes the worktree directory
3. Asks if you want to delete the branch too
4. Optionally deletes the branch with `git branch -D`
5. If a linked ticket exists (`.ticket-id`), offers to mark it as "Done"

### Prune Stale Worktrees

Clean up administrative files for worktrees that were deleted manually:
```bash
./skills/worktree/scripts/worktree.sh prune
```

**When to use**: If you deleted a worktree directory manually (e.g., `rm -rf`) instead of using the remove command.

## Configuration

### Customizing File Copying

By default, the skill copies essential untracked files (`.env`, `.bazelrc.user`, etc.) to new worktrees. You can customize this behavior:

**Create `.worktree-config` file** in your project root:
```bash
# List additional files to copy (one per line)
.custom-config
local-settings.json
scripts/local-env.sh
```

**Skip file copying** with the `--no-copy` flag:
```bash
./skills/worktree/scripts/worktree.sh new feature/test --no-copy
```

### Why Copy Files?

Worktrees share the same `.git` directory but have **separate working directories**. Untracked files (like `.env`) exist only in one working directory. Copying them ensures:

✅ **Ready to work immediately** - No need to recreate `.env` in each worktree
✅ **Consistent configuration** - Same API keys, database URLs, etc.
✅ **Independent changes** - Each worktree can modify its copy without affecting others

**Important**: Changes to copied files in a worktree **do not affect** the main repo or other worktrees. If you update `.env` in main repo, you'll need to manually sync it to active worktrees.

## Ticket Integration

The worktree skill integrates with the ticketing-management skill to automatically track work status.

### Creating a Worktree for a Ticket
When you pass `--ticket <PVTI_id>`, the skill:
1. Creates the worktree as usual
2. Stores the ticket ID in `<worktree>/.ticket-id`
3. Automatically moves the ticket to **"In Progress"** on the project board
4. Pushes the new branch to origin
5. Creates a **draft PR** using the ticket title, linked to the project board
6. Stores the PR URL in `<worktree>/.pr-url`

This means the ticket and PR are linked from the moment you start work.

```bash
# Get ticket ID from the ticketing skill
bash ./skills/ticketing-management/scripts/ticket.sh list --format json

# Create worktree linked to the ticket (also creates draft PR)
./skills/worktree/scripts/worktree.sh new feature/oauth-refresh --ticket PVTI_lADOCNCT9M4BPP61zglfMjk
```

### Closing a Ticket on Remove
When you remove a worktree that has a linked ticket:
1. The skill detects the `.ticket-id` file
2. After removal, asks: **"Mark ticket as Done? (y/N)"**
3. If confirmed, moves the ticket to **"Done"** on the project board

```bash
./skills/worktree/scripts/worktree.sh remove feature/oauth-refresh
# ✓ Worktree removed
# Mark ticket PVTI_... as Done? (y/N)
```

## Typical Workflow

### Starting a New Feature
```bash
# In main repo
cd /home/dan/Code/mail-client-mcp

# Create worktree for new feature
./skills/worktree/scripts/worktree.sh new feature/oauth-token-refresh

# Switch to worktree
cd ../mail-worktrees/feature-oauth-token-refresh

# Work on feature
# ... make changes, commit ...

# When done
cd /home/dan/Code/mail-client-mcp
./skills/worktree/scripts/worktree.sh remove feature/oauth-token-refresh
```

### Working on Multiple Features
```bash
# Create two worktrees
./skills/worktree/scripts/worktree.sh new feature/oauth-refresh
./skills/worktree/scripts/worktree.sh new feature/api-pagination

# Work on feature 1
cd ../mail-worktrees/feature-oauth-refresh
# ... work on OAuth ...

# Switch to feature 2 (no stashing needed!)
cd ../mail-worktrees/feature-api-pagination
# ... work on API ...

# Both features maintain their own state
```

### Hotfix While Working on Feature
```bash
# Currently working in feature worktree
cd /home/dan/Code/mail-client-mcp

# Create hotfix worktree
./skills/worktree/scripts/worktree.sh new hotfix/urgent-bug

# Fix the bug
cd ../mail-worktrees/hotfix-urgent-bug
# ... fix, commit, deploy ...

# Return to feature work (still has all changes intact)
cd ../mail-worktrees/feature-oauth-refresh
```

## Safety Features

### Uncommitted Changes Check
When removing a worktree, the skill checks for uncommitted changes:
```bash
./skills/worktree/scripts/worktree.sh remove feature/test

# If changes exist:
# ⚠ Worktree has uncommitted changes!
# M  src/config.rs
# ?? new-file.txt
#
# Continue removal? (y/N)
```

### Branch Deletion Confirmation
After removing a worktree, you're asked about the branch:
```bash
# Worktree removed: ../mail-worktrees/feature-test
# Delete branch 'feature/test'? (y/N)
```

This prevents accidentally deleting branches that still need to be pushed or merged.

## Important Notes

### Shared Git Directory
- All worktrees share the same `.git` directory from the main repo
- Commits made in any worktree appear in the shared history
- Branches are visible from all worktrees

### Copied Configuration Files
- **Copied files are independent** - Changes in one worktree don't affect others
- **Separate `.env` files** - Each worktree can have different API keys or settings
- **Manual sync required** - If you update `.env` in main repo, manually copy to active worktrees
- **Security consideration** - Each worktree has its own copy of credentials

**Example**: If you update the GitHub project number in main repo's `.env`, you need to manually update it in active worktrees or recreate them.

### Disk Space
- Each worktree is a full working copy of the repository
- A worktree with `node_modules/` and `target/` can be 500MB-2GB
- Copied configuration files add minimal overhead (< 1MB)
- Use `remove` to clean up when done

### Build Artifacts
- Each worktree has its own build artifacts
- Running `npm install` or `cargo build` in one worktree doesn't affect others
- This is a feature (isolation) but uses more disk space

### VS Code Integration
You can open each worktree in a separate VS Code window:
```bash
# Open main repo
code /home/dan/Code/mail-client-mcp

# Open worktree 1
code /home/dan/Code/mail-worktrees/feature-oauth-refresh

# Open worktree 2
code /home/dan/Code/mail-worktrees/feature-api-pagination
```

## Troubleshooting

### "worktree already exists"
**Reason**: Trying to create a worktree for a branch that's already checked out.
**Fix**: Use `list` to see active worktrees, then `remove` the existing one first.

### "branch already exists"
**Reason**: Branch name already exists in the repository.
**Options**:
- Use a different branch name
- Check out the existing branch: skill will ask to create worktree from existing branch

### "cannot remove current directory"
**Reason**: You're currently `cd`'d inside the worktree you're trying to remove.
**Fix**: `cd` back to main repo first:
```bash
cd /home/dan/Code/mail-client-mcp
./skills/worktree/scripts/worktree.sh remove feature/test
```

### Manually deleted worktree
**Reason**: You deleted the worktree directory without using the remove command.
**Fix**: Run prune to clean up:
```bash
./skills/worktree/scripts/worktree.sh prune
```

## Examples

### Example 1: Parallel Feature Development
```bash
# Create worktrees for multiple features
./skills/worktree/scripts/worktree.sh new feature/user-auth
./skills/worktree/scripts/worktree.sh new feature/email-templates
./skills/worktree/scripts/worktree.sh new feature/api-v2

# Work on each in separate terminal windows/tabs
# Terminal 1: cd ../mail-worktrees/feature-user-auth
# Terminal 2: cd ../mail-worktrees/feature-email-templates
# Terminal 3: cd ../mail-worktrees/feature-api-v2
```

### Example 2: Code Review While Developing
```bash
# Working on feature
cd ../mail-worktrees/feature-oauth-refresh

# Teammate asks for code review on their PR
# Create worktree for their branch
cd /home/dan/Code/mail-client-mcp
git fetch origin
./skills/worktree/scripts/worktree.sh new review/teammate-pr origin/teammate-feature

# Review in separate worktree
cd ../mail-worktrees/review-teammate-pr
# ... review code ...

# Return to your feature (unchanged)
cd ../mail-worktrees/feature-oauth-refresh
```

### Example 3: Testing Different Approaches
```bash
# Create two worktrees to try different implementation approaches
./skills/worktree/scripts/worktree.sh new experiment/approach-1
./skills/worktree/scripts/worktree.sh new experiment/approach-2

# Implement and test both approaches in parallel
# Keep the one that works better
```

## Related Commands

### See All Branches
```bash
git branch -a
```

### Fetch Remote Branches
```bash
git fetch origin
```

### Push Branch from Worktree
```bash
# From inside worktree
cd ../mail-worktrees/feature-oauth-refresh
git push -u origin feature/oauth-refresh
```

### Create PR from Worktree
```bash
# From inside worktree
cd ../mail-worktrees/feature-oauth-refresh
gh pr create --title "Add OAuth token refresh" --body "..."
```
