/**
 * @description       : 
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
public without sharing class PositionUpdateCreateLogTriggerHandler extends ExtendedTriggerHandler{
    private Map<Id, PositionUpdateEvent__e> newPositionUpdateEventMap;
    private Map<Id, PositionUpdateEvent__e> oldPositionUpdateEventMap;
    private List<PositionUpdateEvent__e> newPositionUpdateEList;
    private List<PositionUpdateEvent__e> oldPositionUpdateEList;

    /**
    * @description 
    * @author Indrajit Pal | 10-20-2024 
    **/
    public PositionUpdateCreateLogTriggerHandler(){
        this.newPositionUpdateEventMap = (Map<Id, PositionUpdateEvent__e>) Trigger.newMap;
        this.oldPositionUpdateEventMap = (Map<Id, PositionUpdateEvent__e>) Trigger.oldMap;
        this.newPositionUpdateEList = (List<PositionUpdateEvent__e>) Trigger.new;
        this.oldPositionUpdateEList = (List<PositionUpdateEvent__e>) Trigger.old;
    }

    public override void afterInsert(){
        List<Position_Update_Log__c> logs = new List<Position_Update_Log__c>();

        for(PositionUpdateEvent__e event : newPositionUpdateEList){
            Position_Update_Log__c log = new Position_Update_Log__c();
            log.Updated_position_id__c = event.PositionID__c;
            log.UpdatedFields__c = event.UpdatedFields__c;
            log.Updated_by__c = event.UpdatedBy__c;
            logs.add(log);
        }
        try{
            Database.insert(logs, true, AccessLevel.SYSTEM_MODE);
        }
        catch(Exception ex){
            CustomExceptionHandler.logException(ex, PositionUpdateCreateLogTriggerHandler.class.getName());
        }
    }
}