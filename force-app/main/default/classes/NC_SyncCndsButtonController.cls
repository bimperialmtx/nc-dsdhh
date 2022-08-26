/**
 * Created by ashishpandey on 12/05/21.
 */

public with sharing class NC_SyncCndsButtonController {
    /*
    *********************************************************
    @Method Name    : getCNDSSyncStatus
    @description    : get CNDS contact details using record id
    @param          : String recordId
    @return         : Contact
    ********************************************************
    */
    @AuraEnabled
    public static Contact getCNDSSyncStatus(String recordId){
        Contact con;
        for(Contact obj:[SELECT Id,Allow_Resync__c,Cnds_Identifier__c,Allow_CNDS_Update_Sync__c,Comments__c from Contact WHERE Id=:recordId WITH SECURITY_ENFORCED]){
            con=obj;
        }
        return con;
    }

    /*
    *********************************************************
    @Method Name    : getCommentFromError
    @description    : Get error record related to consumer
    @param          : String recordId
    @return         : Error__c
    ********************************************************
    */
    @AuraEnabled
    public static Error__c getCommentFromError(String recordId){
        Error__c error;
        for(Error__c obj:[SELECT Id,Comments__c from Error__c WHERE Consumer__c=:recordId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1]){
            error=obj;
        }
        return error;
    }

    /*
    *********************************************************
    @Method Name    : sendLookupRequest
    @description    : Send lookup request to CNDS
    @param          : String recordId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void sendLookupRequest(String recordId){
        List<Contact> conlist= new List<Contact>();
        for(Contact obj:[SELECT Id, FirstName,MiddleName ,Social_Security_Number__c
        ,Staff_Member_Name__c,Cnds_Identifier__c,BirthDate,User_Id__c,Race__c,Primary_Language__c,Suffix,Hispanic_Ethnicity__c,LastName,Gender__c from Contact  where Id=:recordId WITH SECURITY_ENFORCED]){
            conlist.add(obj);
        }
        System.enqueueJob(new NC_LookupCNDS(conlist));

    }

    /*
    *********************************************************
    @Method Name    : sendUpdateRequest
    @description    : Send update request to CNDS
    @param          : String recordId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void sendUpdateRequest(String recordId){
        List<Contact> conlist= new List<Contact>();
        for(Contact obj:[SELECT Id, FirstName,MiddleName,BirthDate,Staff_Member_Name__c ,Social_Security_Number__c 
        ,Cnds_Identifier__c,User_Id__c,Race__c,Primary_Language__c,Suffix,Hispanic_Ethnicity__c,LastName,Gender__c from Contact  where Id=:recordId WITH SECURITY_ENFORCED]){
            conlist.add(obj);
        }
        System.enqueueJob(new NC_UpdateCNDSConsumer(conlist));

    }

}