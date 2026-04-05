
# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to pull the skuid page changes from the source org.
# Author : Kiranmoy Pradhan
# Date : 27/02/2024
# --------------------------------------------------------------------------------------------------------------

# Function to pull Skuid pages using Salesforce CLI
pullSkuidPages() {
    local SKUID_PAGES_FILE="./cicd-utils/skuid-util/skuid-page/skuidPages.txt"
    local SPECIFIED_SKUID_PAGES 
    
    echo "---------------------------------------------------------------------------------------------------"
    echo "|                                        Skuid Pages Pull                                         |"
    echo "---------------------------------------------------------------------------------------------------"
    # Read Skuid pages from file
    SPECIFIED_SKUID_PAGES=$(cat "$SKUID_PAGES_FILE")

    # Loop through each Skuid page and pull it
    for i in $SPECIFIED_SKUID_PAGES; do
        echo "Pulled $i page"
        sf skuid:page:pull --page "$i"
    done
}

# Call the function to pull Skuid pages
pullSkuidPages