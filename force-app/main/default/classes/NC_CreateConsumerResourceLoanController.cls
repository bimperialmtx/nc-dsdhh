/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 05-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_CreateConsumerResourceLoanController {
    /*
    *********************************************************
    @Method Name    : retrieveDefaults
    @description    : Retrieve resource loan record type id based on input id
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveDefaults(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        if(objectName == 'Contact') {
            Contact contactRecord = [SELECT Id, Regional_Center_Office__c,AccountId FROM Contact WHERE Id =: recordId WITH SECURITY_ENFORCED];
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Resource_Loan__c','Consumer_Resource_Loan'));
            if(contactRecord.Regional_Center_Office__c != NULL){
                result.put('regionalCenter',contactRecord.Regional_Center_Office__c);
            }
            if(contactRecord.AccountId!=NULL){
                result.put('agency',contactRecord.AccountId);
            }
            result.put('forConsumer',true);
        } else {
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Resource_Loan__c','Staff_Resource_Loan'));
            result.put('currentUser',UserInfo.getUserId());
            result.put('forConsumer',false);
        }
        return result;
    }
}