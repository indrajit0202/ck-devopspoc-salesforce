/**
 * @description       : This is the handler class for the trigger -> AutoGenerateResumeTrigger
 * @author            : Indrajit Pal
 * @last modified on  : 12-26-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class AutoGenerateResumeTriggerHandler extends ExtendedTriggerHandler{
    private List<Job_Application__c> newJobApplicationList;
    private Map<Id, Job_Application__c> jobAppIdVsJobAppOldMap;

    /**
    * @description Constructor which contains all the default trigger variables which 
                   are in use.
    * @author Indrajit Pal | 12-26-2024 
    **/
    public AutoGenerateResumeTriggerHandler(){
        this.newJobApplicationList = (List<Job_Application__c>) Trigger.new;
        this.jobAppIdVsJobAppOldMap = (Map<Id, Job_Application__c>) Trigger.oldMap;
    }

    /**
    * @description After update it will check for the old status of the job application and
                   the new status, then if the status is 'Schedule Interviews' then it will 
                   generate resume and attach it to the candidate object.
    * @author Indrajit Pal | 12-26-2024 
    **/
    public override void afterUpdate(){
        Set<Id> candidateIdsToProcessList = new Set<Id>();

        try{
            // Sort the Job Application ids where status is updated to 'Schedule Interviews'
            for(Job_Application__c newJobApplicationObj : newJobApplicationList){
                Job_Application__c oldJobAppObj = jobAppIdVsJobAppOldMap.get(newJobApplicationObj.Id);
                if((newJobApplicationObj.Status__c == RecruitingAppCustomConstants.JOB_APPLICATION_STATUS_SCHEDULE_INTERVIEW) 
                    && (oldJobAppObj.Status__c != RecruitingAppCustomConstants.JOB_APPLICATION_STATUS_SCHEDULE_INTERVIEW)){
                    candidateIdsToProcessList.add(newJobApplicationObj.Candidate__c);
                }
            }
            if(!candidateIdsToProcessList.isEmpty()){
                System.enqueueJob(new GenerateCandidateResumesQueueable(new List<Id>(candidateIdsToProcessList)));
            }
            else{
                throw new CustomException(RecruitingAppCustomConstants.AUTO_RESUME_GENERATE_TRIGGER_HANDLER_ERROR_MESSAGE);
            }
        } catch (Exception exObj){
            CustomExceptionHandler.logException(exObj, AutoGenerateResumeTriggerHandler.class.getName());
        }
    }
}