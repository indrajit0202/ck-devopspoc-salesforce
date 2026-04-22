# --------------------------------------------------------------------------------------------------------------
# Description : This shell script is designed to run Salesforce Code Analyzer (which includes PMD and ESLint engines) on the changed source files in a Salesforce project, generate a JSON report, and print a readable summary of the results to the pipeline log. It is intended for use in a CI/CD pipeline to enforce code quality standards before deployment.
# Author      : Indrajit Pal
# Date        : 08/04/2026
# --------------------------------------------------------------------------------------------------------------

# Exit immediately if any command fails, treat unset variables as an error, and ensure that errors in pipelines are not masked
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
readonly REPORT_DIR="pipeline-artifacts"
readonly REPORT_FILE="${REPORT_DIR}/code-analyzer-results.json"
readonly TARGET_PATH="changed-sources/force-app/main"
readonly CONFIG_FILE="cicd-utils/code-analyzer/code-analyzer.yml"

# Engines to run (pmd and eslint only — no retire-js, flow, cpd, sfge, regex)
readonly RULE_SELECTOR="pmd,eslint"

readonly SEVERITY_THRESHOLD=1

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "[INFO]  $*"; }
warn() { echo "[WARN]  $*"; }
err()  { echo "[ERROR] $*" >&2; }

separator() {
  echo "---------------------------------------------------------------------------------------------------"
}

# ---------------------------------------------------------------------------
# Build the code-analyzer run command
# ---------------------------------------------------------------------------
runCodeAnalyzer() {
  log "Starting Code Analyzer scan..."
  separator
 
  local cmd=(
    sf code-analyzer run
      --rule-selector  "${RULE_SELECTOR}"
      --workspace      "${TARGET_PATH}"
      --output-file    "${REPORT_FILE}"
      --severity-threshold "${SEVERITY_THRESHOLD}"
  )
 
  # Use custom config file if it exists (contains PMD custom ruleset path, etc.)
  if [[ -f "${CONFIG_FILE}" ]]; then
    log "Using config file: ${CONFIG_FILE}"
    cmd+=(--config-file "${CONFIG_FILE}")
  else
    warn "Config file '${CONFIG_FILE}' not found — running with defaults."
    warn "PMD custom ruleset will NOT be applied unless specified in code-analyzer.yml."
  fi
 
  # Execute — capture exit code without letting set -e kill the script
  local exitCode=0
  "${cmd[@]}" || exitCode=$?
 
  separator
  return ${exitCode}
}

# ---------------------------------------------------------------------------
# Parse the JSON report and print a readable summary to the pipeline log
# Uses only 'jq' (available in all GitHub-hosted runners by default)
# ---------------------------------------------------------------------------
printScanSummary() {
  local reportFile="$1"
 
  if [[ ! -f "${reportFile}" ]]; then
    warn "Report file not found at '${reportFile}'. Nothing to summarise."
    return
  fi
 
  separator
  echo "|       Static Code Analysis Report (PMD + ESLint)                |"
  separator
 
  # Overall counts
  local total sev1 sev2 sev3 sev4 sev5
  total=$(jq '.violationCounts.total'  "${reportFile}")
  sev1=$(jq  '.violationCounts.sev1'  "${reportFile}")
  sev2=$(jq  '.violationCounts.sev2'  "${reportFile}")
  sev3=$(jq  '.violationCounts.sev3'  "${reportFile}")
  sev4=$(jq  '.violationCounts.sev4'  "${reportFile}")
  sev5=$(jq  '.violationCounts.sev5'  "${reportFile}")
 
  echo ""
  echo "  Total Violations : ${total}"
  echo "  Critical (Sev 1) : ${sev1}"
  echo "  High     (Sev 2) : ${sev2}"
  echo "  Moderate (Sev 3) : ${sev3}"
  echo "  Low      (Sev 4) : ${sev4}"
  echo "  Info     (Sev 5) : ${sev5}"
  echo ""
 
  if [[ "${total}" -eq 0 ]]; then
    echo "  ✅  No violations found!"
    separator
    return
  fi
 
  separator
  echo "  Violation Details"
  separator
 
  # Pretty-print each violation
    jq -r '
    .violations[] |
    "  Engine           : \(.engine)\n" +
    "  ClassName        : \(.locations[.primaryLocationIndex].file | split("/") | last)\n" +
    "  Rule             : \(.rule)\n" +
    "  Line Number      : \(.locations[.primaryLocationIndex].startLine)\n" +
    "  Error Description: \(.message)"
  ' "${reportFile}"
 
  separator
  echo "  Full JSON report saved to: ${reportFile}"
  separator
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  local scanExitCode=0
 
  # Run the scan — capture the exit code separately
  runCodeAnalyzer || scanExitCode=$?
 
  # Always print summary regardless of violations found
  printScanSummary "${REPORT_FILE}"
 
  # Propagate the scanner exit code so the CI step fails correctly
  if [[ ${scanExitCode} -ne 0 ]]; then
    err "Code Analyzer exited with code ${scanExitCode}."
    err "Violations at or above severity threshold (${SEVERITY_THRESHOLD}) were found."
    exit ${scanExitCode}
  fi
 
  log "Scan completed successfully. No blocking violations found."
  exit 0
}
 
main "$@"