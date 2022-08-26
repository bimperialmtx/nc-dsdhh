/**
* @description       : Create contact attempt from consumer
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
public without sharing class NC_CreateContactAttemptController {
	/*
    *********************************************************
    @Method Name    : retrieveDefaults
    @description    : Retrieve Contact Attempt record type id based on input id
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveDefaults(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        if(objectName == 'Asset__c') {
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Contact_Attempt__c','Contact_Attempt_For_Asset'));
            result.put('forAsset',true);
        }else if(objectName == 'Case'){
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Contact_Attempt__c','Contact_Attempt_For_Request'));
            result.put('forAsset',false);
        }
        return result;
    }
}