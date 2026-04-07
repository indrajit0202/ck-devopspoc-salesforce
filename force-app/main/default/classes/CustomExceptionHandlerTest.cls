/**
 * @description       : This class is the test class for the CustomExceptionHandler class
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
private class CustomExceptionHandlerTest {

    /**
    * @description This is the method where the datas are made for the testing.
    * @author Indrajit Pal | 12-20-2024 
    **/
    @TestSetup
    static void makeData(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
    }

    /**
    * @description This is the test method of the CustomExceptionHandler's logException method.
    * @author Indrajit Pal | 12-20-2024 
    **/
    @isTest
    static void testCreateCustomException() {
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        String testClassName = 'TestClassName';
        Integer iterator;
        Exception sampleException;
        List<Exception_Log__c> prevLogList = [SELECT Message__c, 
                                                Type__c, 
                                                classname__c, 
                                                Occouring_date_time__c 
                                            FROM Exception_Log__c
                                            WHERE classname__c = :testClassName];
        Test.startTest();
        System.runAs(testUser){ 
            try {
                iterator = 1 / 0; 
            } catch (Exception exObj) {
                sampleException = exObj;
            }
            CustomExceptionHandler.logException(sampleException, testClassName);
        }
        Test.stopTest();

        List<Exception_Log__c> logList = [SELECT Message__c, 
                                                Type__c, 
                                                classname__c, 
                                                Occouring_date_time__c 
                                            FROM Exception_Log__c
                                            WHERE classname__c = :testClassName];
        System.assertEquals(false, prevLogList.size()==logList.size(), 'One exception log should have been created.');
        Exception_Log__c log = logList[0];
        System.assertEquals(sampleException.getMessage() + sampleException.getStackTraceString(), log.Message__c, 
                            'The message should match the exception message.');
        System.assertEquals(sampleException.getTypeName(), log.Type__c, 'The type should match the exception type.');
        System.assertEquals(testClassName, log.classname__c, 'The class name should match the provided class name.');
        System.assertNotEquals(null, log.Occouring_date_time__c, 'The date/time should be populated.');
    }
}