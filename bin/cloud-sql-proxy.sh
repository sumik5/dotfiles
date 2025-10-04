#!/usr/bin/env bash
#
# cloud-sql-proxy.sh - Interactive wrapper for Cloud SQL Proxy
#
# Description:
#   Provides an interactive interface to select and connect to Cloud SQL instances
#   using fzf (preferred) or bash select (fallback).
#
# Usage:
#   cloud-sql-proxy.sh [OPTIONS]
#
# Options:
#   -h, --help    Show this help message
#

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

#######################################
# Print error message to stderr
# Arguments:
#   Error message
#######################################
error() {
    echo -e "${RED}Error: $*${NC}" >&2
}

#######################################
# Print info message
# Arguments:
#   Info message
#######################################
info() {
    echo -e "${GREEN}$*${NC}"
}

#######################################
# Print warning message
# Arguments:
#   Warning message
#######################################
warn() {
    echo -e "${YELLOW}Warning: $*${NC}"
}

#######################################
# Show help message
#######################################
show_help() {
    cat << 'EOF'
cloud-sql-proxy.sh - Interactive wrapper for Cloud SQL Proxy

USAGE:
    cloud-sql-proxy.sh [OPTIONS]

OPTIONS:
    -h, --help    Show this help message

DESCRIPTION:
    Provides an interactive interface to select and connect to Cloud SQL instances.
    Uses fzf for selection if available, otherwise falls back to bash select.

REQUIREMENTS:
    - gcloud CLI must be installed and configured
    - cloud-sql-proxy must be installed and in PATH

EXAMPLES:
    # Start interactive selection
    cloud-sql-proxy.sh

    # Show help
    cloud-sql-proxy.sh --help

EOF
}

#######################################
# Check if required commands are available
# Returns:
#   0 if all required commands are available, 1 otherwise
#######################################
check_dependencies() {
    local missing_deps=()

    if ! command -v gcloud &> /dev/null; then
        missing_deps+=("gcloud")
    fi

    if ! command -v cloud-sql-proxy &> /dev/null; then
        missing_deps+=("cloud-sql-proxy")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install the missing dependencies:" >&2
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                gcloud)
                    echo "  - gcloud: https://cloud.google.com/sdk/docs/install" >&2
                    ;;
                cloud-sql-proxy)
                    echo "  - cloud-sql-proxy: https://cloud.google.com/sql/docs/mysql/sql-proxy" >&2
                    ;;
            esac
        done
        return 1
    fi

    return 0
}

#######################################
# Get list of Cloud SQL instances
# Returns:
#   List of instances in format PROJECT_ID:REGION:INSTANCE_NAME
#######################################
get_sql_instances() {
    local instances
    local filtered_instances

    # Output info message to stderr to avoid contaminating the return value
    echo -e "${GREEN}Fetching Cloud SQL instances...${NC}" >&2

    # Get instances list with additional filtering
    # - Only fetch RUNNABLE instances
    # - Get connectionName in value format
    # - Suppress stderr to avoid noise
    if ! instances=$(gcloud sql instances list \
        --filter="state=RUNNABLE" \
        --format="value(connectionName)" \
        2>/dev/null); then
        error "Failed to fetch Cloud SQL instances"
        error "Please check your gcloud authentication and permissions"
        return 1
    fi

    # Filter out invalid entries:
    # 1. Remove empty lines
    # 2. Only keep lines matching PROJECT_ID:REGION:INSTANCE_NAME format
    # 3. Ensure all parts contain only valid characters (alphanumeric and hyphens)
    filtered_instances=$(echo "$instances" | \
        grep -v '^[[:space:]]*$' | \
        grep -E '^[a-z0-9][a-z0-9-]*:[a-z0-9][a-z0-9-]*:[a-z0-9][a-z0-9-]*$')

    # Check if any valid instances were found
    if [ -z "$filtered_instances" ]; then
        error "No runnable Cloud SQL instances found"
        # Output info message to stderr
        echo -e "${GREEN}Please create a Cloud SQL instance or check your project permissions${NC}" >&2
        return 1
    fi

    echo "$filtered_instances"
}

#######################################
# Validate instance name format
# Arguments:
#   Instance connection name (PROJECT_ID:REGION:INSTANCE_NAME)
# Returns:
#   0 if valid, 1 otherwise
#######################################
validate_instance_name() {
    local instance="$1"

    # Check format: PROJECT_ID:REGION:INSTANCE_NAME
    if [[ ! "$instance" =~ ^[a-z0-9-]+:[a-z0-9-]+:[a-z0-9-]+$ ]]; then
        error "Invalid instance format: $instance"
        error "Expected format: PROJECT_ID:REGION:INSTANCE_NAME"
        return 1
    fi

    return 0
}

