#!/usr/bin/env bash
set -e

# Worktree skill - Manage parallel feature development with git worktrees
# Usage: ./skills/worktree.sh [new|list|remove|prune] [args...]

COMMAND="${1:-list}"
WORKTREES_DIR="../mail-worktrees"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TICKET_SCRIPT="$SCRIPT_DIR/../../ticketing-management/scripts/ticket.sh"

# Load environment config (shared with ticketing skill)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a; source "$PROJECT_ROOT/.env"; set +a
fi
DEFAULT_ORG="${GITHUB_ORG:-pawpair}"
DEFAULT_PROJECT_NUMBER="${GITHUB_PROJECT_NUMBER:-2}"
DEFAULT_PROJECT="${GITHUB_PROJECT_NAME:-Kanban}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

show_usage() {
    cat <<EOF
Git Worktree Management Skill

Create and manage parallel development branches with git worktrees.
Each worktree is a separate working directory allowing parallel work.

Usage:
  ./skills/worktree.sh new <branch-name> [base-branch] [--no-copy] [--ticket <ID>]
  ./skills/worktree.sh list
  ./skills/worktree.sh remove <branch-name>
  ./skills/worktree.sh prune
  ./skills/worktree.sh help

Commands:
  new <name> [base] [--no-copy] [--ticket <ID>]
                       Create new branch and worktree
                       base defaults to 'main'
                       Copies .env and other untracked files by default
                       Use --no-copy to skip file copying
                       Use --ticket to link a project ticket (auto-moves to In Progress)
  list                 List all worktrees
  remove <name>        Remove worktree and optionally delete branch
  prune                Clean up stale worktree administrative files
  help                 Show this help message

Examples:
  # Create feature branch from main (copies .env)
  ./skills/worktree.sh new feature/oauth-refresh

  # Create feature branch without copying files
  ./skills/worktree.sh new feature/oauth-refresh --no-copy

  # Create feature branch from specific base
  ./skills/worktree.sh new feature/new-api develop

  # Create feature branch linked to a ticket (auto-moves to In Progress)
  ./skills/worktree.sh new feature/my-feature --ticket PVTI_lADOCNCT9M4BPP61zglfMjk

  # List all worktrees
  ./skills/worktree.sh list

  # Remove worktree (keeps branch)
  ./skills/worktree.sh remove feature/oauth-refresh

  # Clean up stale worktrees
  ./skills/worktree.sh prune

Worktree Location:
  All worktrees are created in: ${WORKTREES_DIR}/
  Main repo remains at: $(pwd)

File Copying:
  By default, essential untracked files are copied to new worktrees:
  - .env (project configuration)
  - .bazelrc.user (if exists)
  - credentials.json (if exists)
  - *.local files (if exist)

  Customize by creating .worktree-config file in project root.

Skills Installation:
  Skills from .agents/skills/ are automatically symlinked into
  .claude/skills/ so Claude Code can discover them in the new worktree.
EOF
}

list_worktrees() {
    log "Active worktrees:"
    echo ""
    git worktree list
    echo ""

    local count=$(git worktree list | wc -l)
    success "Found $count worktree(s)"
}

