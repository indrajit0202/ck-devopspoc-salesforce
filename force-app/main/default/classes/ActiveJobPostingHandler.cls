/**
 * @description       : This class is the handler class for the job posting display LWC component and the purpose is to fetch all the active job postings according to needs.
 * @author            : Indrajit Pal
 * @last modified on  : 12-27-2024
 * @last modified by  : Indrajit Pal
**/
public with sharing class ActiveJobPostingHandler {
    public static final string NO_ACTIVE_JOB_POSTING_FOUND = 'No Active Job Postings Found';
    public static final string NO_JOB_POSTINGS_FOUND = 'No Job Postings Found for this Department';

    /**
    * @description This method will return all the job postings whose positions where the status is open - approved
    * @author Indrajit Pal | 11-09-2024 
    * @return List<Job_Posting__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Job_Posting__c> getActiveJobPosting(){
        try {
            List<Job_Posting__c> activeJobPostingList = [SELECT Id, 
                                                            Position__r.Id, 
                                                            Name, 
                                                            Position__r.Name, 
                                                            Position__r.Location__c, 
                                                            Position__r.Functional_Area__c,
                                                            CreatedDate
                                                        FROM Job_Posting__c 
                                                        WHERE Position__r.Status__c =: RecruitingAppCustomConstants.POSITION_STATUS_OPEN_APPROVED
                                                        WITH SECURITY_ENFORCED];
            if(activeJobPostingList.size() == 0 || activeJobPostingList == null){
                throw new AuraHandledException(NO_ACTIVE_JOB_POSTING_FOUND);
            }
            return activeJobPostingList;
        } catch (AuraHandledException aheObj) {
            throw aheObj;  
        } catch (Exception exObj) {
            CustomExceptionHandler.logException(exObj, ActiveJobPostingHandler.class.getName()); 
            throw new AuraHandledException(exObj.getMessage());
        }
    }

    /**
    * @description This method will return the job postings whose position department is equal to the given department
    * @author Indrajit Pal | 11-10-2024 
    * @param department 
    * @return List<Job_Posting__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Job_Posting__c> getJobPostingsByDepartment(String department) {
        try {
            List<Job_Posting__c> filteredJobPostingList = [
                                                        SELECT Id, 
                                                            Position__r.Id,
                                                            Name, 
                                                            Position__r.Name, 
                                                            Position__r.Location__c, 
                                                            Position__r.Functional_Area__c, 
                                                            CreatedDate
                                                        FROM Job_Posting__c 
                                                        WHERE Position__r.Status__c =: RecruitingAppCustomConstants.POSITION_STATUS_OPEN_APPROVED
                                                        AND Position__r.Functional_Area__c = :department
                                                        WITH SYSTEM_MODE
                                                    ];
            if (filteredJobPostingList.isEmpty()) {
                throw new AuraHandledException(NO_JOB_POSTINGS_FOUND);
            }
            return filteredJobPostingList;
        } catch (AuraHandledException aheObj) {
            throw aheObj; 
        } 
    }

    /**
    * @description Returns all the departments present in the posting object
    * @author Indrajit Pal | 11-10-2024 
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> getAllPositionDepartments(){
        try {
            return ActiveJobPostingHelper.allPositionDepartments();
        } catch (Exception exObj) {
            throw new AuraHandledException(exObj.getMessage());
        }
    }
}