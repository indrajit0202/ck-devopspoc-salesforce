# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to get the org authenticate using secret url.
# Author : Kiranmoy Pradhan
# Date : 12/12/2023
# --------------------------------------------------------------------------------------------------------------

# Define a function to login to the Salesforce org using SFDX URL
loginToSalesforceOrg() {
    echo "------------------------------------------------------------------------------------------------------------"
    echo "|                         Authenticate with Salesforce org [$AUTH_ORG_ALIAS]                               |"
    echo "------------------------------------------------------------------------------------------------------------"

    local sfdxUrlFile="./CI_SFDX_URL.txt"
    echo "${SECRET_URL_PATH}" > "$sfdxUrlFile"
    sf org login sfdx-url --sfdx-url-file "$sfdxUrlFile" --set-default --alias "${AUTH_ORG_ALIAS}"
}

# Init Salesforce authentication
loginToSalesforceOrg