# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to get the corresponding test class only for the changed 
#               apex classes so that it saves time during the deployment.
# Author : Kiranmoy Pradhan
# Date : 12/12/2023
# --------------------------------------------------------------------------------------------------------------


# Define testClassList globally
declare -a testClassList=()
# Define an associative array to store class names and their corresponding test class names
local -A classNamesTestClassesTable

# Function to initialize the safe directory configuration for Git and fetch origin.
fetchOrigin() {
    # Add a global configuration for the safe directory.
    git config --global --add safe.directory '*'

    # If the workflow type is PR validation, fetch the base branch from the remote repository.
    if [[ "$WORKFLOW_TYPE" == "PRVALIDATION" ]]; then
        git fetch origin "refs/heads/$BASE_BRANCH:refs/remotes/origin/$BASE_BRANCH"
    fi
}

# Function to check if the class is a test class
checkTestClass() {
    local className="$1"
    local sfdxPath="force-app/main/default"

    # Check if the file exists in the classes folder
    local classPath="$sfdxPath/classes/${className}.cls"
    if [[ -f "$classPath" ]]; then
        # Check if the file contains the @isTest annotation
        if grep -q -E '^@isTest|^@IsTest' "$classPath"; then
            return 0 # Test class
        else
            return 1 # Non-test class
        fi
    else
        # If the file is not found in the classes folder, check the triggers folder
        local triggerPath="$sfdxPath/triggers/${className}.trigger"
        if [[ -f "$triggerPath" ]]; then
            # Check if the file contains the @isTest annotation
            if grep -q -E '^@isTest|^@IsTest' "$triggerPath"; then
                return 0 # Test class
            else
                return 1 # Non-test class
            fi
        else
            return 1 # File not found
        fi
    fi
}

