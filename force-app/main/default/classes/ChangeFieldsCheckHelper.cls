/**
 * @description       : Helper class for PositionUpdateEventTriggerHandler class to check the updations in the fields.
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class ChangeFieldsCheckHelper {
    public static final String STATUS_STRING = 'Status ';
    public static final String JOB_DESCRIPTION_STRING = 'Job Description ';
    public static final String NAME_STRING = 'Name ';
    public static final String MIN_PAY_STRING = 'Min Pay ';
    public static final String MAX_PAY_STRING = 'Max Pay ';
    public static final String LOCATION_STRING = 'Location ';
    public static final String SKILLS_REQUIRED_STRING = 'Skills Required ';
    /**
    * @description Helper method for PositionUpdateEventTriggerHandler class to check the updations in the fields. 
    * @author Indrajit Pal | 10-21-2024 
    * @param newPositionObj 
    * @param oldPositionObj 
    * @param changedFieldsList 
    **/
    public static void checkFieldsTwo(Position__c newPositionObj,  Position__c oldPositionObj, List<String> changedFieldsList){
        if (newPositionObj.Status__c != oldPositionObj.Status__c) {
            changedFieldsList.add(STATUS_STRING + RecruitingAppCustomConstants.ARROW_STRING + newPositionObj.Status__c);
        }
        if (newPositionObj.Job_Description__c != oldPositionObj.Job_Description__c) {
            changedFieldsList.add(JOB_DESCRIPTION_STRING + RecruitingAppCustomConstants.ARROW_STRING + newPositionObj.Job_Description__c);
        }
        if(newPositionObj.Name != oldPositionObj.Name){
            changedFieldsList.add(NAME_STRING + RecruitingAppCustomConstants.ARROW_STRING + newPositionObj.Name);
        }
    }

    /**
    * @description Helper method for PositionUpdateEventTriggerHandler class to check the updations in the fields. 
    * @author Indrajit Pal | 10-21-2024 
    * @param newPositionObj 
    * @param oldPositionObj 
    * @param changedFieldsList 
    **/
    public static void checkFieldsOne(Position__c newPositionObj,  Position__c oldPositionObj, List<String> changedFieldsList){
        if (newPositionObj.Min_Pay__c != oldPositionObj.Min_Pay__c) {
            changedFieldsList.add(MIN_PAY_STRING + RecruitingAppCustomConstants.ARROW_STRING + newPositionObj.Min_Pay__c);
        }
        if (newPositionObj.Max_Pay__c != oldPositionObj.Max_Pay__c) {
            changedFieldsList.add(MAX_PAY_STRING + RecruitingAppCustomConstants.ARROW_STRING + newPositionObj.Max_Pay__c);
        }
        if (newPositionObj.Location__c != oldPositionObj.Location__c) {
            changedFieldsList.add(LOCATION_STRING + RecruitingAppCustomConstants.ARROW_STRING + newPositionObj.Location__c);
        }
        if (newPositionObj.Skills_Required__c != oldPositionObj.Skills_Required__c) {
            changedFieldsList.add(SKILLS_REQUIRED_STRING + RecruitingAppCustomConstants.ARROW_STRING + newPositionObj.Skills_Required__c);
        }
    }
}