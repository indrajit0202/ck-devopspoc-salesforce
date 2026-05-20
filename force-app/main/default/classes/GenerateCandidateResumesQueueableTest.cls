/**
* @description                : This is the test class for the GenerateCandidateResumesQueueable class
* @author                     : Indrajit Pal
* @last modified on           : 12-26-2024
* @last modified by           : Indrajit Pal
**/
@IsTest
public with sharing class GenerateCandidateResumesQueueableTest {

    /**
    * @description Creates test data for RunAs User
    * @author Indrajit Pal | 12-26-2024 
    **/
    @TestSetup
    static void makeData() {
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        System.runAs(adminUser) {
            Candidate__c candidate = CommonTestHelper.createCandidateWithoutContact('Test', 'example', 'test@example.com');
            insert candidate;
        }
    }

    @IsTest
    /**
    * @description : This is the main method to test the queueable class
    * @author Indrajit Pal | 20-12-2024
    **/
    private static void executeMethodTest() {
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        System.runAs(testUser) {
            Test.startTest();

            List<Candidate__c> candList = [SELECT Id FROM Candidate__c WITH SECURITY_ENFORCED LIMIT 1];
            System.enqueueJob(new GenerateCandidateResumesQueueable(new List<Id>{candList[0].Id}));

            List<AsyncApexJob> jobs = [SELECT Id, 
                                                Status, 
                                                JobItemsProcessed, 
                                                TotalJobItems
                                            FROM AsyncApexJob
                                            WHERE ApexClass.Name = 'GenerateCandidateResumesQueueable'
                                            AND Status = 'Queued'];

            System.assertNotEquals(0, jobs.size(), 'The job should be enqueued.');
            System.assertEquals('Queued', jobs[0].Status, 'The job should have a status of Queued.');
            Test.stopTest();
        }
    }
}
