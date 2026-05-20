/**
 * @description       : This is the test class for PositionUpdateMailController class testing.
 * @author            : Indrajit Pal
 * @last modified on  : 12-27-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class PositionUpdateMailControllerTest {
    @TestSetup
    static void makeData(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Candidate__c testCandidateObj = CommonTestHelper.createCandidateWithContact('John', 'Doe', 'john.doe@example.com');
        insert testCandidateObj;

        Position__c newPositionObj = CommonTestHelper.createPosition('Software Developer');
        insert newPositionObj;

        Job_Application__c testJobApplicationObj = CommonTestHelper.createJobApplication(testCandidateObj);
        testJobApplicationObj.Position__c = newPositionObj.Id;
        insert testJobApplicationObj;
    }

    /**
    * @description This test method is to test the functionality of the sendEmail method.
    * @author Indrajit Pal | 12-20-2024 
    **/
    @isTest()
    static void sendEmailTest(){
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        System.runAs(testUser){
            List<Job_Application__c> jobApplicationsList = [SELECT Id, 
                                                                Candidate__r.First_Name__c, 
                                                                Candidate__r.Last_Name__c, 
                                                                Candidate__r.Email__c, 
                                                                Position__r.Name 
                                                            FROM Job_Application__c];
            Map<Id, String> posIdVsUpdatedValuesMap = new Map<Id, String>{
                jobApplicationsList[0].Position__c => 'Location --> New York, Status --> Open'
            };
            Test.startTest();
            Messaging.SendEmailResult[] resultList = PositionUpdateMailController.sendEmail(jobApplicationsList, posIdVsUpdatedValuesMap);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, resultList, 'Results should not be null');
            System.assertEquals(1, resultList.size(), 'There should be one email result');
            System.assert(resultList[0].success, 'The email should be sent successfully');
        }
    }

    /**
    * @description This test method is to test the functionality of the positiontemplateListNullCheck method.
    * @author Indrajit Pal | 12-20-2024 
    **/
    @isTest
    public static void positiontemplateListNullCheckTest(){
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        System.runAs(testUser){
            try{
                Test.startTest();
                PositionUpdateMailController.positiontemplateListNullCheck(new List<StaticResource>{});
                Test.stopTest();
            }
            catch(Exception exObj){
                System.assertEquals('Position Template not found', exObj.getMessage(), 'There is no position template static resource found.');
            }
        }
    }
}
