/**
 * @description       : This is a trigger handler class, executes when some field is updated in position object then 
 *                      it will listin to the platform event and send mails to the candidates related to all the job 
 *                      applications who have applied under that position.
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class PositionUpdateSendMailTriggerHandler extends ExtendedTriggerHandler{
    private Map<Id, PositionUpdateEvent__e> idVsPosUpdteEvntNewMap;
    private Map<Id, PositionUpdateEvent__e> idVsPosUpdteEvntOldMap;
    private List<PositionUpdateEvent__e> newPositionUpdteEventList;
    private List<PositionUpdateEvent__e> oldPositionUpdteEventList;

    /**
    * @description Constructor which contains all the default trigger variables
    * @author Indrajit Pal | 10-20-2024 
    **/
    public PositionUpdateSendMailTriggerHandler(){
        this.idVsPosUpdteEvntNewMap = (Map<Id, PositionUpdateEvent__e>) Trigger.newMap;
        this.idVsPosUpdteEvntOldMap = (Map<Id, PositionUpdateEvent__e>) Trigger.oldMap;
        this.newPositionUpdteEventList = (List<PositionUpdateEvent__e>) Trigger.new;
        this.oldPositionUpdteEventList = (List<PositionUpdateEvent__e>) Trigger.old;
    }

    /**
    * @description After insert method where the notification mail will be send to candidates when a position update platform 
                   event record is inserted.
    * @author Indrajit Pal | 10-27-2024 
    **/
    public override void afterInsert(){
        Map<Id, String> posIdVsUpdtedValuesStrMap = new Map<Id, String>();
        
        try{
            for(PositionUpdateEvent__e eventObj : newPositionUpdteEventList){
                posIdVsUpdtedValuesStrMap.put(eventObj.PositionID__c, eventObj.UpdatedFields__c);
            }
            
            List<Job_Application__c> jobApplicationsList = getJobApplications(posIdVsUpdtedValuesStrMap.keySet());
            PositionUpdateMailController.sendEmail(jobApplicationsList, posIdVsUpdtedValuesStrMap);
        }
        catch(Exception exObj){
            CustomExceptionHandler.logException(exObj, PositionUpdateSendMailTriggerHandler.class.getName());
        }
    }

    /**
    * @description Get all the job application records related to the position list given.
    * @author Indrajit Pal | 10-21-2024 
    * @param positionIds 
    * @return List<Job_Application__c> 
    **/
    public static List<Job_Application__c> getJobApplications(Set<Id> positionIds){

        List<Job_Application__c> jobApplicationList = [SELECT Candidate__r.Email__c,
                                                            Candidate__r.First_Name__c, 
                                                            Candidate__r.Last_Name__c,
                                                            Position__r.Id,
                                                            Position__r.Name
                                                        FROM Job_Application__c  
                                                        WHERE 
                                                        Position__c IN :positionIds
                                                        WITH SECURITY_ENFORCED];
        return jobApplicationList;
    }
}