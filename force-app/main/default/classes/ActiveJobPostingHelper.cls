/**
 * @description       : Helper class for ActiveJobPostingHandler class
 * @author            : Indrajit Pal
 * @last modified on  : 12-19-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class ActiveJobPostingHelper {
    /**
    * @description Returns all the departments present in the posting object
    * @author Indrajit Pal | 11-10-2024 
    * @return List<String> 
    **/
    public static List<String> allPositionDepartments(){
        
        List<String> positionDepartmentList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Position__c.Functional_Area__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry ple : picklistEntryList){
            positionDepartmentList.add(ple.getLabel());
        }

        return positionDepartmentList;
    }
}