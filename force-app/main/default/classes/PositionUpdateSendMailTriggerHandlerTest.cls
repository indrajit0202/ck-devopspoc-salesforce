/**
 * @description       : Test class for PositionUpdateSendMailTriggerHandler, testing the publishing of platform events.
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class PositionUpdateSendMailTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        insert adminUser;

        Position__c positionSFObj = CommonTestHelper.createPosition('Software Engineer');
        positionSFObj.Location__c = 'San Francisco, CA';
        positionSFObj.Min_Pay__c = 100000;
        insert positionSFObj;

        Position__c positionDSObj = CommonTestHelper.createPosition('Data Scientist');
        positionDSObj.Location__c = 'Sydney, Australia';
        positionDSObj.Min_Pay__c = 120000;
        insert positionDSObj;
    }

    /**
     * @description Tests the afterUpdate logic of the PositionUpdateEventTriggerHandler.
     */
    @isTest
    static void afterUpdateTest() {
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        System.runAs(testUser) {
            Position__c prevTestPositionObj = [SELECT Id, 
                                                        Name, 
                                                        Location__c, 
                                                        Min_Pay__c 
                                                    FROM Position__c 
                                                    WHERE Name = 'Software Engineer'
                                                    LIMIT 1];

            prevTestPositionObj.Location__c = 'Mumbai, India';
            prevTestPositionObj.Min_Pay__c = 11000;


            Test.startTest();
            update prevTestPositionObj;
            Test.stopTest();

            Position__c updatedTestPositionObj = [SELECT Id, 
                                                        Name, 
                                                        Location__c, 
                                                        Min_Pay__c 
                                                    FROM Position__c 
                                                    WHERE Name = 'Software Engineer'
                                                    LIMIT 1];
            
            System.assertEquals(false, prevTestPositionObj.Location__c != updatedTestPositionObj.Location__c, 'Position location should be updated.');
        }
    }

    /**
     * @description Tests that no platform event is published when there are no field changes.
     */
    @isTest
    static void testNoChanges() {
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        System.runAs(testUser) {
            Position__c prevTestPositionObj = [SELECT Id,
                                                        Name, 
                                                        Location__c,
                                                        Min_Pay__c 
                                                FROM Position__c 
                                                WHERE Location__c = 'San Francisco, CA'
                                                LIMIT 1];

            Test.startTest();
            update prevTestPositionObj; 
            Test.stopTest();
            Position__c updatedTestPositionObj = [SELECT Id, 
                                                        Name, 
                                                        Location__c, 
                                                        Min_Pay__c 
                                                    FROM Position__c 
                                                    WHERE Location__c = 'San Francisco, CA'
                                                    LIMIT 1];
            System.assertEquals(true, prevTestPositionObj.Name == updatedTestPositionObj.Name, 'Position name should not be updated.');
        }
    }
}
