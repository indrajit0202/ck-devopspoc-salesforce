# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to push the sfdmu data to the destination org.
# Author : Kiranmoy Pradhan
# Date : 28/02/2024
# --------------------------------------------------------------------------------------------------------------

# Function to run sfdmu process and push data into destonation org
function runSfdmuDataPush() {
    local authOrgAlias=$1
    local productionDomain=$2
    local sourceUsername="csvfile"
    local csvDataPath="cicd-utils/sfdmu/firstrun"
    local targetUsername=$authOrgAlias

    # Store the current directory
    local originalDir=$(pwd)

    echo "---------------------------------------------------------------------------------------------------"
    echo "|                                           SFDMU Data Push                                       |"
    echo "---------------------------------------------------------------------------------------------------"
    # Change directory to cicd-utils/sfdmu/firstrun
    cd cicd-utils/sfdmu/firstrun || { echo "Failed to change directory to $csvDataPath"; exit 1; }

    # Check if any CSV files have changed or new CSV files have been added in the cicd-utils/sfdmu/firstrun directory
    if git diff --name-only --diff-filter=ACMRTUXB HEAD^ HEAD | grep -qE '^cicd-utils/sfdmu/firstrun/.*\.csv$'; then

        echo "CSV files have changed or new CSV files have been added in the $csvDataPath directory. Proceeding with SFDMU data push."
        
        # Install sfdmu package
        sf plugins install sfdmu
        
        # Run sfdmu process based on source org alias
        if [ "$authOrgAlias" = "Production" ]; then
            echo "$productionDomain" | sf sfdmu:run --sourceusername "$sourceUsername" --targetusername "$targetUsername" --usesf "true"
        else
            echo 'y' | sf sfdmu:run --sourceusername "$sourceUsername" --targetusername "$targetUsername" --usesf "true"
        fi

        # Handling MissingParentRecordsReport.csv
        if [ -f MissingParentRecordsReport.csv ]; then
            cat MissingParentRecordsReport.csv
            cp MissingParentRecordsReport.csv ../../../pipeline-artifacts || { echo "Failed to copy MissingParentRecordsReport.csv to pipeline artifacts directory."; exit 1; }
        else
            echo "MissingParentRecordsReport.csv not found."
        fi

        # Handling CSVIssuesReport.csv
        if [ -f CSVIssuesReport.csv ]; then
            cat CSVIssuesReport.csv
            cp CSVIssuesReport.csv ../../../pipeline-artifacts || { echo "Failed to copy CSVIssuesReport.csv to pipeline artifacts directory."; exit 1; }
        else
            echo "No issues found."
        fi
    else
        echo "No CSV file changes or new CSV files added in the $csvDataPath directory. Skipping SFDMU data push."
    fi 
    
    # Return to the original directory
    cd "$originalDir" || { echo "Failed to return to the original directory."; exit 1; }
}

# Call the function with appropriate parameters
runSfdmuDataPush "$AUTH_ORG_ALIAS" "$PROD_ORG_DOMAIN"