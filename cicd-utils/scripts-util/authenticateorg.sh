# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to get the org authenticate using secret url.
# Author : Kiranmoy Pradhan
# Date : 12/12/2023
# --------------------------------------------------------------------------------------------------------------

# Define a function to login to the Salesforce org using SFDX URL
# loginToSalesforceOrg() {
    # echo "------------------------------------------------------------------------------------------------------------"
    # echo "|                         Authenticate with Salesforce org [$AUTH_ORG_ALIAS]                               |"
    # echo "------------------------------------------------------------------------------------------------------------"

#     local sfdxUrlFile="./CI_SFDX_URL.txt"
#     echo "${SECRET_URL_PATH}" > "$sfdxUrlFile"
#     sf org login sfdx-url --sfdx-url-file "$sfdxUrlFile" --set-default --alias "${AUTH_ORG_ALIAS}"
# }

# # Init Salesforce authentication
# loginToSalesforceOrg


authorizeorgjwt(){
    local Cyan='\033[1;36m'
    local Red='\033[1;31m'
    echo -e "${Cyan}------------------------------------------------------------------------------------------------------------"
    echo -e "${Cyan}|                                             Authorizing Org                                              |"
    echo -e "${Cyan}------------------------------------------------------------------------------------------------------------"

    # Authenticating org using JWT
    sf org login jwt --client-id "${CLIENT_ID}" --jwt-key-file "${SECURE_FILE}" --username "${USERNAME}" --alias "${AUTH_ORG_ALIAS}" --instance-url "${INSTANCE_URL}"
}

# Initiate Auhorization
authorizeorgjwt