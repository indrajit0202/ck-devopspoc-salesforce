# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to push the skuid page changes to the destination org.
# Author : Kiranmoy Pradhan
# Date : 28/02/2024
# --------------------------------------------------------------------------------------------------------------

# Function to fetch origin and add it to safe repository
fetchOrigin() {
    git config --global --add safe.directory '*'
}

# Function to fetch changes in Skuid pages and push to Salesforce
pushSkuidPages() {
    local skuidPageFolderPath="cicd-utils/skuid-util/skuid-page"
    local SPECIFIED_SKUID_PAGES=""

    # Getting a list of Skuid pages with changes
    if [[ -d "$skuidPageFolderPath" ]]; then
        SPECIFIED_SKUID_PAGES=$(git diff HEAD HEAD^ --name-only $skuidPageFolderPath)
    fi
    
    echo "---------------------------------------------------------------------------------------------------"
    echo "|                                           Skuid Data Push                                       |"
    echo "---------------------------------------------------------------------------------------------------"
    # Iterate through all the changes in the skuidpages folder
    if [ -n "$SPECIFIED_SKUID_PAGES" ]; then
        for i in $SPECIFIED_SKUID_PAGES; do
            if [ "${i##*.}" = "xml" ]; then  # Check if file extension is .xml
                echo "Pushing changes for page $i..."
                if sf skuid:page:push --page "$i" -u "$AUTH_ORG_ALIAS"; then
                    echo "Successfully pushed changes for page $i"
                else
                    echo "Failed to push changes for page $i"
                    # Handle error scenario here (e.g., exit script, log error, etc.)
                    exit 1
                fi
            else
                echo "Skipping non-XML file: $i"
            fi
        done
    else
        echo "No Skuid page file changes or new Skuid page file added in the $skuidPageFolderPath directory. Skipping Skuid page push."
    fi
}

# Initiate git origins
fetchOrigin
# Call the function to push Skuid pages
pushSkuidPages