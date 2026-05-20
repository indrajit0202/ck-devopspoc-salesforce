/**
 * @description       : This is a class to send email to conacts when a position is updated.
 * @author            : Indrajit Pal
 * @last modified on  : 12-25-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class PositionUpdateMailController {
    public static final string CANDIDATE_NAME_REPLACE_STRING = '[Candidate Name]';
    public static final string POSITION_TITLE_REPLACE_STRING = '[Position Title]';
    public static final string FIELD_UPDATE_REPLACE_STRING = '<li><strong>Status:</strong> New Position</li>';
    /**
    * @description This class takes all the candidate emails and send update email to all of them.
    * @author Indrajit Pal | 10-21-2024 
    * @param jobApplicationList 
    * @param posIdVsUpdtedValuesStrMap
    * @return Messaging.SendEmailResult[] 
    **/
    public static Messaging.SendEmailResult[] sendEmail(List<Job_Application__c> jobApplicationList, Map<Id, String> posIdVsUpdtedValuesStrMap){

        Messaging.SingleEmailMessage[] messagesList = new List<Messaging.SingleEmailMessage>();
        List<StaticResource> posUpdateTemplateList = [SELECT body 
                                                         FROM StaticResource 
                                                         WHERE Name = :RecruitingAppCustomConstants.POSITION_UPDATE_SEND_EMAIL_STATIC_RESOURCE
                                                         WITH SECURITY_ENFORCED];

        positiontemplateListNullCheck(posUpdateTemplateList);
        String bodyText = posUpdateTemplateList[0].body.toString();
        Messaging.SendEmailResult[] resultList = new Messaging.SendEmailResult[]{};
        try{
            for(Job_Application__c jobApplicationObj : jobApplicationList){
                String tempBodyText = bodyText;
                tempBodyText = tempBodytext.replace(CANDIDATE_NAME_REPLACE_STRING, jobApplicationObj.Candidate__r.First_Name__c +
                                                    RecruitingAppCustomConstants.BLANK_STRING + jobApplicationObj.Candidate__r.Last_Name__c);
                tempBodyText = tempBodyText.replace(POSITION_TITLE_REPLACE_STRING, jobApplicationObj.Position__r.Name);
                tempBodyText = tempBodyText.replace(FIELD_UPDATE_REPLACE_STRING, 
                                                    convertToHTMLList(posIdVsUpdtedValuesStrMap.get(jobApplicationObj.Position__r.Id)));
                Messaging.SingleEmailMessage messageObj = new Messaging.SingleEmailMessage();
                messageObj.toAddresses = new String[] { jobApplicationObj.Candidate__r.Email__c };
                messageObj.htmlbody = tempBodyText;
                messageObj.setSubject(RecruitingAppCustomConstants.JOB_POSITION_UPDATE_CLOUDKAPTAN_STRING);
                messagesList.add(messageObj);
            }   
            resultList = Messaging.sendEmail(messagesList);
        }
        catch(Exception exObj){
            CustomExceptionHandler.logException(exObj, PositionUpdateMailController.class.getName());
        }
        return resultList;
    } 

    /**
     * @description Converts a comma-separated string of field-value pairs into an HTML list format, 
     * where each pair is wrapped in an <li> tag with the field name in bold.
     * This method processes a string formatted as "Field Name --> Field Value" and returns a string 
     * suitable for inclusion in an HTML email or template.
     * 
     * Example input: 
     * 'Min Pay --> 100009.00, Location --> New York, NY, Status --> Pending Approval'
     * Example output:
     * <li><strong>Min Pay:</strong> 100009.00</li>
     * <li><strong>Location:</strong> New York, NY</li>
     * <li><strong>Status:</strong> Pending Approval</li>
     * 
     * @author Indrajit Pal | 12-18-2024 
     * @param input The input string containing comma-separated field-value pairs in the format 
     *              "Field Name --> Field Value".
     * @return String The resulting HTML-formatted string containing a list of the field-value pairs.
     */
    public static String convertToHTMLList(String input) {
        String output = '';
        
        // Split the input string by commas (field-value pairs are separated by commas)
        List<String> fieldValuePairs = input.split(',');

        for (String pair : fieldValuePairs) {
            // Split each pair by the delimiter '-->' to separate field and value
            List<String> parts = pair.split('-->');
            
            if (parts.size() == 2) {
                String field = parts[0].trim();  // Field name
                String value = parts[1].trim();  // Field value
                
                // Convert the field and value into HTML list format and append to the output
                output += '<li><strong>' + field + ':</strong> ' + value + '</li>';
            }
        }
        
        return output;
    }

    /**
    * @description This method is used for null checking in the positiontemplateList
    * @author Indrajit Pal | 12-20-2024 
    * @param posUpdateTemplateList 
    **/
    public static void positiontemplateListNullCheck(List<StaticResource> posUpdateTemplateList){
        if(posUpdateTemplateList.size() == 0 || posUpdateTemplateList[0].body == null){
            throw new CustomException(RecruitingAppCustomConstants.POSITION_TEMPLATE_NOT_FOUND);
        }
    }
}