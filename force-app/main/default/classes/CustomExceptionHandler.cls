/**
 * @description       : This class will handle all the custom exceptions and create record when each exception occours
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
public with sharing class CustomExceptionHandler {
    
    /**
    * @description This method will create a custom exception record in the custom exception object.
    * @author Indrajit Pal | 10-29-2024 
    * @param exObj 
    * @param className 
    **/
    public static void logException(Exception exObj, String className){
        String message = exObj.getMessage() + exObj.getStackTraceString();
        String type = exObj.getTypeName();
        Exception_Log__c newLog = new Exception_Log__c();
        newLog.Message__c = message;
        newLog.Type__c = type;
        newLog.classname__c = className;
        newLog.Occouring_date_time__c = System.now();

        Database.insert(newLog, false, AccessLevel.SYSTEM_MODE);
    }
}