# Function to output the classNamesTestClassesTable in a table format
outputClassNamesTestClassesTable() {
    echo "Class Names & Test Class Name Table:"
    if [ ${#classNamesTestClassesTable[@]} -eq 0 ]; then
        echo "-----------------------------------------------------------------------"
        echo "| No classes exist in the changes, so the test classes list is empty. |"
        echo "-----------------------------------------------------------------------"
    else
        # Determine the maximum lengths of the class name and test class name
        maxClassNameLength=0
        maxTestClassNameLength=0
        for className in "${!classNamesTestClassesTable[@]}"; do
            if [ ${#className} -gt $maxClassNameLength ]; then
                maxClassNameLength=${#className}
            fi
            if [ ${#classNamesTestClassesTable[$className]} -gt $maxTestClassNameLength ]; then
                maxTestClassNameLength=${#classNamesTestClassesTable[$className]}
            fi
        done

        # Adjust the width of the columns
        classNameColumnWidth=$((maxClassNameLength + 4)) # Add some padding
        testClassNameColumnWidth=$((maxTestClassNameLength + 4)) # Add some padding

        # Output the table headers
        echo "------------------------------------------------------------------------------------------------"
        printf "| %-*s | %-*s |\n" "$classNameColumnWidth" "Class Name" "$testClassNameColumnWidth" "Test Class Name"
        echo "------------------------------------------------------------------------------------------------"

        # Output the table rows
        for className in "${!classNamesTestClassesTable[@]}"; do
            printf "| %-*s | %-*s |\n" "$classNameColumnWidth" "$className" "$testClassNameColumnWidth" "${classNamesTestClassesTable[$className]}"
            echo "------------------------------------------------------------------------------------------------"
        done
    fi
}

# Function to define the base branch based on $WORKFLOW_TYPE
defineBaseBranch() {
    local baseBranch=""
    
    if [[ "$WORKFLOW_TYPE" == "DEPLOYMENT" ]]; then
        baseBranch="HEAD^"  # Use the commit before HEAD for deployment
    elif [[ "$WORKFLOW_TYPE" == "PRVALIDATION" ]]; then
        baseBranch="origin/$BASE_BRANCH"  # Use origin/$BASE_BRANCH for PR validation
    else
        echo "Invalid WORKFLOW_TYPE specified"
        return 1
    fi

    echo "$baseBranch"
}

# Function to get the list of changed apex classes and their corresponding test classes
getChangedApexClassesAndTestClasses() {
    local classesFolderPath="force-app/main/default/classes"
    local triggerFolderPath="force-app/main/default/triggers"
    local allTestClassesFilePath="cicd-utils/testclass-util/allTestClasses.txt"
    local SPECIFIED_APEX_CLASSES=""

    # Get base branch
    local baseBranch="$(defineBaseBranch)"

    # Get the list of changed apex classes
    if [[ -d "$classesFolderPath" ]]; then
        SPECIFIED_APEX_CLASSES=$(git diff HEAD $baseBranch --name-only $classesFolderPath)
    fi

    if [[ -d "$triggerFolderPath" ]]; then
        # Append the result of git diff only if SPECIFIED_APEX_CLASSES is not empty
        changedTriggerClasses=$(git diff HEAD $baseBranch --name-only $triggerFolderPath)
        if [[ -n "$changedTriggerClasses" ]]; then
            if [[ -n "$SPECIFIED_APEX_CLASSES" ]]; then
                SPECIFIED_APEX_CLASSES+=" $changedTriggerClasses"
            else
                SPECIFIED_APEX_CLASSES="$changedTriggerClasses"
            fi
        fi
    fi

    # Iterate through the specified apex classes
    for className in $SPECIFIED_APEX_CLASSES; do
        if [[ $className == *.cls ]]; then
            # Removing prefixes and postfixes from the name so that we can get the corresponding test class
            className=${className#*force-app/main/default/classes/}
            className=${className#*force-app/main/default/triggers/}
            className=${className%%.*}

            # Check if the class is a test class
            if ! checkTestClass "$className"; then
                # Trim leading and trailing whitespace from the test class name
                testClassName=$(echo "$testClassName" | tr -d '[:space:]')
                # Find test class name only if the class is not a test class
                testClassName=$(grep "^$className," $allTestClassesFilePath | cut -d ',' -f 2)

                # Check if test class name is found and not already present in testClassList
                if [ -n "$testClassName" ] && ! [[ " ${testClassList[@]} " =~ " $testClassName " ]]; then
                    # test class list prepare for test class run
                    testClassList+=("$testClassName")
                    # Store class name and its corresponding test class name in the table for view purpose only
                    classNamesTestClassesTable["$className"]=$testClassName
                fi
            else
                # Add the class if it is test class and have changes. So that we can run it to check the coverage.
                # Check if test class name is found and not already present in testClassList
                if [ -n "$className" ] && ! [[ " ${testClassList[@]} " =~ " $className " ]]; then
                    # test class list prepare for test class run
                    testClassList+=("$className")
                fi
            fi
        else
            echo "File path does not end with .cls : $className"
        fi
    done

    # Call the function to output the classNamesTestClassesTable
    outputClassNamesTestClassesTable
}

# Function to read class names from a text file which contain the subset of all test classes in production and add them to the testClassList
addSubsetOfAllTestClasses() {
    local subsetOfAllTestClassesFilePath="cicd-utils/testclass-util/subsetOfAllTestClasses.txt"

    # Read the entire paragraph and split it by commas
    IFS=',' read -r -a classNamesArray < "$subsetOfAllTestClassesFilePath"
    # Check if classNamesArray is not empty before proceeding
    if [ "${#classNamesArray[@]}" -gt 0 ]; then
        # Add each class name to the testClassList
        for className in "${classNamesArray[@]}"; do
            # Trim leading and trailing whitespace from the class name
            className=$(echo "$className" | tr -d '[:space:]')
            # Check if test class name is found and not already present in testClassList
            if [ -n "$className" ] && ! [[ " ${testClassList[@]} " =~ " $className " ]]; then
                # Add the class name to the testClassList
                testClassList+=("$className")
            fi
        done
    fi
}

# Function to generate the final list of test classes to run
generateTestClassesListToRun() {
    local runTestClassesFilePath="cicd-utils/testclass-util/runTestClasses.txt"

    # Call the function to get changed apex classes and their corresponding test classes
    getChangedApexClassesAndTestClasses
    # Add the subset of all test classes if AUTH_ORG_ALIAS is "CI" or "Production"
    if [ "$AUTH_ORG_ALIAS" == "CI" ] || [ "$AUTH_ORG_ALIAS" == "Production" ]; then
        addSubsetOfAllTestClasses
    fi

    # Convert testClassList into comma-separated string
    local testClassString=$(IFS=,; echo "${testClassList[*]}")
    testClassString=$(echo "$testClassString" | sed 's/,/ /g')
    echo "Test classes to run for coverage: $testClassString"

    # Save the comma-separated string into cicd-utils/testclass-util/testClass.txt
    echo "$testClassString" > "$runTestClassesFilePath"
}

# Initiate test class list generation
fetchOrigin
generateTestClassesListToRun