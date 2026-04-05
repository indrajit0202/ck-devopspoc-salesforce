# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to pull the data from source org using sfdmu.
# Author : Kiranmoy Pradhan
# Date : 28/02/2024
# --------------------------------------------------------------------------------------------------------------

# Define a function to run the Salesforce Data Migration Utility (SFDMU)
runSFDMU() {
    local sourceUsername="$1"
    local exportJsonPath="./cicd-utils/sfdmu/firstrun"

    echo "---------------------------------------------------------------------------------------------------"
    echo "|                                        SFDMU Data Pull                                          |"
    echo "---------------------------------------------------------------------------------------------------"

    # Check if sourceUsername is null
    if [ -z "$sourceUsername" ]; then
        echo "Error: Source username cannot be empty"
        return 1
    fi

    # Run SFDMU command
    if ! sf sfdmu:run -s "$sourceUsername" -u csvfile -p "$exportJsonPath"; then
        echo "Error: SFDMU command failed"
        return 1
    fi
}

# Prompt user for source username
read -rp "Enter source org username/alias: " sourceUser

# Call the function with provided username
if ! runSFDMU "$sourceUser"; then
    echo "SFDMU execution failed"
    exit 1
fi




