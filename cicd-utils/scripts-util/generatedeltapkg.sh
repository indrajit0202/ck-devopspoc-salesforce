# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to get the corresponding test class only for the changed 
#               apex classes so that it saves time during the deployment.
# Author : Kiranmoy Pradhan
# Date : 12/12/2023
# --------------------------------------------------------------------------------------------------------------

# Function to update HOME directory to root
updateHomeDirectory() {
    export HOME=/root
}

# Function to initialize the safe directory configuration for Git and fetch origin.
fetchOrigin() {
    # Add a global configuration for the safe directory.
    git config --global --add safe.directory '*'

    # If the workflow type is PR validation, fetch the base branch from the remote repository.
    if [[ "$WORKFLOW_TYPE" == "PRVALIDATION" ]]; then
        git fetch origin "refs/heads/$BASE_BRANCH:refs/remotes/origin/$BASE_BRANCH"
    fi
}

# Function to create directories for storing generated delta files and pipeline artifacts
createDirectories() {
    # This directory will contain the package.xml and destructiveChanges.xml file
    mkdir changed-sources
    # Create pipeline-artifacts directory will contain artifact related folder/files and adding the pmd report container csv file inside it
    mkdir pipeline-artifacts
    touch pipeline-artifacts/pmd-results.csv
    # Create the runTestClasses file inside the testclass-util folder which will contain all the test classes  taht will run during validation process
    touch cicd-utils/testclass-util/runTestClasses.txt
}

# Function to execute command to get the delta package validated
executeDeltaValidation() {
    local sgdIgnoreFilePath="cicd-utils/sgddelta-util/.sgdignore"
    local changedSourceFolderPath="changed-sources/"
    local packageXmlFilePath="changed-sources/package/package.xml"
    local destructiveChangesXmlFilePath="changed-sources/destructiveChanges/destructiveChanges.xml"

    # Define the --from parameter based on $WORKFLOW_TYPE
    if [[ "$WORKFLOW_TYPE" == "DEPLOYMENT" ]]; then
        from="HEAD^"  # Use the commit before HEAD for deployment
    elif [[ "$WORKFLOW_TYPE" == "PRVALIDATION" ]]; then
        from="origin/$BASE_BRANCH"  # Use origin/$BASE_BRANCH for PR validation
    else
        echo "Invalid WORKFLOW_TYPE specified"
        return 1
    fi
    
    # Execute sf sgd:source:delta command
    sf sgd:source:delta --to HEAD --from "$from" --output $changedSourceFolderPath -i $sgdIgnoreFilePath --generate-delta
}

# Function to print the output to the console
printDeltaPackageDetails() {
    # Added & modified components
    echo "------------------------------------------------------------------------------------------------------------"
    echo "|                      package.xml (generated with added and modified metadata)                            |"
    echo "------------------------------------------------------------------------------------------------------------"
    cat changed-sources/package/package.xml
    echo

    # Deleted components
    echo "------------------------------------------------------------------------------------------------------------"
    echo "|                      destructiveChanges.xml (generated with deleted metadata)                 |"
    echo "------------------------------------------------------------------------------------------------------------"
    cat changed-sources/destructiveChanges/destructiveChanges.xml
    echo
}

# Initiate delta package generation
updateHomeDirectory
fetchOrigin
createDirectories
executeDeltaValidation
printDeltaPackageDetails