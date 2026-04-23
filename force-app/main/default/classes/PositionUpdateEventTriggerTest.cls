/**
 * @description       : Test class for PositionUpdateEventTriggerTest
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class PositionUpdateEventTriggerTest {
    @TestSetup
    static void makeData(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);

        // Create bulk candidates
        List<Candidate__c> candidates = new List<Candidate__c>();
        for(Integer iterator = 0; iterator < 10; iterator++){
            Candidate__c candi = CommonTestHelper.createCandidateWithContact('TestCandidate ' + iterator, 'TestCandidate' + iterator, 'testcandidate' + iterator + '@example.com');
            candidates.add(candi);
        }
        insert candidates;

        List<Position__c> positions = new List<Position__c>();
        for(Integer iterator = 0; iterator < 10; iterator++){
            Position__c position = CommonTestHelper.createPosition('TestPosition ' + iterator);
            positions.add(position);
        }
        insert positions;

        List<Job_Application__c> jobApplications = new List<Job_Application__c>();
        for(Integer iterator = 0; iterator < 9; iterator++){
            jobApplications.add(new Job_Application__c(Candidate__c = candidates[iterator].Id, Position__c = positions[iterator].Id));
        }
        jobApplications.add(new Job_Application__c(Position__c = positions[9].Id));
        insert jobApplications;
    }

    /**
    * @description In this test no field will be updated
    * @author Indrajit Pal | 10-30-2024 
    **/
    @isTest
    static void noUpdateInPosition(){
        User user = CommonTestHelper.findUserWithEmail('testuser@example.com');
        List<Position__c> position = [SELECT Id, 
                                             Name
                                             FROM
                                             Position__c
                                             LIMIT 1];
        Test.startTest();
        System.runAs(user){
            Database.update(position);
        }
        Test.stopTest();

        List<Position_Update_Log__c> updateLogList = [SELECT Id
                                                          FROM
                                                          Position_Update_Log__c
                                                          LIMIT 1];
        System.assertEquals(0, updateLogList.size(), 'There should be 0 logs in the Position_Update_Log__c object records.');
    }

    @isTest
    static void bulkUpdatePosition(){
        User user = CommonTestHelper.findUserWithEmail('testuser@example.com');
        List<Position__c> positionList = [SELECT Id, 
                                             Name
                                             FROM
                                             Position__c
                                             LIMIT 10];
        for( Position__c pos : positionList){
            pos.Name = pos.Name + ' New';
        }

        Test.startTest();
        System.runAs(user){
            Database.update(positionList);
        }
        Test.stopTest();    
        List<Position_Update_Log__c> updateLogList = [SELECT Id
                                                        FROM
                                                        Position_Update_Log__c
                                                        LIMIT 10];
        System.assertEquals(positionList.size(), updateLogList.size(), 'There should be same logs in the Position_Update_Log__c object records.');                                
    }

    @isTest
    static void invalidPositionData(){
        User user = CommonTestHelper.findUserWithEmail('testuser@example.com');
        Position__c pos = CommonTestHelper.createPosition(null);
        Test.startTest();
        System.runAs(user){
            try{
                insert pos;
            }
            catch(Exception ex){
                System.assert(ex.getMessage().contains('Field Name cannot be null'), 'Expected a DmlException for null Name');
            }
        }
        Test.stopTest();  
    }
    
}