{!REQUIRESCRIPT("/soap/ajax/48.0/connection.js")}
{!REQUIRESCRIPT("/soap/ajax/48.0/apex.js")}
{!REQUIRESCRIPT("/resource/SweetAlert2_JS")}

// Dynamically load the CSS for SweetAlert2
var link = document.createElement("link");
link.href = "/resource/SweetAlert2_CSS"; // Path to the SweetAlert2 CSS file
link.type = "text/css";
link.rel = "stylesheet";
document.getElementsByTagName("head")[0].appendChild(link);

// Fetch record IDs
var idArray = {!GETRECORDIDS($ObjectType.Candidate__c)};

// Check if any records are selected
if (idArray.length === 0) {
    Swal.fire({
        title: 'No Records Selected',
        text: 'Please select at least one candidate record to proceed.',
        icon: 'warning',
        confirmButtonText: 'OK'
    }).then(function() {
        // No records selected, just stop execution
        return; // This `return` here will not cause issues, as it's inside a callback.
    });
} else {
    Swal.fire({
        title: 'Confirm Action',
        text: 'Resumes will be generated for the selected candidates. Do you want to continue?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Yes, Generate Resumes',
        cancelButtonText: 'Cancel'
    }).then((result) => {
        if (result.isConfirmed) {
            // Your action if the user confirmed the action (e.g., generating resumes)
            console.log(idArray.length);
            var isEligible = true;
            var data = [];

            for (var i = 0; i < idArray.length; i++) {
                var metaData = { appId: idArray[i] };
                data.push(metaData);
            }

            try {
                var status = sforce.apex.execute("CandidateResumeController", "generateResume", {
                    appIds: JSON.stringify(data)
                });
                if (status[0].indexOf('Successfully') !== -1) {
                    Swal.fire({
                        title: 'Success',
                        text: status,
                        icon: 'success',
                        confirmButtonText: 'OK'
                    });
                }
                else if (status[0].indexOf('not Eligible') !== -1) {
                    Swal.fire({
                        title: 'Ineligible Records',
                        text: status,
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                }
                else {
                    Swal.fire({
                        title: 'Success',
                        text: status,
                        icon: 'success',
                        confirmButtonText: 'OK'
                    });
                }
            } catch (error) {
                Swal.fire({
                    title: 'Error',
                    text: 'An unexpected error occurred: ' + error,
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
            }
        } else {
            // Action if the user cancels
            console.log('Action canceled');
            Swal.fire({
                title: 'Action Cancelled',
                text: 'Resume generation has been cancelled.',
                icon: 'info',
                confirmButtonText: 'OK'
            });
        }
    });
}