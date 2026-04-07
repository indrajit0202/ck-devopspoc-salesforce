/**
 * @description       : This is the trigger on Job applications which will automatically generate resumes and attach it to
 *                      the respective candidate object when the status of the job application is updated to 'Schedule Interviews'
 *                      The trigger handler from this trigger will again call the GenerateCandidateResumesQueueable class to 
 *                      generate resumes. 
 * @author            : Indrajit Pal
 * @last modified on  : 12-26-2024
 * @last modified by  : Indrajit Pal
**/
trigger AutoGenerateResumeTrigger on Job_Application__c (after update) {
    new AutoGenerateResumeTriggerHandler().execute();
}