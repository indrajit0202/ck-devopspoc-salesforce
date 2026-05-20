/**
* @description                : This Queueable class is used to generate the resume for the candidate in a queue.
* @author                     : Indrajit Pal
* @last modified on           : 12-26-2024
* @last modified by           : Indrajit Pal
**/
public inherited sharing class GenerateCandidateResumesQueueable implements Queueable,Database.AllowsCallouts {
    public List<Id> candidateIdList = new List<Id>();
    private static final string CONTENT_TYPE = 'application/pdf';
    private static final string PDF = '.pdf';
    
    /**
    * @description Constructor to assign recordList
    * @author Indrajit Pal | 29-11-2024
    * @param candidateIdList
    **/
    public GenerateCandidateResumesQueueable(List<Id> candidateIdList) {
        this.candidateIdList = candidateIdList;
    }

    /**
    * @description :This method is used to attach the resume
    * @author Indrajit Pal | 29-11-2024
    * @param context
    **/
    public void execute(QueueableContext context) {
        List<Candidate__c> candidateList;
        List<Attachment> attachmentList = new List<Attachment>();
        try {
            candidateList = [SELECT Id,
                                     First_Name__c, 
                                     Last_Name__c
                                FROM Candidate__c
                                WHERE Id IN :candidateIdList
                                WITH SECURITY_ENFORCED];
            
            for(Candidate__c eachCandidate : candidateList){
                Blob pdfBlob;
                Attachment attachment = new Attachment();
                PageReference pdfPage = Page.CandidateResumePage;
                pdfPage.getParameters().put(RecruitingAppCustomConstants.CANDIDATE_ID, eachCandidate.Id);
                try {
                    pdfBlob = pdfPage.getContentAsPDF();
                } catch (Exception exec) {
                    pdfBlob = Blob.valueOf(RecruitingAppCustomConstants.TESTING);
                }
                attachment.ParentId = eachCandidate.Id;
                // this constructs the name of the pdf.
                attachment.Name = eachCandidate.First_Name__c + RecruitingAppCustomConstants.UNDERSCORE_STRING 
                                  + eachCandidate.Last_Name__c + RecruitingAppCustomConstants.UNDERSCORE_STRING  
                                  + String.valueOf(eachCandidate.Id) 
                                  + RecruitingAppCustomConstants.RESUME_STRING + PDF;
                attachment.Body = pdfBlob;
                attachment.ContentType = CONTENT_TYPE;
                attachmentList.add(attachment);
            }
            Database.insert(attachmentList, true, AccessLevel.SYSTEM_MODE);
        } catch (Exception exObj) {
            CustomExceptionHandler.logException(exObj, GenerateCandidateResumesQueueable.class.getName());
        }
    }
}