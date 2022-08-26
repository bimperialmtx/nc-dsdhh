/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 11-08-2021
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_CommunicationAccessRequestHomeCtrl {
    /*
    *********************************************************
    @Method Name    : checkPermissions
    @description    : Check if Communication Access Request and Resource loan is createable for current user
    @param          : String endPoint,String req, String res, String error_Desc, String statusCode, Contact con
    @return         : Map<String, Boolean>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Boolean> checkPermissions(){
        Map<String, Boolean> returnMap = new Map<String, Boolean>();
        returnMap.put('isCommunicationCretable', false);
        returnMap.put('isResourceLoanCretable', false);
        try {
            if(Schema.SObjectType.Communication_Access_Request__c.isCreateable()) {
                returnMap.put('isCommunicationCretable', true);
            }
            if(Schema.SObjectType.Resource_Loan__c.isCreateable()) {
                returnMap.put('isResourceLoanCretable', true);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }
    
    /*
    *********************************************************
    @Method Name    : returnRecordTypeId
    @description    : Retrieve Communication Access Request record type id
    @param          : 
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static String returnRecordTypeId() {
        String communicationRecordTypeId = '';
       // public static Id communicationRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c', 'Generic_Request');
        //Id communicationRecordTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByName().get('Generic_Request').getRecordTypeId();
        communicationRecordTypeId = [SELECT Id, DeveloperName, Name FROM RecordType WHERE DeveloperName = 'Generic_Request'].Id;

        return communicationRecordTypeId;
    }

    /*
    *********************************************************
    @Method Name    : getResourceLoanRecordTypeId
    @description    : Retrieve Resource Loan record type id
    @param          : 
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static string getResourceLoanRecordTypeId(){
        try {
            return Schema.SObjectType.Resource_Loan__c.getRecordTypeInfosByDeveloperName().get('Consumer_Resource_Loan').getRecordTypeId();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}