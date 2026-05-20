/**
 * @description       : Test class for SendWelcomeEmailController.
 * @author            : Indrajit Pal
 * @last modified on  : 12-27-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class SendWelcomeEmailControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create test contactsList
        List<Contact> contactsList = new List<Contact>{
            CommonTestHelper.createContact('John', 'Doe', 'john.doe@example.com'),
            CommonTestHelper.createContact('Jane', 'Doe', 'jane.smith@example.com')
        };
        insert contactsList;
    }

    /**
     * @description Test the sendEmail method with valid contact IDs.
     * @author Indrajit Pal
     */
    @isTest
    public static void testSendEmailWithValidContacts() {
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Messaging.SendEmailResult[] resultList;
        List<Contact> contactsList = [SELECT Id, 
                                               Email 
                                            FROM Contact
                                            WHERE LastName = 'Doe'
                                            WITH SECURITY_ENFORCED];
        Test.startTest();
        System.runAs(adminUser){
            resultList = SendWelcomeEmailController.sendEmail(new List<Id>{contactsList[0].Id, contactsList[1].Id});
        }
        Test.stopTest();

        System.assertEquals(true, resultList.size()==contactsList.size(), 'Sent mesage list size should be equals to the contact list size.');
        for (Messaging.SendEmailResult result : resultList) {
            System.assert(result.success, 'Email should have been sent successfully.');
        }
    }


    /**
    * @description Test the sendEmail method with an empty contact ID list.
    * @author Indrajit Pal | 12-12-2024 
    **/
    @isTest
    public static void testSendEmailWithEmptyContactList() {
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
        Messaging.SendEmailResult[] resultList;
        Test.startTest();
        System.runAs(adminUser){
            resultList = SendWelcomeEmailController.sendEmail(new List<Id>());
        }
        Test.stopTest();
        System.assertEquals(0, resultList.size(), 'No email results should be returned for an empty list.');
    }
}

