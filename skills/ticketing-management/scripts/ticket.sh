#!/bin/bash
set -e

# Ticketing Management Script
# Manage GitHub Issues with Kanban label structure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load .env file from project root if exists
if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
fi

# Load skill-specific .env if exists (overrides project root)
if [ -f "$SKILL_ROOT/.env" ]; then
    set -a
    source "$SKILL_ROOT/.env"
    set +a
fi

# Default configuration (can be overridden by .env)
DEFAULT_PROVIDER="github"
DEFAULT_ORG="${GITHUB_ORG:-pawpair}"
DEFAULT_PROJECT="${GITHUB_PROJECT_NAME:-Kanban}"
DEFAULT_PROJECT_NUMBER="${GITHUB_PROJECT_NUMBER:-2}"
CONFIG_FILE="$PROJECT_ROOT/.ticketing.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Kanban label structure with colors
declare -A LABEL_COLORS=(
    # Type labels
    ["type:bug"]="d73a4a"
    ["type:feature"]="a2eeef"
    ["type:chore"]="fef2c0"
    ["type:docs"]="0075ca"
    ["type:hotfix"]="b60205"

    # Priority labels
    ["priority:critical"]="b60205"
    ["priority:high"]="d93f0b"
    ["priority:medium"]="fbca04"
    ["priority:low"]="0e8a16"

    # Size labels
    ["size:xs"]="c2e0c6"
    ["size:small"]="bfdadc"
    ["size:medium"]="f9d0c4"
    ["size:large"]="f9c0a8"
    ["size:xl"]="e99695"

    # Component labels
    ["component:backend"]="1d76db"
    ["component:frontend"]="5319e7"
    ["component:database"]="006b75"
    ["component:infrastructure"]="0e8a16"
    ["component:auth"]="e99695"
    ["component:api"]="1d76db"
    ["component:security"]="b60205"
    ["component:documentation"]="0075ca"
    ["component:investigation"]="fbca04"

    # Status labels
    ["status:todo"]="ededed"
    ["status:in-progress"]="fbca04"
    ["status:review"]="0075ca"
    ["status:blocked"]="d73a4a"
    ["status:done"]="0e8a16"
)

# Helper functions
info() {
    echo -e "${BLUE}ℹ${NC} $1" >&2
}

success() {
    echo -e "${GREEN}✓${NC} $1" >&2
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1" >&2
}

prompt() {
    echo -e "${CYAN}?${NC} $1" >&2
}

# Check if gh CLI is installed and authenticated
check_github_auth() {
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) is not installed"
        info "Install: https://cli.github.com/"
        exit 1
    fi

    if ! gh auth status &> /dev/null; then
        error "Not authenticated with GitHub"
        info "Run: gh auth login"
        exit 1
    fi
}

