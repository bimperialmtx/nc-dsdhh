/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class nc_ServiceRequest {

    /*
    *********************************************************
    @Method Name    : checkNDBEDP
    @description    : Check request is NDBEDP or not
    @param          : String recordId
    @return         : Boolean
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static Boolean checkNDBEDP(String recordId){
        List<Case>parentCaseList = new List<Case>();
        if(String.isNotBlank(recordId)){
            parentCaseList = [SELECT Id, CaseNumber FROM Case WHERE Id=:recordId AND recordType.DeveloperName = 'NDBEDP' AND Status = 'Approved'];
            if(parentCaseList.size()>0){
                return true;
               
            }
            else{
                return false;
                
            }
        }
        return false;
    }

    /*
    *********************************************************
    @Method Name    : getParentCaseNumber
    @description    : Get parent case number
    @param          : String recordId
    @return         : String
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static String getParentCaseNumber(String recordId){
        String parentCase='';
        if(String.isNotBlank(recordId)){
            parentCase = [SELECT Id, CaseNumber FROM Case WHERE Id=:recordId].CaseNumber;
            return parentCase;
    }
    return null;
}
    
    /*
    *********************************************************
    @Method Name    : checkUserProfile
    @description    : Check if current user profile is NDBEDP Assessor or not
    @param          : 
    @return         : Boolean
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static Boolean checkUserProfile(){
        User use=[SELECT Id,Profile.Name  FROM User
                     WHERE id = :UserInfo.getUserId() AND Profile.Name!=null];
        if(use.Profile.Name == 'NDBEDP Assessor'){
            return false;
        }
        else{
            return true;
        }
    }

    /*
    *********************************************************
    @Method Name    : getParentCaseNumberId
    @description    : Get parent case number
    @param          : String recordId
    @return         : Case
    ********************************************************
    */
@AuraEnabled(cacheable=true)
public static Case getParentCaseNumberId(String recordId){
    Case parentCaseId=new Case();
    if(String.isNotBlank(recordId)){
        parentCaseId = [SELECT Id, CaseNumber,ContactId FROM Case WHERE Id=:recordId];
        return parentCaseId;
}
return null;
}

    /*
    *********************************************************
    @Method Name    : saveData
    @description    : save case data
    @param          : String dataObj
    @return         : Case
    ********************************************************
    */
    @AuraEnabled
    public static Case saveData(String dataObj){
        try {
            RequestDataWrapper requestWrapper = (RequestDataWrapper) JSON.deserialize(dataObj, RequestDataWrapper.class);
            Case caseItem = requestWrapper.RequesDataHandler();
            //insert caseItem;
            return NC_ServiceRequestHelper.saveData(caseItem);
        }
        catch (Exception e) {
            throw new AuraHandledException('Error: '+e.getMessage());
                }

    }

    public class RequestDataWrapper{
        @AuraEnabled public string requestType;
        @AuraEnabled public string requestAudience;
        @AuraEnabled public string requestSubType;
        @AuraEnabled public string ContactId;
        @AuraEnabled public string parentCaseId;
       // @AuraEnabled public string parentCaseId;

        public Case RequesDataHandler() {
            Case caseValue = new Case();
            caseValue.ContactId=contactId;
            if(requestSubType == 'Follow-up'){
            caseValue.recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDBEDP Follow-up').getRecordTypeId();
            }
            else if(requestSubType == 'Additional Part'){
                caseValue.recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDBEDP Additional Parts').getRecordTypeId();
            }
            else if(requestSubType == 'Repair Request'){
                caseValue.recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDBEDP Repair Request').getRecordTypeId();
            }
            else if(requestSubType == 'Additional Training'){
                caseValue.recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDBEDP Additional Training').getRecordTypeId();
            }
            caseValue.Request_Type__c=requestType;
            caseValue.Request_Sub_type__c=requestSubType;
            caseValue.Request_Audience__c=requestAudience;
            caseValue.Parent_NDBEDP__c = parentCaseId;
            caseValue.Status = 'Submitted';
            return caseValue;
    }
    
}
}