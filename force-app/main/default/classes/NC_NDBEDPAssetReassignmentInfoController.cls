/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_NDBEDPAssetReassignmentInfoController {
    
    /*
    *********************************************************
    @Method Name    : getAssetReassignmentInfo
    @description    : Show all assets availble for Reassignment
    @param          : String recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> getAssetReassignmentInfo(String recordId){
        Map<String, Object> resultMap = new Map<String, Object>();
        Boolean isError = true;
        List<EquipmentReassignWrapper> wrapList = new List<EquipmentReassignWrapper>();
        Map<Id, Map<Id, Asset__c>> assetToEqpMap = new Map<Id, Map<Id, Asset__c>>();
        Map<Id, Request_Equipment__c> requestEqpMap = new Map<Id, Request_Equipment__c>();
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        try {
            if(String.isNotBlank(recordId)) {
                for(Asset__c assetRecord : [SELECT Id, Name, Quantity__c, Equipment__r.Equipment_Name__c, Available_for_Reassignment__c, Authorization__c, Authorization__r.Regional_Center__c,Authorization__r.Consumer__c, Authorization__r.Vendor__c, Reassignment_Note__c, Last_Contact_Date_Time__c, Equipment__c, Vendor__c, Request__r.Regional_Center__c,Request__r.OwnerId,Request__r.CaseNumber FROM Asset__c WHERE Status__c =: NC_Constant.STATUS_ASSET_EQUIPMENT_REASSIGNMENT WITH SECURITY_ENFORCED]){	
                    if(!assetToEqpMap.containsKey(assetRecord.id)) {
                        assetToEqpMap.put(assetRecord.id, new Map<Id, Asset__c>());
                    }                
                    assetToEqpMap.get(assetRecord.id).put(assetRecord.Equipment__c, assetRecord);                    
                }

                for(Request_Equipment__c requestEquipmentRecord: [SELECT Equipment__c, Equipment__r.Equipment_Name__c, Request__c, Request__r.CaseNumber FROM Request_Equipment__c WHERE Request__c =: recordId AND Request__r.recordTypeId =: ndbedpRecordTypeId AND Request__r.Status = 'Pending Equipment Order' WITH SECURITY_ENFORCED]) {
                    requestEqpMap.put(requestEquipmentRecord.Equipment__c, requestEquipmentRecord);
                }

                for(Id assetId: assetToEqpMap.keySet()) {                    
                    for(Id equipmentId: assetToEqpMap.get(assetId).keySet()) {
                        if(requestEqpMap.containsKey(equipmentId)) {
                            Asset__c reassignedAsset = assetToEqpMap.get(assetId).get(equipmentId);
                            EquipmentReassignWrapper wrap = new EquipmentReassignWrapper();
                            wrap.requestId = reassignedAsset.Request__c;
                            wrap.requestNumber = reassignedAsset.Request__r.CaseNumber;
                            wrap.requestLink = '/' + wrap.requestId;
                            wrap.equipmentName = reassignedAsset.Equipment__r.Equipment_Name__c;
                            wrap.quantity = reassignedAsset.Quantity__c;
                            wrapList.add(wrap);
                        }
                    }                    
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        isError = (requestEqpMap.size() > 0 && wrapList.size() == 0)? true : false;
        resultMap.put('isError', isError);
        resultMap.put('data', wrapList);
        return resultMap;
    }

    public class EquipmentReassignWrapper
    {
        @AuraEnabled public Id requestId{get;set;}
        @AuraEnabled public String requestNumber{get;set;}
        @AuraEnabled public String requestLink{get;set;}
        @AuraEnabled public String equipmentName{get;set;}
        @AuraEnabled public String quantity{get;set;}
    }
}