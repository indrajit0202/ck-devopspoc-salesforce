/**
 * @description       : Test class for ChangeFieldsCheckHelper.
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class ChangeFieldsCheckHelperTest {

    @TestSetup
    static void makeData(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
    }

    /**
    * @description Test for checkFieldsOne method.
    * @author Indrajit Pal | 12-20-2024 
    **/
    @isTest
    static void testCheckFieldsOne() {
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        System.runAs(testUser) {
            Position__c oldPosition = new Position__c(
                Min_Pay__c = 50000,
                Max_Pay__c = 100000,
                Location__c = 'San Francisco, CA',
                Skills_Required__c = 'Java, Salesforce'
            );

            Position__c newPosition = new Position__c(
                Min_Pay__c = 60000, 
                Max_Pay__c = 100000,
                Location__c = 'New York, NY', 
                Skills_Required__c = 'Java, Python' 
            );

            List<String> changedFieldsList = new List<String>();

            ChangeFieldsCheckHelper.checkFieldsOne(newPosition, oldPosition, changedFieldsList);
            System.assertEquals(3, changedFieldsList.size(), 'There should be 3 changed fields.');
        }
    }

    /**
    * @description Test for checkFieldsTwo method.
    * @author Indrajit Pal | 12-20-2024 
    **/
    @isTest
    static void testCheckFieldsTwo() {
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        System.runAs(testUser) {
            Position__c oldPosition = new Position__c(
                Status__c = 'New Position',
                Job_Description__c = 'Develop and maintain applications.',
                Name = 'Software Engineer'
            );

            Position__c newPosition = new Position__c(
                Status__c = 'Pending Approval', 
                Job_Description__c = 'Develop, maintain, and debug applications.', 
                Name = 'Senior Software Engineer' 
            );

            List<String> changedFieldsList = new List<String>();
            ChangeFieldsCheckHelper.checkFieldsTwo(newPosition, oldPosition, changedFieldsList);
            System.assertEquals(3, changedFieldsList.size(), 'There should be 3 changed fields.');
        }
    }
}
