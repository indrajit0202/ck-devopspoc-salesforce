/**
 * @description       : Test class for ActiveJobPostingHandler.
 * @author            : Indrajit Pal
 * @last modified on  : 12-26-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class ActiveJobPostingHandlerTest {
    /**
    * @description Creates test data for Job_Posting__c, Position__c, and related objects.
    * @author Indrajit Pal | 12-11-2024 
    **/
    @TestSetup
    static void makeData(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);

        Position__c testPositionObj = CommonTestHelper.createPosition('Test Position');
        testPositionObj.Functional_Area__c = 'Miscellaneous';
        testPositionObj.Status__c = 'Open - Approved';
        testPositionObj.Location__c = 'San Francisco, CA';
        insert testPositionObj;

        Employment_Website__c testSiteObj = CommonTestHelper.crateEmploymentwebsite();
        insert testSiteObj;

        Job_Posting__c newPostingObj = CommonTestHelper.createJobPosting(testPositionObj.Id, testSiteObj.Id);
        insert newPostingObj;
    }

    /**
    * @description Verifies successful retrieval of active job postings.
    * @author Indrajit Pal | 11-10-2024 
    **/
    @isTest
    static void getActiveJobPostingsTest(){
        User testingUser = CommonTestHelper.findUserWithEmail('testuser@example.com');

        List<Job_Posting__c> jobPostingList = null;

        Test.startTest();
        System.runAs(testingUser){
            jobPostingList = ActiveJobPostingHandler.getActiveJobPosting();
        }

        Test.stopTest();
        System.assertEquals(true, jobPostingList != null, 'There must be atleast 1 job posting fetched!');
    }


    /**
    * @description Verifies retrieval of job postings by department.
    * @author Indrajit Pal | 11-10-2024 
    **/
    @isTest
    static void getActiveJobPostingWithDepartmentTest(){
        User testingUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        String dept = 'Miscellaneous';
        List<Job_Posting__c> jobPostingList = null;
        

        Test.startTest();
        System.runAs(testingUser){
            jobPostingList = ActiveJobPostingHandler.getJobPostingsByDepartment(dept);
        }
        Test.stopTest();

        System.assertEquals(true, jobPostingList != null, 'There must be atleast 1 job posting fetched!');
    }

    /**
    * @description Verifies retrieval of all functional areas (departments).
    * @author Indrajit Pal | 12-11-2024 
    **/
    @isTest
    static void getAllFunctionalAreaTest(){
        User testingUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        List<String> functionalAreas = null;

        Test.startTest();
        System.runAs(testingUser){
            functionalAreas = ActiveJobPostingHandler.getAllPositionDepartments();
        }
        Test.stopTest();

        System.assertEquals(true, functionalAreas.size() != 0, 'There must be atleast one functional areas!');
    }

    /**
    * @description Test class to check the exception where no data is given.
    * @author Indrajit Pal | 12-12-2024 
    **/
    @isTest
    static void getActiveJobPostingExceptionTest() {
        User testingUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        Job_Posting__c jobPosting = [SELECT Id, 
                                            Position__r.Id, 
                                            Position__r.Status__c 
                                      FROM Job_Posting__c 
                                      WHERE Position__r.Status__c =: RecruitingAppCustomConstants.POSITION_STATUS_OPEN_APPROVED 
                                      LIMIT 1];
        Test.startTest();
        System.runAs(testingUser) {
            jobPosting.Position__r.Status__c = 'New Position';
            update jobPosting.Position__r;
    
            try {
                List<Job_Posting__c> jobPostingList = ActiveJobPostingHandler.getActiveJobPosting();
                System.assert(false, 'An exception should have been thrown but was not!');
            } catch (Exception ex) {
                System.assertEquals('Script-thrown exception', ex.getMessage(), 'Unexpected exception message!');
            }
        }
        Test.stopTest();
    }

    /**
    * @description Test class to check the exception where no data is given.
    * @author Indrajit Pal | 12-12-2024 
    **/
    @isTest
    static void getJobPostingsByDepartmentExceptionTest() {
        User testingUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        
        String nonMatchingDepartment = 'Finance';
        
        Test.startTest();
        System.runAs(testingUser) {
            try {
                List<Job_Posting__c> jobPostingList = ActiveJobPostingHandler.getJobPostingsByDepartment(nonMatchingDepartment);
                System.assert(false, 'An exception should have been thrown but was not!');
            } catch (AuraHandledException ex) {
                System.assertEquals('Script-thrown exception', ex.getMessage(), 'Unexpected exception message!');
            }
        }
        Test.stopTest();
    }
}