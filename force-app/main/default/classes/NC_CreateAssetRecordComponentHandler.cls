/*
*   Class Name: NC_CreateAssetRecordComponentHandler
*   Description: Aura Component Handler to Clone Asset Record
*
*   Date            New/Modified         User                 Identifier                Description
*   13/05/2020         New         Shubham Dadhich(mtx)
*/

public with sharing class NC_CreateAssetRecordComponentHandler {
    
    /*
    *********************************************************
    @Method Name    : cloneAssetRecord
    @description    : Clone Asset Record as Child of Current Record
    @param          : Id recordId
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static String cloneAssetRecord(Id recordId){
        Id recordTypeIdAssetRelpacement = NC_Utility.RecordTypeUtilityMethod('Asset__c',NC_Constant.ASSET_REPLACEMENT_RECORD_TYPE);
        String result = NC_Constant.ASSET_RECORD_VALIDATION_ERROR;
        Asset__c assetRecord = [SELECT Id, RecordTypeId, Equipment__c, Equipment__r.Amount_Authorized__c, Contact__c, Request__c, Authorization__c, Status__c, Returned_to_Vendor__c, Regional_Center_Receipt__c, Vendor__c, Parent_Asset__c FROM Asset__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        if(assetRecord.Status__c == NC_Constant.ASSET_STATUS_EQUIPMENT_DEFECTIVE || assetRecord.Status__c == NC_Constant.ASSET_STATUS_EQUIPMENT_UNAVAILABLE){
            Asset__c assetRecordClone = assetRecord.clone(false, false, false, false);
            assetRecordClone.Status__c = 'Created';
            assetRecordClone.Returned_to_Vendor__c = false;
            assetRecordClone.RecordTypeId = recordTypeIdAssetRelpacement;
            assetRecordClone.Amount_Authorized__c = assetRecord.Equipment__r.Amount_Authorized__c;
            assetRecordClone.Parent_Asset__c = recordId;
            // assetRecordClone.Authorization__c = null;
            if(Schema.SObjectType.Asset__c.isCreateable()){
                insert assetRecordClone;
            }
            result = assetRecordClone.Id;
        }
        return result;
    }
}