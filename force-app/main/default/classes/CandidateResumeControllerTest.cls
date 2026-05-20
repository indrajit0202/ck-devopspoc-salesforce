/**
* @description                : This is the test class for CandidateResumeController
* @author                     : Indrajit Pal
* @last modified on           : 12-28-2024
* @last modified by           : Indrajit Pal
**/
@isTest
public with sharing class CandidateResumeControllerTest {

    /**
    * @description Creates test data for RunAs User
    * @author Indrajit Pal | 12-26-2024 
    **/
    @TestSetup
    static void makesData() {
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Candidate__c candidateObj = CommonTestHelper.createCandidateWithoutContact('Test', 'example', 'test@example.com');
        candidateObj.Status__c = 'Approved';
        insert candidateObj;
    }
    
    @isTest
    /**
    * @description : This is used to test the main method of the CandidateResumeController class
    * @author Indrajit Pal | 20-12-2024
    **/
    private static void generateResumeTest() {
        User user = [SELECT Id FROM User LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            Candidate__c candidateObj = [SELECT Id, 
                                            First_Name__c, 
                                            Last_Name__c 
                                        FROM Candidate__c LIMIT 1];
            String result = CandidateResumeController.generateResume('[{"appid":"' + candidateObj.Id + '"}]');
            System.assertEquals('Resume Attached Successfully for ' + candidateObj.First_Name__c + ' ' + candidateObj.Last_Name__c + ' ' + '\n', result, 'The result should be a success message.');
            
            List<AsyncApexJob> jobList = [SELECT Id,
                                                Status,
                                                JobItemsProcessed,
                                                TotalJobItems
                                            FROM AsyncApexJob
                                            WHERE ApexClass.Name = 'GenerateCandidateResumesQueueable'
                                            AND Status = 'Queued'];
 
            System.assertNotEquals(0, jobList.size(), 'The job should be enqueued.');
            System.assertEquals('Queued', jobList[0].Status, 'The job should have a status of Queued.');
            Test.stopTest();
        }
    }

    @isTest
    /**
    * @description : This is used to test the main method of the CandidateResumeController class
    * @author Indrajit Pal | 20-12-2024
    **/
    private static void generateResumeNotEligibleTest() {
        User user = [SELECT Id FROM User LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            Candidate__c candidateObj = [SELECT Id, 
                                            First_Name__c, 
                                            Last_Name__c 
                                        FROM Candidate__c LIMIT 1];
            candidateObj.Status__c = 'New';
            Database.update(candidateObj);
            String result = CandidateResumeController.generateResume('[{"appid":"' + candidateObj.Id + '"}]');
            System.assertEquals(candidateObj.First_Name__c + ' ' + candidateObj.Last_Name__c + ' is not Eligible for Resume Generation. '  + '\n', result, 'The result should be an error message.');
            Test.stopTest();
        }
    }

    @isTest
    static void testControllerInitialization() {
        User user = [SELECT Id FROM User LIMIT 1];
        System.runAs(user) {
            Candidate__c candidateObj = [SELECT Id FROM Candidate__c LIMIT 1];
            Test.setCurrentPage(Page.CandidateResumePage);
            ApexPages.currentPage().getParameters().put('Id', candidateObj.Id);

            CandidateResumeController controller = new CandidateResumeController();
            System.assertNotEquals(null, controller.currentUser, 'Current user should be set.');
        }
    }
}