# Load configuration from .ticketing.yml if exists
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        info "Loading configuration from .ticketing.yml"
        if command -v yq &> /dev/null; then
            DEFAULT_ORG=$(yq eval '.github.default_org' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_ORG")
            DEFAULT_PROJECT=$(yq eval '.github.default_project' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_PROJECT")
        fi
    fi
}

# Check if label exists in repository
label_exists() {
    local repo="$1"
    local label="$2"

    gh label list --repo "$repo" --json name --jq '.[].name' 2>/dev/null | grep -q "^${label}$"
}

# Create label in repository
create_label() {
    local repo="$1"
    local label="$2"
    local color="${LABEL_COLORS[$label]:-ededed}"

    info "Creating label: $label"
    gh label create "$label" --repo "$repo" --color "$color" --force 2>/dev/null || {
        warning "Failed to create label: $label (may already exist with different color)"
        return 1
    }
    success "Created label: $label"
}

# Check and create missing labels
ensure_labels() {
    local repo="$1"
    shift
    local labels=("$@")
    local missing_labels=()

    info "Checking labels in repository..."

    for label in "${labels[@]}"; do
        if ! label_exists "$repo" "$label"; then
            missing_labels+=("$label")
        fi
    done

    if [ ${#missing_labels[@]} -eq 0 ]; then
        success "All labels exist"
        return 0
    fi

    warning "Missing labels: ${missing_labels[*]}"
    prompt "Create missing labels? (y/n) "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        for label in "${missing_labels[@]}"; do
            create_label "$repo" "$label"
        done
        return 0
    else
        warning "Proceeding without creating labels"
        return 1
    fi
}

# Auto-suggest type label based on title/body
suggest_type() {
    local text="$1"
    local lower_text=$(echo "$text" | tr '[:upper:]' '[:lower:]')

    if [[ "$lower_text" =~ (fix|bug|broken|error|crash|issue|problem) ]]; then
        echo "bug"
    elif [[ "$lower_text" =~ (add|new|implement|feature|enhance|improvement) ]]; then
        echo "feature"
    elif [[ "$lower_text" =~ (refactor|cleanup|update|upgrade|dependency|dependencies) ]]; then
        echo "chore"
    elif [[ "$lower_text" =~ (docs|documentation|readme|guide) ]]; then
        echo "docs"
    elif [[ "$lower_text" =~ (hotfix|urgent|critical|production) ]]; then
        echo "hotfix"
    else
        echo "feature"  # Default
    fi
}

# Auto-suggest priority label based on title/body
suggest_priority() {
    local text="$1"
    local lower_text=$(echo "$text" | tr '[:upper:]' '[:lower:]')

    if [[ "$lower_text" =~ (critical|urgent|hotfix|production|blocking|blocker) ]]; then
        echo "critical"
    elif [[ "$lower_text" =~ (important|high|soon|asap) ]]; then
        echo "high"
    elif [[ "$lower_text" =~ (low|minor|nice.to.have|optional) ]]; then
        echo "low"
    else
        echo "medium"  # Default
    fi
}

# Auto-suggest component label based on title/body
suggest_component() {
    local text="$1"
    local lower_text=$(echo "$text" | tr '[:upper:]' '[:lower:]')
    local components=()

    [[ "$lower_text" =~ (backend|api|server|grpc|rest) ]] && components+=("backend")
    [[ "$lower_text" =~ (frontend|ui|client|svelte|react) ]] && components+=("frontend")
    [[ "$lower_text" =~ (database|postgres|sql|migration|schema) ]] && components+=("database")
    [[ "$lower_text" =~ (infrastructure|k8s|kubernetes|docker|deploy|devops) ]] && components+=("infrastructure")
    [[ "$lower_text" =~ (auth|authentication|authorization|oauth|keycloak|login) ]] && components+=("auth")
    [[ "$lower_text" =~ (api|endpoint|rest) ]] && components+=("api")
    [[ "$lower_text" =~ (security|vulnerability|cve|exploit|xss|csrf|injection) ]] && components+=("security")
    [[ "$lower_text" =~ (docs|documentation|readme|guide|tutorial) ]] && components+=("documentation")
    [[ "$lower_text" =~ (investigate|investigation|research|analyze|debug|troubleshoot) ]] && components+=("investigation")

    if [ ${#components[@]} -gt 0 ]; then
        echo "${components[0]}"  # Return first match
    else
        echo ""
    fi
}

# Create a new ticket
create_ticket() {
    local title=""
    local body=""
    local repo=""
    local raw_labels=""
    local assignee=""
    local milestone=""
    local auto_suggest=true

    # Structured label params
    local type=""
    local priority=""
    local size=""
    local component=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --title)
                title="$2"
                shift 2
                ;;
            --body)
                body="$2"
                shift 2
                ;;
            --repo)
                repo="$2"
                shift 2
                ;;
            --type)
                type="$2"
                shift 2
                ;;
            --priority)
                priority="$2"
                shift 2
                ;;
            --size)
                size="$2"
                shift 2
                ;;
            --component)
                component="$2"
                shift 2
                ;;
            --labels)
                raw_labels="$2"
                shift 2
                ;;
            --assignee)
                assignee="$2"
                shift 2
                ;;
            --milestone)
                milestone="$2"
                shift 2
                ;;
            --no-auto)
                auto_suggest=false
                shift
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Validate required fields
    if [ -z "$title" ]; then
        error "Title is required (--title)"
        exit 1
    fi

    check_github_auth

    # Auto-suggest labels if not provided and auto-suggest is enabled
    local search_text="$title $body"

    if [ -z "$type" ] && [ -z "$raw_labels" ] && [ "$auto_suggest" = true ]; then
        type=$(suggest_type "$search_text")
        info "Auto-suggested type: $type"
    fi

    if [ -z "$priority" ] && [ -z "$raw_labels" ] && [ "$auto_suggest" = true ]; then
        priority=$(suggest_priority "$search_text")
        info "Auto-suggested priority: $priority"
    fi

    if [ -z "$component" ] && [ -z "$raw_labels" ] && [ "$auto_suggest" = true ]; then
        component=$(suggest_component "$search_text")
        if [ -n "$component" ]; then
            info "Auto-suggested component: $component"
        fi
    fi

    # Build label list
    local label_list=()

    if [ -n "$raw_labels" ]; then
        # Use raw labels if provided
        IFS=',' read -ra label_list <<< "$raw_labels"
    else
        # Build from structured params
        [ -n "$type" ] && label_list+=("type:$type")
        [ -n "$priority" ] && label_list+=("priority:$priority")
        [ -n "$size" ] && label_list+=("size:$size")
        [ -n "$component" ] && label_list+=("component:$component")
    fi

    # Default repo to org/main if not specified
    local target_repo="${repo:-$DEFAULT_ORG/main}"

    # Ensure body is not empty (gh issue create requires --body in non-interactive mode)
    if [ -z "$body" ]; then
        body="*Created via ticketing skill*"
    fi

    # Build label string (comma-separated)
    local label_str=""
    if [ ${#label_list[@]} -gt 0 ]; then
        label_str=$(IFS=','; echo "${label_list[*]}")
    fi

    # Create repo issue linked to project
    info "Creating issue in $target_repo..."
    echo "" >&2
    echo "Title: $title" >&2
    if [ -n "$label_str" ]; then
        echo "Labels: $label_str" >&2
    fi
    echo "" >&2

    local cmd_args=(gh issue create --repo "$target_repo" --title "$title" --body "$body")

    if [ -n "$label_str" ]; then
        cmd_args+=(--label "$label_str")
    fi

    if [ -n "$assignee" ]; then
        cmd_args+=(--assignee "$assignee")
    fi

    if [ -n "$milestone" ]; then
        cmd_args+=(--milestone "$milestone")
    fi

    # Link to project board
    cmd_args+=(--project "$DEFAULT_PROJECT")

    issue_url=$("${cmd_args[@]}" 2>&1)

    if [ $? -eq 0 ]; then
        success "Issue created: $issue_url"

        # Extract issue number from URL
        local issue_number
        issue_number=$(echo "$issue_url" | grep -oP '/issues/\K[0-9]+' || echo "")

        if [ -n "$issue_number" ]; then
            echo "Issue #$issue_number" >&2
        fi

        echo ""  >&2
        echo "Project: https://github.com/orgs/$DEFAULT_ORG/projects/$DEFAULT_PROJECT_NUMBER" >&2
        if [ ${#label_list[@]} -gt 0 ]; then
            echo "Labels applied: ${label_list[*]}" >&2
        fi
    else
        error "Failed to create issue: $issue_url"
        exit 1
    fi
}

# List tickets
list_tickets() {
    local limit=30
    local format="json"
    local state="open"
    local label_filter=""
    local repo=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --limit)
                limit="$2"
                shift 2
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            --state)
                state="$2"
                shift 2
                ;;
            --label)
                label_filter="$2"
                shift 2
                ;;
            --repo)
                repo="$2"
                shift 2
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    check_github_auth

    local target_repo="${repo:-$DEFAULT_ORG/main}"

    info "Fetching issues from $target_repo..."

    # Build command args
    local cmd_args=(gh issue list --repo "$target_repo" --limit "$limit" --state "$state")

    if [ -n "$label_filter" ]; then
        cmd_args+=(--label "$label_filter")
    fi

    if [ "$format" = "json" ]; then
        cmd_args+=(--json "number,title,state,labels,assignees,url,createdAt,updatedAt")
        "${cmd_args[@]}" 2>&1
    else
        "${cmd_args[@]}" 2>&1
    fi
}

