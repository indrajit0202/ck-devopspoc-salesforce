# ─────────────────────────────────────────────────────────────────────────────
# Utility   : Logger
# Purpose   : Common logging and command execution functions
#             to be sourced by other shell scripts
# Usage     : source ./cicd-utils/scripts-util/logger.sh
# ─────────────────────────────────────────────────────────────────────────────

# Debug mode — controlled via GitHub Actions variable (Settings → Variables → DEBUG)
DEBUG=${DEBUG:-false}

log_info()  { echo "✅ $1"; }
log_error() { echo "❌ ERROR: $1" >&2; exit 1; }

run_cmd() {
    local success_msg="$1" error_msg="$2"; shift 2
    if [ "$DEBUG" = "true" ]; then
        "$@" || log_error "$error_msg"
    else
        "$@" > /dev/null 2>&1 || log_error "$error_msg"
    fi
    log_info "$success_msg"
}