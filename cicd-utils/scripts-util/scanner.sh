# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to get the pmd executed for code quality validation
# Author : Kiranmoy Pradhan
# Date : 12/12/2023
# --------------------------------------------------------------------------------------------------------------

# Function to read the CSV content and print classname, PMD error, and error description for each issue
showPmdIssues() {
    # Loop through each line of the CSV file
    tail -n +2 "$1" | while IFS=, read -r _ _ _ classPath lineNumber _ pmdError errorDescription _; do
        # Extract classname
        className=$(basename "$classPath")
        # Print classname, PMD error, and error description
        echo "ClassName: \"$className"
        echo "PMD Error: $pmdError"
        echo "Line Nuber: $lineNumber"
        echo "Error Description: $errorDescription"
        echo "---------------------------------------------------------------------------------------------------"
    done
}

# Execute PMD scan and display results
executeScannerAndShowResult() {
    local pmdRulePath="cicd-utils/pmd-util/pmd-rule/pmdRules.xml"
    local pmdReportPath="pipeline-artifacts/pmd-results.csv"
    local forceAppMainFolderPath="changed-sources/force-app/main"
    local scanEngineName="pmd"
    local reportFileType="csv"

    # Execute the PMD scanner command
    sf scanner:run --engine "$scanEngineName" \
                   --format "$reportFileType" \
                   --pmdconfig "$pmdRulePath" \
                   --outfile "$pmdReportPath" \
                   --target "$forceAppMainFolderPath" \
                   --normalize-severity

    # Displaying code scan report
    echo "---------------------------------------------------------------------------------------------------"
    echo "|                                   Static Code Scan (PMD) Report                                 |"
    echo "---------------------------------------------------------------------------------------------------"

    # Call function to print classname, PMD error, and error description for each issue
    showPmdIssues "$pmdReportPath"
}

# Initiate static code analysis (PMD) and display results
executeScannerAndShowResult