# Resolve GitHub Projects V2 field IDs dynamically
# Sets: PROJECT_NODE_ID, STATUS_FIELD_ID, and STATUS_OPTIONS associative array
resolve_project_ids() {
    # Get project node ID from project number
    PROJECT_NODE_ID=$(gh project list --owner "$DEFAULT_ORG" --format json | jq -r ".projects[] | select(.number == $DEFAULT_PROJECT_NUMBER) | .id")

    if [ -z "$PROJECT_NODE_ID" ] || [ "$PROJECT_NODE_ID" = "null" ]; then
        error "Could not find project #$DEFAULT_PROJECT_NUMBER for org $DEFAULT_ORG"
        exit 1
    fi

    # Get field data
    local field_data
    field_data=$(gh project field-list "$DEFAULT_PROJECT_NUMBER" --owner "$DEFAULT_ORG" --format json)

    STATUS_FIELD_ID=$(echo "$field_data" | jq -r '.fields[] | select(.name == "Status") | .id')

    if [ -z "$STATUS_FIELD_ID" ] || [ "$STATUS_FIELD_ID" = "null" ]; then
        error "Could not find Status field in project #$DEFAULT_PROJECT_NUMBER"
        exit 1
    fi

    # Build associative array of status name -> option ID
    declare -gA STATUS_OPTIONS
    while IFS=$'\t' read -r opt_name opt_id; do
        STATUS_OPTIONS["$opt_name"]="$opt_id"
    done < <(echo "$field_data" | jq -r '.fields[] | select(.name == "Status") | .options[] | [.name, .id] | @tsv')
}

