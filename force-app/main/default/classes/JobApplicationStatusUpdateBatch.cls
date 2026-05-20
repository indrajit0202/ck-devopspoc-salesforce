/**
 * @description       : This is the batch class which will be scheduled to update the status of the job applications in certain 
 *                      conditions.
 * @author            : Indrajit Pal
 * @last modified on  : 12-26-2024
 * @last modified by  : Indrajit Pal
**/
public with sharing class JobApplicationStatusUpdateBatch implements DataBase.Batchable<sObject> {

    public Map<String, Job_Application_Status_Update_Setting__mdt> ruleNameVSMetadata;

    /**
    * @description This is the constructor of the batch class where the metadata is queried..
    * @author Indrajit Pal | 12-24-2024 
    **/
    public JobApplicationStatusUpdateBatch() {
        this.ruleNameVSMetadata = Job_Application_Status_Update_Setting__mdt.getAll();
    }

    /**
    * @description In the start method the data will be queried on which the batch will execute.
    * @author Indrajit Pal | 12-17-2024 
    * @param bat 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bat) {

        // Base query
        String query = 'SELECT Id, Status__c, candidate__r.no_longer_interested__c, LastModifiedDate, Job_Interview_Date__c FROM Job_Application__c WHERE ';

        // Construct query conditions based on metadata
        List<String> conditions = new List<String>();
        DateTime now = DateTime.now();

        for (Job_Application_Status_Update_Setting__mdt metadata : ruleNameVSMetadata.values()) {
            if (metadata.Active__c) {
                constructQueryString(metadata, conditions, now);
            }
        }
        
        if (!conditions.isEmpty()) {
            query += '(' + String.join(conditions, ' OR ') + ')';
        } else {
            query += '1 = 0'; // No active metadata -> no records should be queried
        }

        return Database.getQueryLocator(query);
    }

    /**
    * @description This method will handle query construction for the batch
    * @author Indrajit Pal | 12-25-2024 
    * @param metadata 
    * @param conditions 
    * @param now 
    **/
    public static void constructQueryString(Job_Application_Status_Update_Setting__mdt metadata, List<String> conditions, DateTime now) {
        // Handle DaysSinceLastActivity__c condition
        if (metadata.DaysSinceLastActivity__c != null) {
            DateTime thresholdDateTime = now.addDays(-Integer.valueOf(metadata.DaysSinceLastActivity__c));
            String formattedDateTime = thresholdDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            conditions.add('LastModifiedDate < ' + formattedDateTime);
        }
        // Handle DaysSinceInterview__c condition
        if (metadata.DaysSinceInterview__c != null) {
            DateTime intrviewThresholdDateTime = now.addDays(-Integer.valueOf(metadata.DaysSinceInterview__c));
            String formattedDateTime = intrviewThresholdDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            conditions.add('Job_Interview_Date__c < ' + formattedDateTime);
        }
        // Handle Candidate_no_longer_interested__c condition
        if (metadata.Candidate_no_longer_interested__c) {
            conditions.add('candidate__r.no_longer_interested__c = true');
        }
        // Handle CurrentStatus__c condition
        if (metadata.CurrentStatus__c != 'Any') {
            conditions.add('Status__c = \'' + metadata.CurrentStatus__c + '\'');
        }
    }

    /**
    * @description In this method the whole functionality will be performed.
    * @author Indrajit Pal | 12-17-2024 
    * @param bat 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bat, List<sObject> scope) {
        List<Job_Application__c> jobApplicationList = (List<Job_Application__c>)scope;
        JobApplicationStatusUpdateHandler.updateJobApplicationStatus(jobApplicationList);
    }

    /**
    * @description 
    * @author Indrajit Pal | 12-17-2024 
    * @param bat 
    **/
    public void finish(Database.BatchableContext bat) {
        return;
    }
}