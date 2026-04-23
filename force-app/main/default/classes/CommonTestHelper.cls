/**
 * @description       : Helper class to create Object records.
 * @author            : Indrajit Pal
 * @last modified on  : 12-27-2024
 * @last modified by  : Indrajit Pal
**/
public with sharing class CommonTestHelper {

    /**
    * @description This method is used to create test contacts.
    * @author Indrajit Pal | 10-30-2024 
    * @param firstName 
    * @param lastName 
    * @param email 
    * @return Contact 
    **/
    public static Contact createContact(String firstName, String lastName, String email){
        Contact con = new Contact(FirstName = firstName, LastName = lastName, Email = email);
        return con;
    }

    /**
    * @description : This method creates a new user baeed on the given profile, email and alias / nickname
    * @author Indrajit Pal | 10-02-2024 
    * @param profileName 
    * @param userEmail 
    * @param userAlias 
    * @return User 
    **/
    public static User createUserWithProfile(String profileName, String userEmail, String userAlias) {
        List<Profile> profileList = [SELECT Id 
                                        FROM
                                        Profile
                                        WHERE
                                        Name = :profileName
                                        WITH SYSTEM_MODE];
        Profile expetedProfile = profileList[0];
        User newUserObj = new User(
                        FirstName = 'Test1',
                        LastName = 'User1',
                        ProfileId = expetedProfile.Id,
                        Alias = userAlias,
                        Email = userEmail,
                        Username = userAlias+'@testorg.com',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        LocaleSidKey = 'en_US',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US'
        );
        return newUserObj;
    }

    /**
    * @description This method is used to get the user with the email for Run As method.
    * @author Indrajit Pal | 12-20-2024 
    * @param email 
    * @return User 
    **/
    public static User findUserWithEmail(String email){
        List<User> userList = [SELECT Id, Name, Email
                            FROM User
                            WHERE Email = :email
                            WITH SYSTEM_MODE];
        User expectedUser = userList[0];
        return expectedUser;
    }

    /**
    * @description Create candidate with contact linked with it
    * @author Indrajit Pal | 10-30-2024 
    * @param firstName 
    * @param lastName 
    * @param email 
    * @return Candidate__c 
    **/
    public static Candidate__c createCandidateWithContact(String firstName, String lastName, String email){

        Contact newContactObj = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email
        );

        Database.insert(newContactObj, true, AccessLevel.SYSTEM_MODE);

        Candidate__c newCandidateObj = new Candidate__c(
            First_Name__c = firstName,
            Last_Name__c = lastName,
            Email__c = email,
            Contact__c = newContactObj.Id
            );
        return newCandidateObj;
    }

    /**
    * @description Create candidate with contact not linked with it
    * @author Indrajit Pal | 10-30-2024 
    * @param firstName 
    * @param lastName 
    * @param email 
    * @return Candidate__c 
    **/
    public static Candidate__c createCandidateWithoutContact(String firstName, String lastName, String email){
        Candidate__c newCandidateObj = new Candidate__c(
            First_Name__c = firstName,
            Last_Name__c = lastName,
            Email__c = email
        );
        return newCandidateObj;
    }

    /**
    * @description 
    * @author Indrajit Pal | 10-30-2024 
    * @param positionName 
    * @return Position__c 
    **/
    public static Position__c createPosition(String positionName){

        Position__c newPositionObj = new Position__c(
            Name = positionName
        );
        
        return newPositionObj;
    }

    /**
    * @description create job posting obj and populate the position and site then return the instance.
    * @author Indrajit Pal | 11-10-2024 
    * @param positionId 
    * @param siteId 
    * @return Job_Posting__c 
    **/
    public static Job_Posting__c createJobPosting(Id positionId, Id siteId){

        Job_Posting__c newPostingObj = new Job_Posting__c();
        newPostingObj.Position__c = positionId;
        newPostingObj.Employment_Website__c = siteId;
 
        return newPostingObj;
    }

    /**
    * @description Create job application with candidate obj and return the instance.
    * @author Indrajit Pal | 12-19-2024 
    * @param candidateObj 
    * @return Job_Application__c 
    **/
    public static Job_Application__c createJobApplication(Candidate__c candidateObj){
        Job_Application__c jobApplicationObj = new Job_Application__c();
        jobApplicationObj.Candidate__c = candidateObj.Id;
        
        return jobApplicationObj;
    }  
    
    /**
    * @description This method is to create test employment website
    * @author Indrajit Pal | 12-26-2024 
    * @return Employment_Website__c 
    **/
    public static Employment_Website__c crateEmploymentwebsite(){
        Employment_Website__c testSiteObj = new Employment_Website__c();
        testSiteObj.Name = 'LinkedinTest';
        testSiteObj.Price_Per_Post__c = 10;
        testSiteObj.Maximum_Budget__c = 100;
        testSiteObj.Web_Address__c = 'https://linkedin.test.com/in';
        return testSiteObj;
    }
}