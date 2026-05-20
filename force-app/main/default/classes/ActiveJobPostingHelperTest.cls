/**
 * @description       : Test class for ActiveJobPostingHelper
 * @author            : Indrajit Pal
 * @last modified on  : 12-20-2024
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class ActiveJobPostingHelperTest {
    /**
    * @description Creates test data for RunAs User
    * @author Indrajit Pal | 12-11-2024 
    **/
    @TestSetup
    static void makeData(){
        User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'testuser@example.com', 'randuser');
        Database.insert(adminUser);
    }
    
    /**
     * @description Verifies the retrieval of all functional areas (departments) as defined in the picklist.
     * @author Indrajit Pal 
     * @createdDate 12-12-2024
     **/
    @isTest
    static void allPositionDepartmentsTest() {
        User testUser = CommonTestHelper.findUserWithEmail('testuser@example.com');
        List<String> departmentList = null;
        Test.startTest();
        System.runAs(testUser){        
            departmentList = ActiveJobPostingHelper.allPositionDepartments();
        }
        Test.stopTest();

        System.assertNotEquals(null, departmentList, 'The list of functional areas should not be null.');
        System.assert(!departmentList.isEmpty(), 'The list of functional areas should not be empty.');

        System.assert(departmentList.contains('Miscellaneous'), 'The list should include the "Miscellaneous" department.');
    }
}
