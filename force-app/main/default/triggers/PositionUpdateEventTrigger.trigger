/**
 * @description       : Trigger for the Position Update Platfrom Event
 * @author            : Indrajit Pal
 * @last modified on  : 12-12-2024
 * @last modified by  : Indrajit Pal
**/
trigger PositionUpdateEventTrigger on Position__c (after update) {
    new PositionUpdateEventTriggerHandler().execute();
}