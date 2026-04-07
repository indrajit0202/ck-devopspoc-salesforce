/**
 * @description       : This method is publishing the PositionUpdateEvent__e platform event with the respective 
 *                      fields.
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class PositionUpdateEventTriggerHandler extends ExtendedTriggerHandler {

    private Map<Id, Position__c> newPosIdVsPositionNameMap;
    private Map<Id, Position__c> oldPosIdVsPositionNameMap;

    /**
    * @description This constructor is setting the trigger values into the variables.
    * @author Indrajit Pal | 10-21-2024 
    **/
    public PositionUpdateEventTriggerHandler() {
        this.newPosIdVsPositionNameMap = (Map<Id, Position__c>) Trigger.newMap;
        this.oldPosIdVsPositionNameMap = (Map<Id, Position__c>) Trigger.oldMap;
    }

    /**
    * @description After update method where the platform event is getting published.
    * @author Indrajit Pal | 10-21-2024 
    **/
    public override void afterUpdate() {
        List<PositionUpdateEvent__e> eventsToPublishList = new List<PositionUpdateEvent__e>();

        try{
        // Loop through the updated records
        for (Position__c newPositionObj : newPosIdVsPositionNameMap.values()) {
            Position__c oldPositionObj = oldPosIdVsPositionNameMap.get(newPositionObj.Id);
            List<String> changedFieldsList = new List<String>();

            ChangeFieldsCheckHelper.checkFieldsOne(newPositionObj, oldPositionObj, changedFieldsList);
            ChangeFieldsCheckHelper.checkFieldsTwo(newPositionObj, oldPositionObj, changedFieldsList);

            // Create platform event if there are any changed fields
            if (!changedFieldsList.isEmpty()) {
                PositionUpdateEvent__e eventObj = createPlatformEvent(newPositionObj, changedFieldsList);
                eventsToPublishList.add(eventObj);
            }
        }

        // Publish the events
            if (!eventsToPublishList.isEmpty()) {
                EventBus.publish(eventsToPublishList);
            }
        }
        catch(Exception exObj){
            CustomExceptionHandler.logException(exObj,PositionUpdateEventTriggerHandler.class.getName());
        }
    }

    /**
    * @description Creates a PositionUpdateEvent__e platform event based on the updated Position__c record and the changed fields.
    * @param newPositionObj The new Position__c record.
    * @param changedFieldsList The list of changed fields.
    * @return PositionUpdateEvent__e The created platform event.
    **/
    public PositionUpdateEvent__e createPlatformEvent(Position__c newPositionObj, List<String> changedFieldsList) {
        return new PositionUpdateEvent__e(
            PositionID__c = newPositionObj.Id,
            UpdatedFields__c = String.join(changedFieldsList, ', '),
            UpdatedBy__c = UserInfo.getUserId(),
            Timestamp__c = System.now()
        );
    }
}