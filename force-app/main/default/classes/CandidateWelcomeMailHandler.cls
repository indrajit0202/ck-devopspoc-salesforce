/**
 * @description       : This class basically sends a welcome email to a candidate based on the candidate email.
 * @author            : Indrajit Pal
 * @last modified on  : 09-29-2024
 * @last modified by  : Indrajit Pal
**/
public with sharing class CandidateWelcomeMailHandler {
    /**
    * @description : This is a method which sends a welcome email to a candidate based on the candidate email.
    * @author Indrajit Pal | 09-28-2024 
    * @param newCandidateTriggerNewMap 
    **/
    public static void sendMailCandidate(Map<Id, Candidate__c> newCandidateTriggerNewMap){

        Map<Id, Candidate__c> newCandidateMap = triggerMapToNewMap(newCandidateTriggerNewMap.keySet());
        CandidateWelcomeMailHandler.CandidateContactWrapper candidateWrapperObj = new CandidateWelcomeMailHandler.CandidateContactWrapper();
        // This list will store those candidates Ids to send email to
        List <Id> sendMailContactId = new List<Id>();

        candidateContactFilter(newCandidateMap.values(), sendMailContactId, candidateWrapperObj.candidateIdEmailMap);

        List<Contact> candidateContactList = candidateNotLinkedContactList(candidateWrapperObj.candidateIdEmailMap.values());

        for(Contact conObj : candidateContactList){
            candidateWrapperObj.withoutContactMap.put(conObj.Email, conObj);
        }

        createLinkWithContact(candidateWrapperObj, newCandidateMap, sendMailContactId);

        insert candidateWrapperObj.contactsNotFoundMap.values();

        createLinkWithNewContacts(sendMailContactId, candidateWrapperObj.contactsNotFoundMap, newCandidateMap);

        update newCandidateMap.values();

        // System.debug(sendMailContactId);
        SendWelcomeEmailController.sendEmail(sendMailContactId);
    }


    /**
    * @description 
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
    * @param triggerMap 
    * @return Map<Id, Candidate__c> 
    **/
    public static Map<Id, Candidate__c> triggerMapToNewMap (Set<Id> triggerMap){
        return new Map<Id, Candidate__c>([SELECT Id, 
                                                 Email__c ,
                                                 First_Name__c,
                                                 Last_Name__c,
                                                 Contact__c,
                                                 Contact__r.Email
                                                 FROM Candidate__c 
                                                 WHERE Id IN :triggerMap
                                                 WITH SYSTEM_MODE]);
    }

    /**
    * @description : This method filters out those candidates Ids where there are a contact lookup present and the emails are matching and The candidates whose lookup are not present.
    * @author Indrajit Pal | 09-29-2024 
    * @param newCandidateMap 
    * @param sendMailContactId 
    * @param candidateIdEmailMap 
    **/
    public static void candidateContactFilter(List <Candidate__c> newCandidateMap, List <Id> sendMailContactId, Map<Id, String> candidateIdEmailMap){
        for (Candidate__c candidate : newCandidateMap){
            // Check those candidates whose email is not null and equals to it's contact email
            if(candidate.Email__c != null && candidate.Contact__r.Email == candidate.Email__c){
                sendMailContactId.add(candidate.Contact__r.Id);
            }
            if(candidate.Email__c != null && candidate.Contact__c == null){
                candidateIdEmailMap.put(candidate.Id, candidate.Email__c);
            }
        }
    }

    /**
    * @description : This method gets the contacts of those Candidates where contact email and candidate email are mathing but not linked with each other.
    * @author Indrajit Pal | 09-29-2024 
    * @param candidateIdEmailMap 
    * @return List<Contact> 
    **/
    public static List<Contact> candidateNotLinkedContactList(List<String> candidateIdEmailMap){
        return [SELECT Id, 
                       Email 
                       FROM Contact 
                       WHERE Email IN :candidateIdEmailMap
                       WITH SYSTEM_MODE];
    }

   
    /**
    * @description : In this method we are connecting the Contacts with the true candidates in contact present, and if the contacts are not present then create the contact and link with the candidate
    * @author Indrajit Pal | 09-29-2024 
    * @param candidateWrapperObj 
    * @param newCandidateMap 
    * @param sendMailContactId 
    **/
    public static void createLinkWithContact(CandidateWelcomeMailHandler.CandidateContactWrapper candidateWrapperObj, Map<Id, Candidate__c> newCandidateMap, List<Id> sendMailContactId){
        for(Id key : candidateWrapperObj.candidateIdEmailMap.keySet()){
            // if candidate email present in any contact email
            if(candidateWrapperObj.withoutContactMap.containsKey(candidateWrapperObj.candidateIdEmailMap.get(key))){
                newCandidateMap.get(key).Contact__c = candidateWrapperObj.withoutContactMap.get(candidateWrapperObj.candidateIdEmailMap.get(key)).id;
                sendMailContactId.add(candidateWrapperObj.withoutContactMap.get(candidateWrapperObj.candidateIdEmailMap.get(key)).id);
            }
            if(!candidateWrapperObj.withoutContactMap.containsKey(candidateWrapperObj.candidateIdEmailMap.get(key))){
                System.debug(newCandidateMap.get(key));
                candidateWrapperObj.contactsNotFoundMap.put(key, createNewContactHandler(newCandidateMap.get(key)));
            }
        }
    } 


    /**
    * @description : In this method we are attaching the contacts that are newly created with the candidated in the cndidate lookup field. 
    * @author Indrajit Pal | 09-29-2024 
    * @param sendMailContactId 
    * @param contactsNotFoundMap 
    * @param newCandidateMap 
    **/
    public static void createLinkWithNewContacts(List<Id> sendMailContactId, Map<Id, Contact> contactsNotFoundMap, Map<Id, Candidate__c> newCandidateMap){
        for(Id candidateId : contactsNotFoundMap.keySet()){
            newCandidateMap.get(candidateId).Contact__c = contactsNotFoundMap.get(candidateId).Id;
            sendMailContactId.add(contactsNotFoundMap.get(candidateId).Id);
        }
    }

    /**
    * @description : Wrapper class
    * @author Indrajit Pal | 09-29-2024 
    * @return class 
    **/
    public class CandidateContactWrapper{
        Map<Id, String> candidateIdEmailMap = new Map<Id, String>();
        Map<String, Contact> withoutContactMap = new Map<String, Contact>();
        Map<Id, Contact> contactsNotFoundMap = new Map<Id, Contact>();
    }
}