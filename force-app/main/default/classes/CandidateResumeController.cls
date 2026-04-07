/**
* @description                : This is the controller class for the resume generation for acndidates.
* @author                     : Indrajit Pal
* @last modified on           : 01-02-2025
* @last modified by           : Indrajit Pal
**/
global with sharing class CandidateResumeController {
    private static final string SUCCESS_MESSAGE = 'Resume Attached Successfully for ';
    private static final string ERROR_MESSAGE = 'Error! Resume Has not been Attached';
    private static final string CANDIDATE_IS_NOT_ELIGIBLE = ' is not Eligible for Resume Generation.';

    /**
     * @description                : The method is data setter for the vf page
     * @last modified by           : Indrajit Pal
    **/
    public Candidate__c currentUser { get; set; }

    /**
     * @description                : The method is used to send data to the vf page
     * @last modified by           : Indrajit Pal
    **/
    public CandidateResumeController() {
        String candidateId = ApexPages.currentPage().getParameters().get(RecruitingAppCustomConstants.CANDIDATE_ID);
        currentUser = [SELECT First_Name__c, 
                                Last_Name__c, 
                                Phone__c, 
                                Email__c, 
                                Street__c, 
                                City__c, 
                                State_Province__c, 
                                Zip_Postal_Code__c, 
                                Country__c, 
                                Current_Employer__c, 
                                Job_Title__c, 
                                Responsibilities__c, 
                                Years_of_Experience__c, 
                                Institution_Name__c, 
                                Field_of_Study__c, 
                                Education__c, 
                                GPA__c, 
                                Skills__c, 
                                Certification_Name__c, 
                                Issuing_Organization__c, 
                                LinkedIn_Profile__c, 
                                Portfolio_Website__c, 
                                Languages__c, 
                                Awards_Achievements__c
                            FROM Candidate__c
                            WHERE Id = :candidateId
                            WITH SECURITY_ENFORCED];
    }
    /**
    * @description : This method is used to enqueue the queueable class to attach resume to the candidate record
    * @author Indrajit Pal | 06-12-2024
    * @param appIds
    * @return String
    **/
    webservice static String generateResume(String appIds){
        List<Candidate__c> candidateDetailsList = new List<Candidate__c>();
        String returnMessage = '';
        try {
            List<RecordWrapper> recordList = (List<RecordWrapper>)JSON.deserialize(appIds, List<RecordWrapper>.class);
            List<Id>candidateIdList = new List<Id>();
            for(RecordWrapper record : recordList){
                candidateIdList.add(record.appId);
            }
            //Query for eligibility
            candidateDetailsList = [SELECT Id,
                                         First_Name__c,
                                         Last_Name__c,
                                         is_Eligible_for_Resume_Generation__c
                                        FROM Candidate__c
                                        WHERE Id IN :candidateIdList
                                        WITH SECURITY_ENFORCED];
            for(Candidate__c candidateObj : candidateDetailsList){
                if(candidateObj.is_Eligible_for_Resume_Generation__c == false){
                    returnMessage += (candidateObj.First_Name__c + RecruitingAppCustomConstants.BLANK_STRING
                                     + candidateObj.Last_Name__c + CANDIDATE_IS_NOT_ELIGIBLE + RecruitingAppCustomConstants.BLANK_STRING 
                                     + RecruitingAppCustomConstants.LINE_CHANGE);
                    candidateIdList.remove(candidateIdList.indexOf(candidateObj.Id));
                }
                else{
                    returnMessage += SUCCESS_MESSAGE + candidateObj.First_Name__c 
                                    + RecruitingAppCustomConstants.BLANK_STRING 
                                    + candidateObj.Last_Name__c + RecruitingAppCustomConstants.BLANK_STRING
                                    + RecruitingAppCustomConstants.LINE_CHANGE;
                }
            }
            System.enqueueJob(new GenerateCandidateResumesQueueable(candidateIdList));
            return returnMessage;
        } catch (Exception exObj) {
            CustomExceptionHandler.logException(exObj, CandidateResumeController.class.getName());
            return ERROR_MESSAGE;
        }
    }

    /**
     * @description       : This is a Wrapper class to wrap the upcoming json format
     * @author            : Indrajit Pal
    **/
    public class RecordWrapper{
        public String appId;
    }
}