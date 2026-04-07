/**
 * @description       : This trigger is on the PositionUpdateEvent__e platform event and sending the email to the candidate.
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
trigger PositionUpdateSendMailTrigger on PositionUpdateEvent__e (after insert) {
    new PositionUpdateSendMailTriggerHandler().execute();
}