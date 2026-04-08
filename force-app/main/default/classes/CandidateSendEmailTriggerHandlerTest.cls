/**
 * @description       : Test classes for checking mail sending to candidate is successful or not.
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class CandidateSendEmailTriggerHandlerTest {

    /**
    * @description Test case where there is no contact present for the created candidate.
    * @author Indrajit Pal | 10-30-2024 
    **/
    @isTest
    public static void candidateWithNoContactPresent(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Candidate__c newCandidateObj = new Candidate__c(
                                                First_Name__c = 'John',
                                                Last_Name__c = 'Doe',
                                                Email__c = 'johndoe@gmail.com'
                                                );
        System.runAs(adminUser){
            Test.startTest();
            Database.insert(newCandidateObj);
            List<Contact> contactsList = [SELECT Id 
                                              FROM Contact
                                              WHERE Email = 'johndoe@gmail.com'];
            Contact contact = contactsList[0];
            List<Candidate__c> candidatesList = [SELECT Id,
                                                    Contact__c 
                                                    FROM Candidate__c];
            Candidate__c candidate = candidatesList[0];
            Test.stopTest();
            System.assertEquals(contact.Id, candidate.Contact__c, 'Contact not created and linked successfully.');
        }
    }

    /**
    * @description Test case where there are already a contact present for the candidate and already linked with the candidate at the time of record creation.
    * @author Indrajit Pal | 10-30-2024 
    **/
    @isTest
    public static void candidateWithContactPresent(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Candidate__c newCandidateObj = CommonTestHelper.createCandidateWithContact('Indrajit', 'Pal', 'indrajit@example.com');
        System.runAs(adminUser){
            Test.startTest();
            insert newCandidateObj;
            List<Contact> contactsList = [SELECT Id, 
                                                  Name
                                             FROM
                                             Contact];
            Test.stopTest();
            System.assertEquals(1, contactsList.size(), 'There must be one contact present.');
            System.Assert.isTrue(contactsList[0].Name.contains('Indrajit'), 'Contact name must contain \'Indrajit\'');
        }
    }

    /**
    * @description Test case where there are already a contact present for the candidate but not linked with the candidate at the time of record creation.
    * @author Indrajit Pal | 12-12-2024 
    **/
    @isTest
    public static void candidateWithContactPresentButNotLinked(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Candidate__c newCandidateObj = CommonTestHelper.createCandidateWithoutContact('Indrajit', 'Pal', 'indrajit@example.com');
        Contact newContactObj = CommonTestHelper.createContact('Indrajit', 'Pal', 'indrajit@example.com');
        System.runAs(adminUser){
            Test.startTest();
            insert newContactObj;
            insert newCandidateObj;
            List<Contact> contactList = [SELECT Id, 
                                              Name
                                           FROM
                                           Contact];
            Test.stopTest();
            System.Assert.areEqual(1, contactList.size(), 'There must be one contact present.');
        }
    }

    /**
    * @description Test case where there are some details missing for the candidate.
    * @author Indrajit Pal | 12-12-2024 
    **/
    @isTest
    public static void candidateWithIncompleteDetails(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Candidate__c newCandidateObj = new Candidate__c(Last_Name__c = 'Pal', Email__c = 'indrajit@example.com');
        System.runAs(adminUser){
            Test.startTest();
            insert newCandidateObj;
            List<Candidate__c> candidateList = [SELECT Id, 
                                                    First_Name__c,
                                                    Last_Name__c,
                                                    Email__c
                                                    FROM
                                                    Candidate__c];
            Test.stopTest();

            System.Assert.areEqual(1, candidateList.size(), 'There must be one candidate present.');
            System.Assert.areEqual(null, candidateList[0].First_Name__c, 'First name must be null.');
        }
    }
}