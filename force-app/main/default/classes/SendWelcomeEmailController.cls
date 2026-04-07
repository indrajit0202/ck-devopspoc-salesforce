/**
 * @description       : Send welcome email to a candidate based on the contact linked with the candidate.
 * @author            : Indrajit Pal
 * @last modified on  : 12-27-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class SendWelcomeEmailController {
    
    /**
    * @description This method takes all the contact ids and send update email to all of them.
    * @author Indrajit Pal | 09-29-2024 
    * @param contactIdList 
    * @return Messaging.SendEmailResult[] 
    **/
    public static Messaging.SendEmailResult[] sendEmail(List<Id> contactIdList){

        Messaging.SingleEmailMessage[] messagesList = new List<Messaging.SingleEmailMessage>();
        Messaging.SendEmailResult[] resultList = new Messaging.SendEmailResult[]{};
        try{
            List<EmailTemplate> templateList = [SELECT Id, 
                                                    Name
                                                FROM EmailTemplate 
                                                WHERE Name = :RecruitingAppCustomConstants.CANDIDATE_SEND_WELCOME_EMAIL_TEMPLATE
                                                WITH SECURITY_ENFORCED];
            templateListNullCheck(templateList);
            EmailTemplate templateObj = templateList[0];
            
            for(Id contactId : contactIdList){
                Messaging.SingleEmailMessage messageObj = new Messaging.SingleEmailMessage();
                messageObj.toAddresses = new String[] { contactId };
                messageObj.setTemplateId(templateObj.Id);
                messageObj.setTargetObjectId(contactId);
                messagesList.add(messageObj);
            }  
            resultList = Messaging.sendEmail(messagesList);
        }
        catch(Exception exObj){
            CustomExceptionHandler.logException(exObj, SendWelcomeEmailController.class.getName());
        }
        return resultList;
    }      
    
    /**
    * @description This method will check if the email template is null or not.
    * @author Indrajit Pal | 12-20-2024 
    * @param templateList 
    **/
    public static void templateListNullCheck(List<EmailTemplate> templateList){
        if(templateList.isEmpty() || templateList[0].Id == null){
            throw new CustomException(RecruitingAppCustomConstants.EMAIL_TEMPLATE_NOT_FOUND);
        }
    }
}