#######################################
# Detect database type from instance name
# Arguments:
#   Instance connection name
# Returns:
#   Database type (postgres or mysql)
#######################################
detect_database_type() {
    local instance="$1"
    local db_version

    # Get database version from gcloud
    db_version=$(gcloud sql instances describe "${instance##*:}" \
        --format="value(databaseVersion)" 2>/dev/null || echo "POSTGRES")

    # Determine database type from version string
    if [[ "$db_version" =~ ^MYSQL ]]; then
        echo "mysql"
    else
        echo "postgres"
    fi
}

#######################################
# Get default port for database type
# Arguments:
#   Database type (postgres or mysql)
# Returns:
#   Default port number
#######################################
get_default_port() {
    local db_type="$1"

    case "$db_type" in
        mysql)
            echo "3306"
            ;;
        postgres)
            echo "5432"
            ;;
        *)
            echo "5432"  # Default to PostgreSQL port
            ;;
    esac
}

#######################################
# Check if a port is available
# Arguments:
#   Port number
# Returns:
#   0 if available, 1 if in use
#######################################
check_port_available() {
    local port="$1"

    # Try lsof first (more reliable and available on macOS)
    if command -v lsof &> /dev/null; then
        ! lsof -i ":$port" &> /dev/null
        return $?
    fi

    # Fallback to netstat (Linux)
    if command -v netstat &> /dev/null; then
        ! netstat -tuln 2>/dev/null | grep -q ":$port "
        return $?
    fi

    # If neither command is available, assume port is available
    warn "Cannot check port availability (lsof and netstat not found)"
    return 0
}

#######################################
# Find an available port starting from the default
# Arguments:
#   Default port number
# Returns:
#   Available port number, or empty string if none found
#######################################
find_available_port() {
    local start_port="$1"
    local max_attempts=10
    local current_port="$start_port"

    for ((i=0; i<max_attempts; i++)); do
        if check_port_available "$current_port"; then
            echo "$current_port"
            return 0
        fi
        current_port=$((current_port + 1))
    done

    # No available port found
    return 1
}

#######################################
# Select instance using fzf or bash select
# Arguments:
#   List of instances (one per line)
# Returns:
#   Selected instance name
#######################################
select_instance() {
    local instances="$1"
    local selected_instance

    if command -v fzf &> /dev/null; then
        # Use fzf for interactive selection
        # Output info message to stderr to avoid contaminating fzf output
        echo -e "${GREEN}Select a Cloud SQL instance (use arrow keys):${NC}" >&2
        if ! selected_instance=$(echo "$instances" | fzf \
            --prompt="Cloud SQL Instance > " \
            --height=40% \
            --border \
            --reverse); then
            warn "Selection cancelled"
            return 1
        fi
    else
        # Fallback to bash select
        warn "fzf not found, using basic selection menu"
        info "Select a Cloud SQL instance (enter number):"

        # Convert instances to array
        local -a instance_array
        mapfile -t instance_array <<< "$instances"

        select selected_instance in "${instance_array[@]}"; do
            if [ -n "$selected_instance" ]; then
                break
            else
                error "Invalid selection, please try again"
            fi
        done
    fi

    # Check if selection was made
    if [ -z "$selected_instance" ]; then
        error "No instance selected"
        return 1
    fi

    echo "$selected_instance"
}

#######################################
# Run cloud-sql-proxy with selected instance
# Arguments:
#   Instance connection name
#######################################
run_proxy() {
    local instance="$1"
    local db_type
    local default_port
    local available_port

    # Detect database type and get default port
    db_type=$(detect_database_type "$instance")
    default_port=$(get_default_port "$db_type")

    info "Database type detected: $db_type"
    info "Default port: $default_port"

    # Find an available port
    if ! available_port=$(find_available_port "$default_port"); then
        error "No available ports found in range $default_port-$((default_port + 9))"
        error "Please close some applications using these ports and try again"
        return 1
    fi

    # Notify user if using non-default port
    if [ "$available_port" != "$default_port" ]; then
        warn "Port $default_port is in use. Using port $available_port instead."
    else
        info "Using default port: $available_port"
    fi

    info "Starting Cloud SQL Proxy for: $instance"
    info "Connection details:"
    info "  Host: 127.0.0.1"
    info "  Port: $available_port"
    info "Press Ctrl+C to stop the proxy"
    echo ""

    # Run cloud-sql-proxy with the available port
    # shellcheck disable=SC2086
    exec cloud-sql-proxy "--port=$available_port" "$instance"
}

#######################################
# Main function
#######################################
main() {
    # Parse command line arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac

    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi

    # Get instances list
    local instances
    if ! instances=$(get_sql_instances); then
        exit 1
    fi

    # Select instance
    local selected_instance
    if ! selected_instance=$(select_instance "$instances"); then
        exit 1
    fi

    # Validate instance name
    if ! validate_instance_name "$selected_instance"; then
        exit 1
    fi

    # Run proxy
    run_proxy "$selected_instance"
}

# Execute main function
main "$@"