install_skills() {
    local worktree_path="$1"

    log "Installing skills into worktree..."

    # Skills live in .agents/skills/ (tracked by git, present in every worktree)
    # Symlinks in .claude/skills/ point to them (not tracked, must be created)
    local agents_dir="${worktree_path}/.agents/skills"
    local skills_dir="${worktree_path}/.claude/skills"

    if [[ ! -d "$agents_dir" ]]; then
        warn "No .agents/skills/ directory found in worktree — skipping skill install"
        return
    fi

    mkdir -p "$skills_dir"

    local installed=0
    for skill_path in "$agents_dir"/*/; do
        [[ ! -d "$skill_path" ]] && continue
        local skill_name
        skill_name="$(basename "$skill_path")"

        # Relative symlink: .claude/skills/<name> -> ../../.agents/skills/<name>
        local link="${skills_dir}/${skill_name}"
        local target="../../.agents/skills/${skill_name}"

        if [[ -L "$link" ]]; then
            # Already linked
            continue
        fi

        ln -s "$target" "$link"
        success "Installed skill: ${skill_name}"
        installed=$((installed + 1))
    done

    if [[ $installed -gt 0 ]]; then
        success "Installed $installed skill(s)"
    else
        log "All skills already installed"
    fi
}

copy_untracked_files() {
    local worktree_path="$1"
    local main_repo_path="$(pwd)"

    log "Copying essential untracked files to worktree..."

    # Default files to copy
    local files_to_copy=(
        ".env"
        ".bazelrc.user"
        "credentials.json"
    )

    # Check for .worktree-config for custom files
    if [[ -f ".worktree-config" ]]; then
        log "Found .worktree-config, loading custom file list..."
        mapfile -t custom_files < .worktree-config
        files_to_copy+=("${custom_files[@]}")
    fi

    # Also copy any *.local files
    shopt -s nullglob
    local local_files=( *.local )
    if [ ${#local_files[@]} -gt 0 ]; then
        files_to_copy+=( "${local_files[@]}" )
    fi
    shopt -u nullglob

    local copied_count=0
    local skipped_count=0

    for file in "${files_to_copy[@]}"; do
        # Skip empty lines from config file
        [[ -z "$file" ]] && continue

        if [[ -f "$main_repo_path/$file" ]]; then
            cp "$main_repo_path/$file" "$worktree_path/$file"
            success "Copied: $file"
            copied_count=$((copied_count + 1))

            # Warn about sensitive files
            if [[ "$file" == "credentials.json" ]] || [[ "$file" == *.pem ]] || [[ "$file" == *.key ]]; then
                warn "Copied sensitive file: $file (handle with care)"
            fi
        else
            skipped_count=$((skipped_count + 1))
        fi
    done

    echo ""
    if [[ $copied_count -gt 0 ]]; then
        success "Copied $copied_count file(s) to worktree"
        log "Note: Changes to these files in worktree won't affect main repo"
    else
        log "No untracked files found to copy"
    fi
}

create_worktree() {
    local branch_name="$1"
    local base_branch="${2:-main}"
    local copy_files="${3:-true}"
    local ticket_id="${4:-}"

    if [[ -z "$branch_name" ]]; then
        error "Branch name required"
        echo "Usage: ./skills/worktree.sh new <branch-name> [base-branch] [--no-copy] [--ticket <ID>]"
        exit 1
    fi

    # Sanitize branch name for directory
    local dir_name=$(echo "$branch_name" | sed 's/\//-/g')
    local worktree_path="${WORKTREES_DIR}/${dir_name}"

    log "Creating worktree for branch: ${branch_name}"
    log "Base branch: ${base_branch}"
    log "Location: ${worktree_path}"
    if [[ -n "$ticket_id" ]]; then
        log "Linked ticket: ${ticket_id}"
    fi

    # Create worktrees directory if it doesn't exist
    mkdir -p "${WORKTREES_DIR}"

    # Check if branch already exists
    if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        warn "Branch '${branch_name}' already exists"
        read -p "Check out existing branch? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git worktree add "${worktree_path}" "${branch_name}"
        else
            exit 1
        fi
    else
        # Create new branch and worktree
        git worktree add -b "${branch_name}" "${worktree_path}" "${base_branch}"
    fi

    success "Worktree created: ${worktree_path}"
    echo ""

    # Copy untracked files unless --no-copy was specified
    if [[ "$copy_files" == "true" ]]; then
        copy_untracked_files "${worktree_path}"
        echo ""
    fi

    # Install skills (symlink .agents/skills/* into .claude/skills/)
    install_skills "${worktree_path}"
    echo ""

    # Store ticket ID and move ticket to In Progress
    if [[ -n "$ticket_id" ]]; then
        echo "$ticket_id" > "${worktree_path}/.ticket-id"
        success "Stored ticket ID in ${worktree_path}/.ticket-id"

        if [[ -f "$TICKET_SCRIPT" ]]; then
            log "Moving ticket to In Progress..."
            bash "$TICKET_SCRIPT" update --item-id "$ticket_id" --status "In progress" || {
                warn "Could not update ticket status (non-fatal)"
            }
        else
            warn "Ticket script not found at $TICKET_SCRIPT - skipping status update"
        fi

        # Create draft PR linked to the ticket
        echo ""
        log "Pushing branch to origin..."
        git -C "${worktree_path}" push -u origin "${branch_name}" 2>&1 || {
            warn "Could not push branch to origin (non-fatal, skipping draft PR)"
        }

        if git -C "${worktree_path}" ls-remote --exit-code origin "${branch_name}" >/dev/null 2>&1; then
            local repo_name
            repo_name="$(basename "$(git remote get-url origin)" .git)"

            # Get ticket title from project board for PR title
            local ticket_title
            ticket_title=$(gh project item-list "$DEFAULT_PROJECT_NUMBER" --owner "$DEFAULT_ORG" --format json 2>/dev/null \
                | jq -r ".items[] | select(.id == \"$ticket_id\") | .title" 2>/dev/null) || true

            if [[ -z "$ticket_title" || "$ticket_title" == "null" ]]; then
                ticket_title="$branch_name"
                warn "Could not fetch ticket title, using branch name for PR"
            fi

            log "Creating draft PR: ${ticket_title}"
            local pr_url
            pr_url=$(gh pr create \
                --repo "$DEFAULT_ORG/$repo_name" \
                --head "$branch_name" \
                --base main \
                --title "$ticket_title" \
                --body "Linked to project ticket: $ticket_id" \
                --draft \
                --project "$DEFAULT_PROJECT" 2>&1) || {
                warn "Could not create draft PR (non-fatal)"
                pr_url=""
            }

            if [[ -n "$pr_url" ]]; then
                echo "$pr_url" > "${worktree_path}/.pr-url"
                success "Draft PR created: ${pr_url}"
            fi
        fi

        echo ""
        log "Ticket: https://github.com/orgs/${DEFAULT_ORG}/projects/${DEFAULT_PROJECT_NUMBER}"
    fi

    log "To start working:"
    echo -e "  ${GREEN}cd ${worktree_path}${NC}"
    echo ""
    log "Current worktrees:"
    git worktree list
}

remove_worktree() {
    local branch_name="$1"

    if [[ -z "$branch_name" ]]; then
        error "Branch name required"
        echo "Usage: ./skills/worktree.sh remove <branch-name>"
        exit 1
    fi

    # Sanitize branch name for directory
    local dir_name=$(echo "$branch_name" | sed 's/\//-/g')
    local worktree_path="${WORKTREES_DIR}/${dir_name}"

    # Check if worktree exists
    if [[ ! -d "$worktree_path" ]]; then
        error "Worktree not found: ${worktree_path}"
        exit 1
    fi

    log "Removing worktree: ${worktree_path}"

    # Check for linked ticket before removal
    local ticket_id=""
    if [[ -f "${worktree_path}/.ticket-id" ]]; then
        ticket_id=$(cat "${worktree_path}/.ticket-id")
        log "Linked ticket found: ${ticket_id}"
    fi

    # Check for uncommitted changes
    if ! git -C "${worktree_path}" diff-index --quiet HEAD --; then
        warn "Worktree has uncommitted changes!"
        git -C "${worktree_path}" status --short
        echo ""
        read -p "Continue removal? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Remove worktree
    git worktree remove "${worktree_path}"
    success "Worktree removed: ${worktree_path}"

    # Ask about branch deletion
    echo ""
    read -p "Delete branch '${branch_name}'? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -D "${branch_name}"
        success "Branch deleted: ${branch_name}"
    else
        log "Branch kept: ${branch_name}"
    fi

    # Offer to mark linked ticket as Done
    if [[ -n "$ticket_id" ]]; then
        echo ""
        read -p "Mark ticket ${ticket_id} as Done? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [[ -f "$TICKET_SCRIPT" ]]; then
                log "Moving ticket to Done..."
                bash "$TICKET_SCRIPT" update --item-id "$ticket_id" --status "Done" || {
                    warn "Could not update ticket status"
                }
            else
                warn "Ticket script not found at $TICKET_SCRIPT"
            fi
        else
            log "Ticket status unchanged"
        fi
    fi
}

prune_worktrees() {
    log "Pruning stale worktree administrative files..."
    git worktree prune -v
    success "Prune complete"
}

# Main execution
case $COMMAND in
    new|create|add)
        # Parse flags
        copy_files="true"
        branch_name="$2"
        base_branch=""
        ticket_id=""

        shift # remove the command
        shift # remove the branch name

        # Parse remaining args
        while [[ $# -gt 0 ]]; do
            case $1 in
                --no-copy)
                    copy_files="false"
                    shift
                    ;;
                --ticket)
                    ticket_id="$2"
                    shift 2
                    ;;
                -*)
                    error "Unknown flag: $1"
                    exit 1
                    ;;
                *)
                    # Positional arg = base branch
                    if [[ -z "$base_branch" ]]; then
                        base_branch="$1"
                    fi
                    shift
                    ;;
            esac
        done

        base_branch="${base_branch:-main}"

        create_worktree "$branch_name" "$base_branch" "$copy_files" "$ticket_id"
        ;;
    list|ls)
        list_worktrees
        ;;
    remove|rm|delete)
        remove_worktree "$2"
        ;;
    prune|clean)
        prune_worktrees
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        error "Unknown command: $COMMAND"
        echo ""
        show_usage
        exit 1
        ;;
esac
