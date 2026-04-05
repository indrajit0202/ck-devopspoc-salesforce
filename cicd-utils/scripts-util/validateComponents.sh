# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to make the package ready for deployment by validation.
# Author : Kiranmoy Pradhan
# Date : 12/12/2023
# --------------------------------------------------------------------------------------------------------------

# Define a function for delta check-only deployment
performDeltaCheckOnlyDeployment() {

    echo "---------------------------------------------------------------------------------------------------"
    echo "|                                      Component Validation                                       |"
    echo "---------------------------------------------------------------------------------------------------"

    local packageXmlFilePath="changed-sources/package/package.xml"
    local runTestClassesFilePath="./cicd-utils/testclass-util/runTestClasses.txt"
    local deployOrgFilePath="./DEPLOY_ORG.txt"

    # Checking if any metadata changes are in package.xml
    if grep -q '<types>' $packageXmlFilePath; then
        # Initiating async deployment.
        if grep -q '<name>ApexClass</name>' $packageXmlFilePath; then
            # Initiating async deployment with RunSpecifiedTests.
            sf project deploy start -o $AUTH_ORG_ALIAS -x $packageXmlFilePath -l RunSpecifiedTests -t $(cat $runTestClassesFilePath) --verbose --dry-run --async | tee $deployOrgFilePath
        else
            # Initiating async deployment without specifying test classes.
            sf project deploy start -o $AUTH_ORG_ALIAS -x $packageXmlFilePath --verbose --dry-run --async | tee $deployOrgFilePath
        fi
        
        # Fetching Deploy Id from the output.
        VALIDATION_OUTPUT=$(cat $deployOrgFilePath) 
        DEPLOYMENT_STRING=${VALIDATION_OUTPUT#*Deploy ID: }
        echo $DEPLOYMENT_STRING
        FINAL_DEPLOY_ID=${DEPLOYMENT_STRING:0:18}
        echo $FINAL_DEPLOY_ID

        # Watch the deployment for validation.
        sf project deploy resume --job-id $FINAL_DEPLOY_ID --coverage-formatters cobertura --junit --results-dir "pipeline-artifacts" --verbose

        DEPLOY_EXIT_CODE=${PIPESTATUS[0]}
        if [ $DEPLOY_EXIT_CODE != 0 ]; then
            exit $DEPLOY_EXIT_CODE;
        fi
    else
        echo "Empty package.xml file."
        exit 0
    fi
}

# Initiate component validation
performDeltaCheckOnlyDeployment