# Update ticket
update_ticket() {
    local item_id=""
    local issue_number=""
    local status=""
    local field_name=""
    local field_value=""
    local add_labels=""
    local remove_labels=""
    local assignee=""
    local close_issue=false
    local repo=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --item-id)
                item_id="$2"
                shift 2
                ;;
            --issue)
                issue_number="$2"
                shift 2
                ;;
            --status)
                status="$2"
                shift 2
                ;;
            --field)
                field_name="$2"
                shift 2
                ;;
            --value)
                field_value="$2"
                shift 2
                ;;
            --add-labels)
                add_labels="$2"
                shift 2
                ;;
            --remove-labels)
                remove_labels="$2"
                shift 2
                ;;
            --assignee)
                assignee="$2"
                shift 2
                ;;
            --close)
                close_issue=true
                shift
                ;;
            --repo)
                repo="$2"
                shift 2
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Need at least an item-id or issue number
    if [ -z "$item_id" ] && [ -z "$issue_number" ]; then
        error "Either --item-id or --issue is required"
        info "Get issue numbers using: bash ./skills/ticketing-management/scripts/ticket.sh list"
        exit 1
    fi

    check_github_auth

    local target_repo="${repo:-$DEFAULT_ORG/main}"

    # Update project board status if --status provided and we have an item-id
    if [ -n "$status" ]; then
        if [ -n "$item_id" ]; then
            info "Updating project item $item_id status..."
            info "Resolving project field IDs..."
            resolve_project_ids

            local option_id="${STATUS_OPTIONS[$status]}"
            if [ -z "$option_id" ]; then
                error "Unknown status: '$status'"
                info "Available statuses:"
                for key in "${!STATUS_OPTIONS[@]}"; do
                    info "  - $key"
                done
                exit 1
            fi

            gh project item-edit \
                --project-id "$PROJECT_NODE_ID" \
                --id "$item_id" \
                --field-id "$STATUS_FIELD_ID" \
                --single-select-option-id "$option_id" 2>&1

            if [ $? -eq 0 ]; then
                success "Updated project status to: $status"
            else
                error "Failed to update project status. Try using the web interface."
            fi
        else
            warning "Skipping project status update (no --item-id provided)"
        fi

        # Auto-close issue when moving to Done
        if [ "$status" = "Done" ] && [ -n "$issue_number" ]; then
            close_issue=true
        fi
    fi

    # Update custom field if provided
    if [ -n "$field_name" ] && [ -n "$field_value" ]; then
        if [ -z "$item_id" ]; then
            error "Custom field updates require --item-id"
            exit 1
        fi

        # Resolve IDs if not already done
        if [ -z "$PROJECT_NODE_ID" ]; then
            resolve_project_ids
        fi

        local custom_field_id
        custom_field_id=$(gh project field-list "$DEFAULT_PROJECT_NUMBER" --owner "$DEFAULT_ORG" --format json | jq -r ".fields[] | select(.name == \"$field_name\") | .id")

        if [ -z "$custom_field_id" ] || [ "$custom_field_id" = "null" ]; then
            error "Could not find field: $field_name"
            exit 1
        fi

        gh project item-edit \
            --project-id "$PROJECT_NODE_ID" \
            --id "$item_id" \
            --field-id "$custom_field_id" \
            --text "$field_value" 2>&1

        if [ $? -eq 0 ]; then
            success "Updated $field_name to: $field_value"
        else
            error "Failed to update field. Check field name and try again."
        fi
    fi

    # Issue-level operations (labels, assignees, close)
    if [ -n "$issue_number" ]; then
        # Add labels
        if [ -n "$add_labels" ]; then
            info "Adding labels to issue #$issue_number..."
            gh issue edit "$issue_number" --repo "$target_repo" --add-label "$add_labels" 2>&1
            if [ $? -eq 0 ]; then
                success "Added labels: $add_labels"
            else
                error "Failed to add labels"
            fi
        fi

        # Remove labels
        if [ -n "$remove_labels" ]; then
            info "Removing labels from issue #$issue_number..."
            gh issue edit "$issue_number" --repo "$target_repo" --remove-label "$remove_labels" 2>&1
            if [ $? -eq 0 ]; then
                success "Removed labels: $remove_labels"
            else
                error "Failed to remove labels"
            fi
        fi

        # Update assignee
        if [ -n "$assignee" ]; then
            info "Assigning issue #$issue_number to $assignee..."
            gh issue edit "$issue_number" --repo "$target_repo" --add-assignee "$assignee" 2>&1
            if [ $? -eq 0 ]; then
                success "Assigned to: $assignee"
            else
                error "Failed to assign issue"
            fi
        fi

        # Close issue
        if [ "$close_issue" = true ]; then
            info "Closing issue #$issue_number..."
            gh issue close "$issue_number" --repo "$target_repo" 2>&1
            if [ $? -eq 0 ]; then
                success "Issue #$issue_number closed"
            else
                error "Failed to close issue"
            fi
        fi
    fi

    echo "" >&2
    info "View project: https://github.com/orgs/$DEFAULT_ORG/projects/$DEFAULT_PROJECT_NUMBER"
    if [ -n "$issue_number" ]; then
        info "View issue: https://github.com/$target_repo/issues/$issue_number"
    fi
}

