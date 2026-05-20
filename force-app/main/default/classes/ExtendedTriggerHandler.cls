/**
 * @description       : This class demonstrates how to use the ExtendedTriggerHandler class
 *                      which is used as an extention to the base TriggerHandler class and provide additional functionalities
 * @author            : Mainak Gupta
 * @group             : 
 * @last modified on  : 12-27-2024
 * @last modified by  : Indrajit Pal
**/
public with sharing virtual class ExtendedTriggerHandler extends TriggerHandler{
    /**
    * @description : This method is used to enable/disable the trigger per object. 
    *                For Example, if you want to disable the trigger for Contact object, 
    *                you just need to create a Custom MetaData/ Custom Setting record 
    *                and set value to true.
    * @author Mainak Gupta | 08-22-2024 
    * @return virtual 
    **/
    protected virtual boolean isTriggerEnabled(){
        String objectName = String.valueOf(Trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType());
        Boolean executeTrigger = false;
        // check metadata and check object trigger disble is off
        List<sobject_Trigger_Manager__mdt> triggerSettingList = [SELECT Id,
                                                                        disable_trigger__c
                                                                    FROM sobject_Trigger_Manager__mdt
                                                                    WHERE Object_Name__r.QualifiedApiName = :objectName
                                                                    WITH SECURITY_ENFORCED];
        if(triggerSettingList.size() > 0 && !triggerSettingList[0].disable_trigger__c){
            executeTrigger = true;
        }                                                  
        return executeTrigger;
    }
    
    /**
    * @description : This method is used to validate whether the trigger is supposed to run or not. 
    *                The logic for this is usually used for managing triggers in production 
    *                activating/deactivating triggers.
    *                This method is executed first before any other validations.
    *                Triggers are supposed to call the execute method in the trigger body via the sobject TriggerHandler which extends this class
    * @author Mainak Gupta | 08-22-2024 
    **/
    public void execute(){
        if(isTriggerEnabled()){
            run();
        }
    }
}