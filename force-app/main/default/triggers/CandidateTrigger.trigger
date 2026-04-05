/**
 * @description       : Trigger for the sending email to the new candidate
 * @author            : Indrajit Pal
 * @last modified on  : 12-26-2024
 * @last modified by  : Indrajit Pal
**/
trigger CandidateTrigger on Candidate__c (after insert) {
    new CandidateSendEmailTriggerHandler().execute();
}