# Setup repository labels
setup_labels() {
    local repo=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --repo)
                repo="$2"
                shift 2
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    if [ -z "$repo" ]; then
        error "Repository is required (--repo)"
        exit 1
    fi

    check_github_auth

    info "Setting up Kanban labels in $repo..."

    local all_labels=("${!LABEL_COLORS[@]}")

    for label in "${all_labels[@]}"; do
        if ! label_exists "$repo" "$label"; then
            create_label "$repo" "$label"
        else
            info "Label exists: $label"
        fi
    done

    success "All Kanban labels are set up!"
}


# Show usage
usage() {
    cat << EOF
Ticketing Management - Manage GitHub Issues with Kanban workflow
Creates repo issues linked to project #2 (https://github.com/orgs/pawpair/projects/2)

Usage: $0 <command> [options]

Commands:
  create              Create a new repo issue with labels, linked to project
  list                List issues with labels
  update              Update issue labels, assignees, status, or close
  setup-labels        Set up all Kanban labels in repository

Create Options:
  --title TEXT         Issue title (required)
  --body TEXT          Issue description
  --repo OWNER/REPO   Target repository (default: pawpair/main)
  --type TYPE          Type label: bug, feature, chore, docs, hotfix
  --priority LEVEL     Priority label: critical, high, medium, low
  --size SIZE          Size label: xs, small, medium, large, xl
  --component COMP     Component label: backend, frontend, database, infrastructure, auth, api, security, documentation, investigation
  --labels LIST        Raw comma-separated labels (overrides structured labels)
  --assignee USER      Assign to GitHub user
  --milestone NAME     Add to milestone
  --no-auto            Disable auto-suggestion of labels

List Options:
  --limit N            Limit results (default: 30)
  --format FORMAT      Output format: json (default) or table
  --state STATE        Issue state: open (default), closed, all
  --label LABEL        Filter by label
  --repo OWNER/REPO    Target repository (default: pawpair/main)

Update Options:
  --issue NUMBER       Issue number (for label/assignee/close operations)
  --item-id ID         Project item ID (for project status updates)
  --status STATUS      Update project board status (e.g., "Todo", "In Progress", "Done")
  --add-labels LIST    Comma-separated labels to add
  --remove-labels LIST Comma-separated labels to remove
  --assignee USER      Assign to GitHub user
  --close              Close the issue
  --repo OWNER/REPO    Target repository (default: pawpair/main)
  --field NAME         Custom project field name to update
  --value VALUE        Value for custom field

Setup Labels Options:
  --repo OWNER/REPO    GitHub repository (required)

Examples:
  # Create a bug with auto-suggested labels
  $0 create --title "Fix login bug"

  # Create a feature with specific labels in a specific repo
  $0 create --title "Add OAuth refresh" --repo pawpair/main \\
    --type feature --priority high --component backend --size medium

  # List open issues with labels
  $0 list --limit 50 --format json

  # List issues filtered by label
  $0 list --label "type:bug" --state open

  # Update project board status and close issue
  $0 update --issue 13 --item-id PVTI_xxx --status "Done"

  # Add labels to an issue
  $0 update --issue 13 --add-labels "priority:high,component:backend"

  # Close an issue
  $0 update --issue 13 --close

  # Set up all Kanban labels in repository
  $0 setup-labels --repo pawpair/main

EOF
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    # Load configuration
    load_config

    # Parse command
    command="$1"
    shift

    case "$command" in
        create)
            create_ticket "$@"
            ;;
        list)
            list_tickets "$@"
            ;;
        update)
            update_ticket "$@"
            ;;
        setup-labels)
            setup_labels "$@"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
