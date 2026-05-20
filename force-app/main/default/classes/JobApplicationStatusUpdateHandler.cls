/**
 * @description       : Handler method to handle the job application status update.
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class JobApplicationStatusUpdateHandler {

    /**
    * @description This method makes the changes in the status for the job applications.
    * @author Indrajit Pal | 12-17-2024 
    * @param jobApplicationList 
    **/
    public static void updateJobApplicationStatus(List<Job_Application__c> jobApplicationList){
        List<Job_Application__c> jobApplicationUpdateList = new List<Job_Application__c>();
        try{
            Map<String, Job_Application_Status_Update_Setting__mdt> ruleNameVSMetadata = Job_Application_Status_Update_Setting__mdt.getAll();
            for(Job_Application__c jobApplicationObj : jobApplicationList){
                if(ruleNameVSMetadata.containsKey(RecruitingAppCustomConstants.INACTIVE_APPLICANT_RULE_NAME)){
                    updateInactiveStatusIfStale(jobApplicationObj, jobApplicationUpdateList, 
                    ruleNameVSMetadata.get(RecruitingAppCustomConstants.INACTIVE_APPLICANT_RULE_NAME));
                }
                if(ruleNameVSMetadata.containsKey(RecruitingAppCustomConstants.APPLICATION_WITHDRAWN_RULE_NAME)){
                    markWithdrawnIfUninterested(jobApplicationObj, jobApplicationUpdateList,
                    ruleNameVSMetadata.get(RecruitingAppCustomConstants.APPLICATION_WITHDRAWN_RULE_NAME));
                }
                if(ruleNameVSMetadata.containsKey(RecruitingAppCustomConstants.NOT_SELECTED_AFTER_INTERVIEW_RULE_NAME)){
                    updateStatusToNotSelected(jobApplicationObj, jobApplicationUpdateList,
                    ruleNameVSMetadata.get(RecruitingAppCustomConstants.NOT_SELECTED_AFTER_INTERVIEW_RULE_NAME));
                }
            }
            Database.update(jobApplicationList, true, AccessLevel.SYSTEM_MODE);
        }
        catch(Exception exObj){
            CustomExceptionHandler.logException(exObj, JobApplicationStatusUpdateHandler.class.getName()); 
        }
    }

    /**
    * @description This method checks for the last modified date of the job application and 
                   if last modified date - todays date is greater than 30 then change the status to inactive.
    * @author Indrajit Pal | 12-18-2024 
    * @param jobApplicationObj 
    * @param jobApplicationUpdateList 
    * @param inactiveRule 
    **/
    public static void updateInactiveStatusIfStale(Job_Application__c jobApplicationObj, List<Job_Application__c> jobApplicationUpdateList,
                                            Job_Application_Status_Update_Setting__mdt inactiveRule){
        if (jobApplicationObj.LastModifiedDate.date().daysBetween(Date.today()) > inactiveRule.DaysSinceLastActivity__c
            && jobApplicationObj.Candidate__r.No_Longer_Interested__c == inactiveRule.Candidate_no_longer_interested__c && inactiveRule.Active__c) {
            jobApplicationObj.Status__c = inactiveRule.NewStatus__c;
        }
        jobApplicationUpdateList.add(jobApplicationObj);
    }

    /**
    * @description This method updates the status of applicants who have indicated they are no longer interested (via a checkbox on the candidate record) to "Withdrawn."
    * @param jobApplicationObj Job Application obj on which the checking the condition.
    * @param jobApplicationUpdateList List to hold updated job application records for further processing.
    * @param withdrawnRule
    **/
    public static void markWithdrawnIfUninterested(Job_Application__c jobApplicationObj, List<Job_Application__c> jobApplicationUpdateList,
                                            Job_Application_Status_Update_Setting__mdt withdrawnRule) {
        if(jobApplicationObj.Candidate__r.No_Longer_Interested__c && withdrawnRule.Active__c
           && withdrawnRule.CurrentStatus__c == jobApplicationObj.Status__c){
            jobApplicationObj.Status__c = withdrawnRule.NewStatus__c;
        }
        jobApplicationUpdateList.add(jobApplicationObj);
    }    

    /**
    * @description This method checks for the interview date and the status and if the interview date is less than 14 days from today then change the status to not selected.
    * @author Indrajit Pal | 12-17-2024 
    * @param jobApplicationObj 
    * @param jobApplicationUpdateList 
    * @param notSelectedRule
    **/
    public static void updateStatusToNotSelected(Job_Application__c jobApplicationObj, List<Job_Application__c> jobApplicationUpdateList,
                                          Job_Application_Status_Update_Setting__mdt notSelectedRule){
        if(jobApplicationObj.Job_Interview_Date__c.date()!= null 
           && (jobApplicationObj.Job_Interview_Date__c.date().daysBetween(Date.today())) > notSelectedRule.DaysSinceInterview__c 
           && jobApplicationObj.Status__c == notSelectedRule.CurrentStatus__c && notSelectedRule.Active__c 
           && jobApplicationObj.Candidate__r.No_Longer_Interested__c == notSelectedRule.Candidate_no_longer_interested__c){
            jobApplicationObj.Status__c = notSelectedRule.NewStatus__c;
        }
        jobApplicationUpdateList.add(jobApplicationObj);
    }
}