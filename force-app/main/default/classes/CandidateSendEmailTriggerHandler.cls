/**
 * @description       : This class handles the sending of emails to the new candidates.
 * @author            : Indrajit Pal
 * @last modified on  : 12-27-2024
 * @last modified by  : Indrajit Pal
**/
public inherited sharing class CandidateSendEmailTriggerHandler extends ExtendedTriggerHandler {

    private Map<Id, Candidate__c> newIdVsCandidateMap;
    private Map<Id, Candidate__c> oldIdVsCandidateMap;
    private List<Candidate__c> newCandidateList;
    private List<Candidate__c> oldCandidateList;

    /**
    * @description Class constructor
    * @author Indrajit Pal | 10-02-2024 
    **/
    public CandidateSendEmailTriggerHandler() {
        this.newIdVsCandidateMap = (Map<Id, Candidate__c>) Trigger.newMap;
        this.oldIdVsCandidateMap = (Map<Id, Candidate__c>) Trigger.newMap;
        this.newCandidateList = (List<Candidate__c>) Trigger.new;
        this.oldCandidateList = (List<Candidate__c>) Trigger.old;
    }

    /**
    * @description This is a method which sends a welcome email to a candidate based on the candidate email.
    * @author Indrajit Pal | 10-02-2024 
    **/
    public override void afterInsert(){
        Map<Id, Candidate__c> newIdVsCandidateMap = triggerMapToNewMap(newIdVsCandidateMap.keySet());
        CandidateSendEmailTriggerHandler.CandidateContactWrapper candidateWrapperObj
                                = new CandidateSendEmailTriggerHandler.CandidateContactWrapper();
        // This list will store those candidates Ids to send email to
        List<Id> sendMailContactIdList = new List<Id>();

        try{
            candidateContactFilter(newIdVsCandidateMap.values(), sendMailContactIdList, candidateWrapperObj.candidateIdVsEmailMap);
    
            List<Contact> candidateContactList = candidateNotLinkedContactList(candidateWrapperObj.candidateIdVsEmailMap.values());
    
            for(Contact conObj : candidateContactList){
                candidateWrapperObj.withoutContactMap.put(conObj.Email, conObj);
            }
    
            createLinkWithContact(candidateWrapperObj, newIdVsCandidateMap, sendMailContactIdList);
    
            Database.insert(candidateWrapperObj.idVsNoContactFoundMap.values(), true, AccessLevel.SYSTEM_MODE);
    
            createLinkWithNewContacts(sendMailContactIdList, candidateWrapperObj.idVsNoContactFoundMap, newIdVsCandidateMap);
    
            Database.update(newIdVsCandidateMap.values(), true, AccessLevel.SYSTEM_MODE);
    
            SendWelcomeEmailController.sendEmail(sendMailContactIdList);
        }
        catch(Exception exObj){
            CustomExceptionHandler.logException(exObj, CandidateSendEmailTriggerHandler.class.getName());
        }
    }

    /**
    * @description This method is creating new contact based on the candidates
    * @author Indrajit Pal | 09-29-2024 
    * @param candidate 
    * @return Contact 
    **/
    public static Contact createNewContactHandler(Candidate__c candidate){
        return new Contact( LastName  = candidate.Last_Name__c, 
                            FirstName = candidate.First_Name__c, 
                            Email     = candidate.Email__c);
    }

    /**
    * @description : This method converts the Trigger.new read only to a new Map which can be read / write
    * @author Indrajit Pal | 09-29-2024 
    * @param triggerSet 
    * @return Map<Id, Candidate__c> 
    **/
    public static Map<Id, Candidate__c> triggerMapToNewMap(Set<Id> triggerSet) {
        Map<Id, Candidate__c> idVsCandidateMap = new Map<Id, Candidate__c>();
        
        if (triggerSet != null && !triggerSet.isEmpty()) { 
            List<Candidate__c> candidatesList = [
                SELECT Id, 
                        Email__c,
                        First_Name__c,
                        Last_Name__c,
                        Contact__c,
                        Contact__r.Email
                FROM Candidate__c 
                WHERE Id IN :triggerSet
                WITH SECURITY_ENFORCED
            ];
            
            for (Candidate__c candidateObj : candidatesList) {
                idVsCandidateMap.put(candidateObj.Id, candidateObj);
            }
        }
        
        return idVsCandidateMap;
    }

    /**
    * @description This method filters out those candidates Ids where there are a contact lookup 
                   present and the emails are matching and The candidates whose lookup are not present.
    * @author Indrajit Pal | 12-20-2024 
    * @param newIdVsCandidateMap 
    * @param sendMailContactIdList 
    * @param candidateIdVsEmailMap 
    **/
    public static void candidateContactFilter(List <Candidate__c> newIdVsCandidateMap, List <Id> sendMailContactIdList, 
                                              Map<Id, String> candidateIdVsEmailMap){
        for (Candidate__c candidateObj : newIdVsCandidateMap){
            // Check those candidates whose email is not null and equals to it's contact email
            if(candidateObj.Email__c != null && candidateObj.Contact__r.Email == candidateObj.Email__c){
                sendMailContactIdList.add(candidateObj.Contact__r.Id);
            }
            if(candidateObj.Email__c != null && candidateObj.Contact__c == null){
                candidateIdVsEmailMap.put(candidateObj.Id, candidateObj.Email__c);
            }
        }
        
    }

    /**
    * @description This method gets the contacts of those Candidates where contact email and candidate 
                   email are mathing but not linked with each other.
    * @author Indrajit Pal | 09-29-2024 
    * @param candidateEmailList 
    * @return List<Contact> 
    **/
    public static List<Contact> candidateNotLinkedContactList(List<String> candidateEmailList){
        List<Contact> candidateContactList = new List<Contact>();
        try{
            if(!candidateEmailList.isEmpty()){
                candidateContactList = [SELECT Id, 
                                                Email 
                                            FROM Contact 
                                            WHERE Email IN :candidateEmailList
                                            WITH SECURITY_ENFORCED];
            }
        }catch(Exception exObj){
            CustomExceptionHandler.logException(exObj, CandidateSendEmailTriggerHandler.class.getName());
        }
        
        return candidateContactList;
    }

   
    /**
    * @description : This method connects the Contacts with the true candidates in contact present, and if 
                     the contacts are not present then create the contact and link with the candidate
    * @author Indrajit Pal | 09-29-2024 
    * @param candidateWrapperObj 
    * @param newIdVsCandidateMap 
    * @param sendMailContactIdList 
    **/
    public static void createLinkWithContact(CandidateSendEmailTriggerHandler.CandidateContactWrapper candidateWrapperObj, 
                                             Map<Id, Candidate__c> newIdVsCandidateMap, List<Id> sendMailContactIdList){
        for(Id key : candidateWrapperObj.candidateIdVsEmailMap.keySet()){
            // if candidate email present in any contact email
            if(candidateWrapperObj.withoutContactMap.containsKey(candidateWrapperObj.candidateIdVsEmailMap.get(key))){
                if(newIdVsCandidateMap.get(key).Contact__c == null 
                   || candidateWrapperObj.withoutContactMap.get(candidateWrapperObj.candidateIdVsEmailMap.get(key)) != null){
                    newIdVsCandidateMap.get(key).Contact__c 
                        = candidateWrapperObj.withoutContactMap.get(candidateWrapperObj.candidateIdVsEmailMap.get(key)).id;
                    sendMailContactIdList.add(candidateWrapperObj.withoutContactMap.get(candidateWrapperObj.candidateIdVsEmailMap.get(key)).id);
                }
            }
            if(!candidateWrapperObj.withoutContactMap.containsKey(candidateWrapperObj.candidateIdVsEmailMap.get(key))){
                // System.debug(newIdVsCandidateMap.get(key));
                candidateWrapperObj.idVsNoContactFoundMap.put(key, createNewContactHandler(newIdVsCandidateMap.get(key)));
            }
        }
    } 


    /**
    * @description : This method attachs the contacts that are newly created with the candidated in the cndidate lookup field. 
    * @author Indrajit Pal | 09-29-2024 
    * @param sendMailContactId 
    * @param idVsNoContactFoundMap 
    * @param newIdVsCandidateMap 
    **/
    public static void createLinkWithNewContacts(List<Id> sendMailContactId, Map<Id, Contact> idVsNoContactFoundMap, 
                                                 Map<Id, Candidate__c> newIdVsCandidateMap){
        for(Id candidateId : idVsNoContactFoundMap.keySet()){
            if(newIdVsCandidateMap.get(candidateId) != null){
                newIdVsCandidateMap.get(candidateId).Contact__c = idVsNoContactFoundMap.get(candidateId).Id;
            }
            sendMailContactId.add(idVsNoContactFoundMap.get(candidateId).Id);
        }
    }

    /**
    * @description : Wrapper class
    * @author Indrajit Pal | 09-29-2024 
    * @return class 
    **/
    public inherited sharing class CandidateContactWrapper{
        Map<Id, String> candidateIdVsEmailMap = new Map<Id, String>();
        Map<String, Contact> withoutContactMap = new Map<String, Contact>();
        Map<Id, Contact> idVsNoContactFoundMap = new Map<Id, Contact>();
    }
}