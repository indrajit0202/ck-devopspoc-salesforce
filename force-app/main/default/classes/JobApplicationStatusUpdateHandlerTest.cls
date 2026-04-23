/**
 * @description       : Test class for JobApplicationStatusUpdateHandler
 * @author            : Indrajit Pal
 * @last modified on  : 12-26-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class JobApplicationStatusUpdateHandlerTest {
    /**
    * @description This is the test setup method for RunAs User
    * @author Indrajit Pal | 12-26-2024 
    **/
    @TestSetup
    static void makeData(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Candidate__c candidateObj = CommonTestHelper.createCandidateWithoutContact('Indrajit', 'Pal', 'example@email.com');
        candidateObj.No_Longer_Interested__c = true;
        insert candidateObj;

        Job_Application__c jobApplicationObj = CommonTestHelper.createJobApplication(candidateObj);
        jobApplicationObj.Status__c = 'Applied';
        DateTime myDateTime = DateTime.newInstance(2023, 8, 21, 14, 30, 0);
        jobApplicationObj.Job_Interview_Date__c = myDateTime;
        insert jobApplicationObj;
    }

    /**
    * @description This is the method of the test class for the batch class where the status of the job application is changed to Withdrawn.
    * @author Indrajit Pal | 12-26-2024 
    **/
    @isTest
    public static void markWithdrawnIfUninterestedTest(){
        User testingUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        List<Job_Application__c> jobApllicationList = [SELECT Id,
                                                            Status__c,
                                                            candidate__r.no_longer_interested__c,
                                                            Job_Interview_Date__c,
                                                            LastModifiedDate
                                                        FROM Job_Application__c
                                                        WHERE candidate__r.no_longer_interested__c = true];
        Test.startTest();
            System.runAs(testingUser){
                JobApplicationStatusUpdateHandler.updateJobApplicationStatus(jobApllicationList);
            }
        Test.stopTest();
        List<Job_Application__c> updateJobApllicationList = [SELECT id,
                                                                    Status__c,
                                                                    candidate__r.no_longer_interested__c,
                                                                    LastModifiedDate
                                                                FROM Job_Application__c
                                                                WHERE id =:jobApllicationList[0].id];
        System.assertEquals('Withdrawn', updateJobApllicationList[0].Status__c, 'The status must be changed to WITHDRAWN');
    }

    /**
    * @description This is the method for the batch class where the status of the job application is changed to Not Selected.
    * @author Indrajit Pal | 12-26-2024 
    **/
    @isTest
    public static void updateStatusToNotSelectedTest(){
        User testingUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        List<Candidate__c> candidateList = [SELECT  id,
                                                    no_longer_interested__c
                                                FROM Candidate__c
                                                WHERE Email__c = 'example@email.com'];
        candidateList[0].no_longer_interested__c = false;
        update candidateList;
        List<Job_Application__c> jobApllicationList = [SELECT id,
                                                            Status__c,
                                                            candidate__r.no_longer_interested__c,
                                                            Job_Interview_Date__c,
                                                            LastModifiedDate
                                                        FROM Job_Application__c
                                                        WHERE candidate__r.no_longer_interested__c = false];
        
        jobApllicationList[0].Status__c = 'Interviewed';
        jobApllicationList[0].Job_Interview_Date__c = DateTime.now().addDays(-15);
        update jobApllicationList;
        Test.startTest();
            System.runAs(testingUser){
                JobApplicationStatusUpdateHandler.updateJobApplicationStatus(jobApllicationList);
            }
        Test.stopTest();
        List<Job_Application__c> updateJobApllicationList = [SELECT id,
                                                                    Status__c,
                                                                    candidate__r.no_longer_interested__c,
                                                                    LastModifiedDate
                                                                FROM Job_Application__c
                                                                WHERE id =:jobApllicationList[0].id];
        System.assertEquals('Not Selected', updateJobApllicationList[0].Status__c,'Assert Failed');
    }
}