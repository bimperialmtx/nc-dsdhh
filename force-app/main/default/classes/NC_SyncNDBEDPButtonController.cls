/**
 * Created by ashishpandey on 08/07/21.
 */

public with sharing class NC_SyncNDBEDPButtonController {
    /*
    *********************************************************
    @Method Name    : getNDBEDPSyncStatus
    @description    : get NDBEDP sync details from Consumer
    @param          : String recordId
    @return         : Contact
    ********************************************************
    */
    @AuraEnabled
    public static Contact getNDBEDPSyncStatus(String recordId){
        Contact con;
        for(Contact obj:[SELECT Id,Allow_NDBEDP_Resync__c,Patron_Id__c,Comments__c from Contact WHERE Id=:recordId WITH SECURITY_ENFORCED]){
            con=obj;
        }
        return con;
    }

    /*
    *********************************************************
    @Method Name    : getCommentFromError
    @description    : get NDBEDP error related to consumer
    @param          : String recordId
    @return         : Error__c
    ********************************************************
    */
    @AuraEnabled
    public static Error__c getCommentFromError(String recordId){
        Error__c error;
        for(Error__c obj:[SELECT Id,Comments__c,Type__c from Error__c WHERE Consumer__c=:recordId AND Type__c='NDBEDP Exception' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1]){
            error=obj;
        }
        return error;
    }

    /*
    *********************************************************
    @Method Name    : sendLookupRequest
    @description    : send lookup request to NDBEDP
    @param          : String recordId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void sendLookupRequest(String recordId){ 
        List<Contact> conlist= new List<Contact>();
        for(Contact obj:[SELECT Id,Ethnicity__c,OtherCountryCode,OtherStateCode,Patron_Contact_Obj_Add__c,Patron_Type__c,Allow_NDBEDP_Resync__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,Patron_Contact_Obj_Email__c,County__c,Preferred_Contact_Method__c,Status_Code__c,Reg_End_Date__c,Patron_Obj__c,Address_Link_Obj__c,Patron_Contact_Obj__c,Library_ID__c,Email,Alt_Phone_Number__c,Work_Phone_Number__c,Cell_Phone_Number__c, FirstName,MiddleName,BirthDate,Primary_Language__c,Suffix,Hispanic_Ethnicity__c,LastName,Gender__c,MobilePhone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,Patron_ID__c from Contact  where Id=:recordId WITH SECURITY_ENFORCED]){
            conlist.add(obj);
        }
        System.enqueueJob(new NC_NDBEDP_PatronSearch(conlist));

    }
}