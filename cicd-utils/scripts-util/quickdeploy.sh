# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to initiate quick deployment of an already validated 
#               package.
# Author : Kiranmoy Pradhan
# Date : 12/12/2023
# --------------------------------------------------------------------------------------------------------------

# Define a function to handle deployment based on conditions
handleDeployment() {
    
    echo "------------------------------------------------------------------------------------------------------------"
    echo "|                          Deploument into Salesforce org [$AUTH_ORG_ALIAS]                                |"
    echo "------------------------------------------------------------------------------------------------------------"

    local packageXmlFilePath="changed-sources/package/package.xml"
    local deployOrgFilePath="./DEPLOY_ORG.txt"

    if [ -f DEPLOY_ORG.txt ]; then
        if grep -q '<name>ApexClass</name>' $packageXmlFilePath; then 
            VALIDATION_OUTPUT=$(cat $deployOrgFilePath) 
            DEPLOYMENT_STRING=${VALIDATION_OUTPUT#*Deploy ID: }
            FINAL_DEPLOY_ID=${DEPLOYMENT_STRING:0:18}
            echo "Final Deployment ID: $FINAL_DEPLOY_ID"
            sf project deploy quick -i "$FINAL_DEPLOY_ID" -o "$AUTH_ORG_ALIAS"
        else
            sf project deploy start -o "$AUTH_ORG_ALIAS" -x $packageXmlFilePath
        fi
    fi
}

# Initiate deployment
handleDeployment