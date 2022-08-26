/*
*********************************************************
Apex Class Name    : NC_CommunityLoginController
Created Date       : 
@description       : 
@author            : Gourav Nirwal
Modification Log:
Ver   Date         Author                               Modification
*********************************************************
*/
public without sharing class NC_CommunityLoginController {
    /*
    *********************************************************
    @Method Name    : isContactExist
    @description    : Check if Contact exist and user is active or not
    @param          : String jsonString
    @return         : ContactInfoWrapper
    ********************************************************
    */
    @AuraEnabled 
    public static ContactInfoWrapper isContactExist(String jsonString) {
        ContactInfoWrapper infoWrapperInstance = new ContactInfoWrapper();
        ContactWrapper contactWrapperInstance = (ContactWrapper)JSON.deserialize(jsonString, ContactWrapper.Class);
        List<Contact> listOfContact = getContact(contactWrapperInstance);        
        if (!listOfContact.isEmpty()) {
            infoWrapperInstance.isContactExist = true;            
            List<User> listOfUser = [SELECT Id, IsActive FROM User WHERE ContactId =: listOfContact[0].Id AND ContactId != null];
            infoWrapperInstance.contactRecord = listOfContact[0];
            if (!listOfUser.isEmpty()) {
                infoWrapperInstance.isUserExist = true;
                if (listOfUser[0].isActive == false) {
                    infoWrapperInstance.error = NC_Constant.USER_IS_INACTIVE;
                }
            }
        }
        return infoWrapperInstance;
    }
    
    /*
    *********************************************************
    @Method Name    : registerUser
    @description    : Register new portal user
    @param          : String jsonString
    @return         : ContactInfoWrapper
    ********************************************************
    */
    @AuraEnabled 
    public static ContactInfoWrapper registerUser(String jsonString) {
        ContactInfoWrapper infoWrapperInstance = new ContactInfoWrapper();
        ContactWrapper contactWrapperInstance = (ContactWrapper)JSON.deserialize(jsonString, ContactWrapper.Class);
        List<Contact> listOfContact = getContact(contactWrapperInstance);

        if (!listOfContact.isEmpty()) {
            String email = contactWrapperInstance.email;
            listOfContact[0].Email = email;
            update listOfContact;
            infoWrapperInstance.contactRecord = listOfContact[0];
            infoWrapperInstance = selfRegister( listOfContact[0].Id, contactWrapperInstance.userName, listOfContact[0].firstName, listOfContact[0].lastName, email, contactWrapperInstance.password, 
                contactWrapperInstance.confirmPassword, listOfContact[0].AccountId, true,NC_Constant.SITE_BASE_URL);            
        }
        return infoWrapperInstance;
    }

    /*
    *********************************************************
    @Method Name    : logInUser
    @description    : redirect to login user
    @param          : String jsonString
    @return         : ContactInfoWrapper
    ********************************************************
    */
    @AuraEnabled 
    public static ContactInfoWrapper logInUser(String jsonString) {
        ContactInfoWrapper infoWrapperInstance = new ContactInfoWrapper();
        ContactWrapper contactWrapperInstance = (ContactWrapper)JSON.deserialize(jsonString, ContactWrapper.Class);
        String userId;
        
        //List<Contact> listOfContact = getContact(contactWrapperInstance);
        string communityUrl = '';
        if (contactWrapperInstance.password != null && (contactWrapperInstance.password).length() > 1) {
            communityUrl =  NC_Constant.AFTER_LOGIN_URL;
        }

        List<User> listOfUser = [SELECT Id, userName FROM User WHERE userName =: contactWrapperInstance.userName AND IsActive = True AND ContactId != null];
        ApexPages.PageReference lgn = Site.login(contactWrapperInstance.userName, contactWrapperInstance.password, communityUrl);
        if(!Test.isRunningTest()) {
            infoWrapperInstance.redirectUrl = lgn.getUrl();
            aura.redirect(lgn);
        }
        return infoWrapperInstance;
    }
    
    /*
    *********************************************************
    @Method Name    : forgotPassword
    @description    : forgot password for user
    @param          : String jsonString
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static String forgotPassword(String jsonString) {
        ContactInfoWrapper infoWrapperInstance = new ContactInfoWrapper();
        ContactWrapper contactWrapperInstance = (ContactWrapper)JSON.deserialize(jsonString, ContactWrapper.Class);
        String userId;

        String url = './CheckPasswordResetEmail';
        try {
            if(!Site.isValidUsername(contactWrapperInstance.userName)) {
                return Label.Site.invalid_email;
            }
            Site.forgotPassword(contactWrapperInstance.userName);
            ApexPages.PageReference checkEmailRef = new PageReference(url);
            if(!Test.isRunningTest()){
                aura.redirect(checkEmailRef);
            }
            return 'success';
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
        
    }
    
    /*
    *********************************************************
    @Method Name    : selfRegister
    @description    : Register new user
    @param          : Id contactId, String userName, String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, Boolean includePassword, String startUrl
    @return         : ContactInfoWrapper
    ********************************************************
    */
    public static ContactInfoWrapper selfRegister(Id contactId, String userName, String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, Boolean includePassword, String startUrl) {
        Savepoint sp = null;
        ContactInfoWrapper infoWrapperInstance = new ContactInfoWrapper();
        try {
            sp = Database.setSavepoint();
            
            User userRecord = new User();
            userRecord.Username = userName;
            userRecord.ProfileId = getProfileId();
            userRecord.Email = email;            
            userRecord.FirstName = firstname;
            userRecord.LastName = lastname;   
            userRecord.ContactId = contactId;       
            
            Contact c = new Contact (id = contactId);
            Contact[] sameEmails = [select id, email from Contact where AccountID =: accountId AND email =: email];
            If (sameEmails.size() > 1) {
                c.AccountID = NC_Constant.NCDHHS_ACCOUNT_ID;
                update c;
                accountId = NC_Constant.NCDHHS_ACCOUNT_ID;
            }
            
            
            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            userRecord.CommunityNickname = nickname;
                        
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword)) {
                    infoWrapperInstance.error = Label.site.passwords_dont_match;
                    return infoWrapperInstance;
                }
                validatePassword(userRecord, password, confirmPassword);
            }
            else {
                password = null;
            }

            if (!getUserExist(userName)) {
                infoWrapperInstance.error = NC_Constant.USER_ALREADY_EXISTS;
                return infoWrapperInstance;   
            }
            
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createPortalUser(userRecord, accountId, password);
            // create a fake userId for test.
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';           
            }
            if (userId != null) { 
                if (password != null && password.length() > 1) {
                    ApexPages.PageReference lgn = Site.login(userName, password, startUrl);
                    if (!Test.isRunningTest()) {
                        infoWrapperInstance.redirectUrl = lgn.getUrl();                     
                        aura.redirect(lgn);
                    }
                }                
                return infoWrapperInstance;
            } 
            return infoWrapperInstance;
        } catch (Exception ex) {
            Database.rollback(sp);
            infoWrapperInstance.error = ex.getMessage();
            return infoWrapperInstance;            
        }
    }

    /*
    *********************************************************
    @Method Name    : isValidPassword
    @description    : password validation
    @param          : String password, String confirmPassword
    @return         : boolean
    ********************************************************
    */
    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
          
    /*
    *********************************************************
    @Method Name    : validatePassword
    @description    : password validation for user
    @param          : User u, String password, String confirmPassword
    @return         : void
    ********************************************************
    */
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }

    /*
    *********************************************************
    @Method Name    : getContact
    @description    : Get contact from Wrapper
    @param          : ContactWrapper contactWrapperInstance
    @return         : List<Contact>
    ********************************************************
    */
    private static List<Contact> getContact(ContactWrapper contactWrapperInstance) {
        Integer len = (contactWrapperInstance.lastName).length();
        String ssn = contactWrapperInstance.ssn;
        List<Contact> listOfContact = [
            SELECT Id, LastName, FirstName, Name, Email, Birthdate, AccountId               
            FROM Contact
            LIMIT 1];
        return listOfContact;
    }

    /*
    *********************************************************
    @Method Name    : getProfileId
    @description    : Get profile id by name
    @param          : 
    @return         : Id
    ********************************************************
    */
    public static Id getProfileId() {
        return [SELECT Id FROM Profile WHERE Name =: NC_Constant.VENDOR_USER].Id;
    }

    /*
    *********************************************************
    @Method Name    : getUserExist
    @description    : Check if user exist
    @param          : String userName
    @return         : Boolean
    ********************************************************
    */
    public static Boolean getUserExist(String userName) {
        List<User> listOfUser = [SELECT Id FROM User WHERE UserName =: userName AND Profile.Name =: NC_Constant.VENDOR_USER AND ContactId != null];
        return listOfUser.isEmpty();
    }

    public class ContactWrapper {
        @AuraEnabled public String ssn {get; set;}
        @AuraEnabled public Date dob {get; set;}
        @AuraEnabled public String lastName {get; set;}
        @AuraEnabled public String middleName {get; set;}
        @AuraEnabled public String firstName {get; set;}
        @AuraEnabled public String email {get; set;}
        @AuraEnabled public String userName {get; set;}
        @AuraEnabled public String password {get; set;}
        @AuraEnabled public String confirmPassword {get; set;}
    }

    public class ContactInfoWrapper {
        @AuraEnabled public Boolean isContactExist {get; set;}
        @AuraEnabled public Boolean isUserExist {get; set;}
        @AuraEnabled public String redirectUrl {get; set;}
        @AuraEnabled public String error {get; set;}
        @AuraEnabled public Contact contactRecord {get; set;}

        public ContactInfoWrapper() {
            this.isContactExist = false;
            this.isUserExist = false;
            this.redirectUrl = null;
            this.error = null;
            this.contactRecord = new Contact();
        }
    }
}