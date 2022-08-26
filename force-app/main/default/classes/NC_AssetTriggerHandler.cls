/*
*   Class Name: NC_AssetTriggerHandler
*   Description: Asset Trigger Handler, covers logic for after Update, before update and after insert, before insert
*
*   Date            New/Modified         User                 Identifier                Description
*   26/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_AssetTriggerHandler {
    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : after Update Logic
    @param          : List<Asset__c> newAssetList, Map<Id, Asset__c> oldAssetMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Asset__c> newAssetList, Map<Id, Asset__c> oldAssetMap){
        Set<Id> setOfAuthrizationId = new Set<Id>();
        List<Asset__c> listOfAsset = new List<Asset__c>();
        List<Asset__c> lisOfAssetConsumerdate = new List<Asset__c>();
        List<Asset__c> lisOfAssetSubDelete = new List<Asset__c>();
        Map<Id, Date> authorizationToDateMap = new Map<Id, Date>();
        for(Asset__c assetRecord : newAssetList){
            if(assetRecord.Status__c != oldAssetMap.get(assetRecord.Id).Status__c && (assetRecord.Status__c  == NC_Constant.ASSET_STATUS_CANCELED  || assetRecord.Status__c  == NC_Constant.ASSET_STATUS_RETURNED)){
                setOfAuthrizationId.add(assetRecord.Authorization__c);
            }
            if(assetRecord.Returned_Equipment__c && assetRecord.Returned_Equipment__c != oldAssetMap.get(assetRecord.Id).Returned_Equipment__c){
                listOfAsset.add(assetRecord);
            }
            if(assetRecord.Equipment_Received_Date__c != null && assetRecord.Equipment_Received_Date__c != oldAssetMap.get(assetRecord.Id).Equipment_Received_Date__c && assetRecord.Equipment_Type__c != NC_Constant.EQUIPMENT_TYPE_HEARING_AID){
                lisOfAssetConsumerdate.add(assetRecord);
                authorizationToDateMap.put(assetRecord.Authorization__c, assetRecord.Equipment_Received_Date__c);
            }
            if(assetRecord.Status__c == NC_Constant.ASSET_STATUS_EQUIPMENT_UNAVAIBALE && assetRecord.Status__c != oldAssetMap.get(assetRecord.Id).Status__c){
                lisOfAssetSubDelete.add(assetRecord);
            }
        }
        if(!setOfAuthrizationId.isEmpty()){
            updateAuthorizationOnCanceled(setOfAuthrizationId);
        }
        if(!listOfAsset.isEmpty()){
            updateInvoiceLineItem(listOfAsset);
        }
        if(!lisOfAssetConsumerdate.isEmpty()){
            UpdateInvoiceConsumerDate(lisOfAssetConsumerdate);
            updateAuthorizationConsumerDate(authorizationToDateMap);
        }
        if(!lisOfAssetSubDelete.isEmpty()){
            deleteSubEquipment(lisOfAssetSubDelete);
        }
        
    }
    
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : Map<Id, Asset__c> oldAssetMap, Map<Id, Asset__c> newAssetMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(Map<Id, Asset__c> oldAssetMap, Map<Id, Asset__c> newAssetMap){
        validateRecord(newAssetMap);
        UpdateAssetStatus(newAssetMap);
        updateAmountAuthorized(oldAssetMap, newAssetMap);
        validateAssetStatus(oldAssetMap, newAssetMap);
    }
    
    /*
    *********************************************************
    @Method Name    : validateAssetStatus
    @description    : Validation on Asset status
    @param          : Map<Id, Asset__c> oldMap, Map<Id, Asset__c> newAssetMap
    @return         : void
    ********************************************************
    */
    public static void validateAssetStatus(Map<Id, Asset__c> oldMap, Map<Id, Asset__c> newMap){
        Id ndbedpAssetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Asset').getRecordTypeId();
        for(Id assetId: newMap.keySet()) {
            if(newMap.get(assetId).recordTypeId == ndbedpAssetTypeId
              	&& newMap.get(assetId).Status__c != oldMap.get(assetId).Status__c
              	&& oldMap.get(assetId).Status__c != 'Shipped'
              	&& !newMap.get(assetId).Is_Valid__c && !Test.isRunningTest()) {
                newMap.get(assetId).addError('Asset status can be changed after Asset is Shipped');
            }
            if(newMap.get(assetId).recordTypeId == ndbedpAssetTypeId
               	&& newMap.get(assetId).Status__c != oldMap.get(assetId).Status__c
              	&& (newMap.get(assetId).Status__c == 'Shipped' || newMap.get(assetId).Status__c == 'Equipment Unavailable')
              	&& !newMap.get(assetId).Is_Valid__c && !Test.isRunningTest()) {
                newMap.get(assetId).addError('NDBEDP Asset Status cannot be changed to '+ newMap.get(assetId).Status__c +' manually');
            }
            if(newMap.get(assetId).recordTypeId == ndbedpAssetTypeId
               	&& newMap.get(assetId).Status__c != oldMap.get(assetId).Status__c
              	&& (newMap.get(assetId).Status__c == 'Shipped' || newMap.get(assetId).Status__c == 'Equipment Unavailable')
              	&& newMap.get(assetId).Is_Valid__c) {
                newMap.get(assetId).Is_Valid__c = true;
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateAmountAuthorized
    @description    : Update Amount Authorized for Asset from Equipment
    @param          : Map<Id, Asset__c> oldAssetMap, Map<Id, Asset__c> newAssetMap
    @return         : void
    ********************************************************
    */
    public static void updateAmountAuthorized(Map<Id, Asset__c> oldAssetMap, Map<Id, Asset__c> newAssetMap){
        Set<Id> equipmentIds = new Set<Id>();
        for(Asset__c asset: newAssetMap.values()) {
            if(asset.Equipment__c != oldAssetMap.get(asset.id).Equipment__c) {
                equipmentIds.add(asset.Equipment__c);
            }
        }
        if(equipmentIds.size() > 0) {
            Map<Id, Equipment__c> equipmentMap = new Map<Id, Equipment__c>();
            for(Equipment__c equipment: [SELECT Amount_Authorized__c FROM Equipment__c WHERE Id IN: equipmentIds]) {
                equipmentMap.put(equipment.id, equipment);
            }
            
            for(Asset__c asset: newAssetMap.values()) {
                if(equipmentMap.containsKey(asset.Equipment__c)) {
                    asset.Amount_Authorized__c = equipmentMap.get(asset.Equipment__c).Amount_Authorized__c;
                }
            }   
        }
    }
    
    /*
    *********************************************************
    @Method Name    : deleteSubEquipment
    @description    : Delete Sub Asset If Asset is Unaviable
    @param          : List<Asset__c> listOfAsset
    @return         : void
    ********************************************************
    */
    public static void deleteSubEquipment(List<Asset__c> listOfAsset){
        List<Asset__c> listOfAssetToDelete = new List<Asset__c>();
        for(Asset__c assetRecord : [SELECT Id FROM Asset__c WHERE Parent_Asset__c IN : listOfAsset WITH SECURITY_ENFORCED]){
            listOfAssetToDelete.add(assetRecord);
        }
        if(!listOfAssetToDelete.isEmpty()){
            if(Asset__c.sObjectType.getDescribe().isDeletable()){
                DELETE listOfAssetToDelete;
            }
            else{
                throw new NC_Custom_Exception('You don\'t have access to delete');}
            }
    }
    
    /*
    *********************************************************
    @Method Name    : UpdateAssetStatus
    @description    : Update Asset status to Returned if return equipment is checked
    @param          : Map<Id, Asset__c> newAssetMap
    @return         : void
    ********************************************************
    */
    public static void UpdateAssetStatus(Map<Id, Asset__c> newAssetMap){
        for(Id assetId : newAssetMap.keyset()){
            if(newAssetMap.get(assetId).Returned_Equipment__c){
                newAssetMap.get(assetId).Status__c = NC_Constant.ASSET_STATUS_RETURNED;
            }   
        }
    }
    
    /*
    *********************************************************
    @Method Name    : UpdateInvoiceConsumerDate
    @description    : Update invoice consumer signed date from Asset Equipment received date
    @param          : List<Asset__c> listOfAsset
    @return         : void
    ********************************************************
    */
    public static void UpdateInvoiceConsumerDate(List<Asset__c> listOfAsset){
        Map<Id, Date> mapOfInvoiceIdWithDate = new Map<Id, Date>();
        List<Invoice__c> listOfInvoiceTobeUpdated = new List<Invoice__c>();
        for(Invoice_Line_Item__c invoicelineItem : [SELECT Id, Invoice__c, Asset__r.Equipment_Received_Date__c FROM Invoice_Line_Item__c WHERE Asset__c IN : listOfAsset WITH SECURITY_ENFORCED]){
            mapOfInvoiceIdWithDate.put(invoicelineItem.Invoice__c, invoicelineItem.Asset__r.Equipment_Received_Date__c);
        }
        for(Invoice__c invoice : [SELECT Id, Consumer_Signed_Date__c FROM Invoice__c WHERE Id IN: mapOfInvoiceIdWithDate.keyset() WITH SECURITY_ENFORCED]){
            invoice.Consumer_Signed_Date__c = mapOfInvoiceIdWithDate.get(invoice.Id);
            listOfInvoiceTobeUpdated.add(invoice);
        }
        SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Invoice__c', listOfInvoiceTobeUpdated, 'update', true ,'NC_AssetTriggerHandler','UpdateInvoiceConsumerDate');
        update objectDecision.getRecords();
        //UPDATE listOfInvoiceTobeUpdated;
    }
    
    /*
    *********************************************************
    @Method Name    : updateAuthorizationConsumerDate
    @description    : Update Authorization consumer signed date from Asset Equipment received date
    @param          : Map<Id, Date> authorizationToDateMap
    @return         : void
    ********************************************************
    */
    public static void updateAuthorizationConsumerDate( Map<Id, Date> authorizationToDateMap ){
        List<Authorization__c> authorizationUpdateList = new List<Authorization__c>();
        for(Authorization__c authrozationRecord: [SELECT Id,Consumer_Signed_Date__c FROM Authorization__c Where Id IN: authorizationToDateMap.keySet() WITH SECURITY_ENFORCED]){
            if(authrozationRecord.Consumer_Signed_Date__c == NULL){
                authrozationRecord.Consumer_Signed_Date__c = authorizationToDateMap.get(authrozationRecord.Id);
                authorizationUpdateList.add(authrozationRecord);
            }
        }
        if(!authorizationUpdateList.isEmpty()){
            for(Authorization__c auth: authorizationUpdateList) {
                auth.Update_If_Vendor_Inactive__c = true;
            }
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Authorization__c', authorizationUpdateList, 'update', true,'NC_AssetTriggerHandler','updateAuthorizationConsumerDate');
            update objectDecision.getRecords();
            //Update authorizationUpdateList;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateRecord
    @description    : Validate Asset record
    @param          : Map<Id, Asset__c> newAssetMap
    @return         : void
    ********************************************************
    */
    public static void validateRecord(Map<Id, Asset__c> newAssetMap){
        for(Asset__c assetRecord : [SELECT Id, Returned_Equipment__c, Equipment__r.Equipment_Type__c, Equipment_Received_Date__c FROM Asset__c WHERE Id IN : newAssetMap.keyset() AND Equipment_Received_Date__c != null]){
            if(newAssetMap.get(assetRecord.Id).Returned_Equipment__c && newAssetMap.get(assetRecord.Id).Equipment_Received_Date__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_RETURN_WEATHER) < System.today() && assetRecord.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_WEATHER_RADIO){
                newAssetMap.get(assetRecord.Id).addError(NC_Constant.AUTHORIZATION_TRIGGER_ERROR_RETURN_DAYS_WEATHER);
            }
            if(newAssetMap.get(assetRecord.Id).Returned_Equipment__c && newAssetMap.get(assetRecord.Id).Equipment_Received_Date__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_RETURN_OTHERS) < System.today() && assetRecord.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_HEARING_AID){
                newAssetMap.get(assetRecord.Id).addError(NC_Constant.AUTHORIZATION_TRIGGER_ERROR_RETURN_DAYS_OTHERS);
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateInvoiceLineItem
    @description    : Update Invoice Line Item Returned Status
    @param          : List<Asset__c> assetList
    @return         : void
    ********************************************************
    */
    public static void updateInvoiceLineItem(List<Asset__c> assetList){
        List<Invoice_Line_Item__c> listOfInvoiceLineItemInsert = new List<Invoice_Line_Item__c>();
        List<Hearing_Aid_Sub_Item__mdt> listOfhearingAidSubItem = new List<Hearing_Aid_Sub_Item__mdt>();
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
        List<Invoice__c> invoiceHearingAidList = new List<Invoice__c>();
        Set<Id> AuthorizationSetId = new Set<Id>();
        Set<Id> InvoiceSetId = new Set<Id>();
        
        for(Asset__c assetRecord : [SELECT Id, Authorization__c FROM Asset__c WHERE Id IN: assetList]){
            AuthorizationSetId.add(assetRecord.Authorization__c);
        }
        
        for(Invoice__c invoiceRecord : [SELECT Id, RecordTypeId, Authorization__c FROM Invoice__c WHERE Authorization__c IN: AuthorizationSetId WITH SECURITY_ENFORCED]){
            InvoiceSetId.add(invoiceRecord.Id);
            if(invoiceRecord.RecordTypeId == NC_Utility.RecordTypeUtilityMethod('Invoice__c',NC_Constant.INVOICE_RECORDTYPE_HEARING_AID)){
                invoiceHearingAidList.add(invoiceRecord);
            }
            
        }
        
        for(Invoice_Line_Item__c invoiceLineItem : [SELECT Id, Returned__c FROM Invoice_Line_Item__c WHERE Asset__c IN : assetList AND Invoice__c IN : InvoiceSetId WITH SECURITY_ENFORCED]){
            invoiceLineItem.Returned__c= true;
            invoiceLineItemList.add(invoiceLineItem);
        }
        
        if(!invoiceLineItemList.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', invoiceLineItemList, 'update', true,'NC_AssetTriggerHandler','updateInvoiceLineItem');
            update objectDecision.getRecords();
            //UPDATE invoiceLineItemList;
        }
        
        for(Hearing_Aid_Sub_Item__mdt hearingAidSubItem : [SELECT Id, MasterLabel, Amount_Authorized__c, Validation_Amount__c FROM Hearing_Aid_Sub_Item__mdt WHERE Is_Return_Item__c = true AND Validation_Amount__c = false WITH SECURITY_ENFORCED]){
            listOfhearingAidSubItem.add(hearingAidSubItem);
        }
        
        for(Invoice__c invoice : invoiceHearingAidList){
            for(Hearing_Aid_Sub_Item__mdt hearingAidSubItem : listOfhearingAidSubItem){
                Invoice_Line_Item__c invoiceLineItemRecord = new Invoice_Line_Item__c();
                invoiceLineItemRecord.Amount_Authorized__c = hearingAidSubItem.Amount_Authorized__c;
                invoiceLineItemRecord.Invoice__c = invoice.Id;
                invoiceLineItemRecord.Equipment_Name__c = hearingAidSubItem.MasterLabel;
                listOfInvoiceLineItemInsert.add(invoiceLineItemRecord);
            }
        }
        
        if(!listOfInvoiceLineItemInsert.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', listOfInvoiceLineItemInsert, 'insert', true,'NC_AssetTriggerHandler','updateInvoiceLineItem');
            insert objectDecision.getRecords();
            //INSERT listOfInvoiceLineItemInsert;
        }
        
        
    }
    
    /*
    *********************************************************
    @Method Name    : updateAuthorizationOnCanceled
    @description    : Update Authorization Status On Asset Canceld if Only Asset Exist
    @param          : List<Asset__c> assetList
    @return         : void
    ********************************************************
    */
    public static void updateAuthorizationOnCanceled(set<Id> setOfAuthrizationId){
        
        List<Authorization__c> updateAuthorizationList = new List<Authorization__c>();
        Map<Id, Integer> mapOfAuthorizationAssetCanceledCount = new Map<Id, Integer>();
        Map<Id, Integer> mapOfAuthorizationAssetReturnedCount = new Map<Id, Integer>();
        Map<Id, Integer> mapOfAuthorizationAssetCount = new Map<Id, Integer>();
        Set<Id> authorizationIdSet = new Set<Id>();
        
        for(Asset__c assetRecord : [SELECT Id, Authorization__c, Status__c FROM Asset__c WHERE Authorization__c IN: setOfAuthrizationId]){
            if(assetRecord.Status__c == NC_Constant.ASSET_STATUS_CANCELED){
                if(!mapOfAuthorizationAssetCanceledCount.containsKey(assetRecord.Authorization__c)){
                    mapOfAuthorizationAssetCanceledCount.put(assetRecord.Authorization__c, 0);
                }
                mapOfAuthorizationAssetCanceledCount.put(assetRecord.Authorization__c, mapOfAuthorizationAssetCanceledCount.get(assetRecord.Authorization__c) + 1);
            }else if(assetRecord.Status__c == NC_Constant.ASSET_STATUS_RETURNED){
                if(!mapOfAuthorizationAssetReturnedCount.containsKey(assetRecord.Authorization__c)){
                    mapOfAuthorizationAssetReturnedCount.put(assetRecord.Authorization__c, 0);
                }
                mapOfAuthorizationAssetReturnedCount.put(assetRecord.Authorization__c, mapOfAuthorizationAssetReturnedCount.get(assetRecord.Authorization__c) + 1);
            }
            if(!mapOfAuthorizationAssetCount.containsKey(assetRecord.Authorization__c)){
                mapOfAuthorizationAssetCount.put(assetRecord.Authorization__c, 0);
            }
            mapOfAuthorizationAssetCount.put(assetRecord.Authorization__c, mapOfAuthorizationAssetCount.get(assetRecord.Authorization__c) + 1);
            
        }
        
        for(Id authId : mapOfAuthorizationAssetCanceledCount.keyset()){
            if(mapOfAuthorizationAssetCanceledCount.get(authId) == mapOfAuthorizationAssetCount.get(authId)){
                authorizationIdSet.add(authId);
            }
        }
        
        for(Id authId : mapOfAuthorizationAssetReturnedCount.keyset()){
            if(mapOfAuthorizationAssetReturnedCount.get(authId) == mapOfAuthorizationAssetCount.get(authId)){
                authorizationIdSet.add(authId);
            }
        }
        
        for(Authorization__c authRecord : [SELECT Id, Status__c FROM Authorization__c WHERE Id IN: authorizationIdSet WITH SECURITY_ENFORCED]){
            authRecord.Status__c = mapOfAuthorizationAssetReturnedCount.containsKey(authRecord.Id) ? NC_Constant.AUTHORIZATION_STATUS_RETURNED : NC_Constant.AUTHORIZATION_STATUS_CANCELED;
            updateAuthorizationList.add(authRecord);
        }
        
        if(!updateAuthorizationList.isEmpty()){
            for(Authorization__c auth: updateAuthorizationList) {
                auth.Update_If_Vendor_Inactive__c = true;
            }
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Authorization__c', updateAuthorizationList, 'update', true,'NC_AssetTriggerHandler','updateAuthorizationOnCanceled');
            update objectDecision.getRecords();
            //UPDATE updateAuthorizationList;
        }
        
        
    }
    
    /*
    *********************************************************
    @Method Name    : afterDelete
    @description    : Execute after delete trigger event
    @param          : List<Asset__c> oldList
    @return         : void
    ********************************************************
    */
    public static void afterDelete(List<Asset__c> oldList){
        Set<Id> requestIds = new Set<Id>();
        Set<Id> equipmentIds = new Set<Id>();
        for(Asset__c asset: oldList) {
            if(asset.Equipment__c != null && asset.Request__c != null) {
                requestIds.add(asset.Request__c);
                equipmentIds.add(asset.Equipment__c);
            }
        }
        if(equipmentIds.size() > 0) {
            List<Request_Equipment__c> reqEqpList = [SELECT id FROM Request_Equipment__c WHERE Request__c IN: requestIds AND Equipment__c IN: equipmentIds WITH SECURITY_ENFORCED];
            if(!reqEqpList.isEmpty()) {
                //delete reqEqpList;
                if(Request_Equipment__c.sObjectType.getDescribe().isDeletable()){
                    delete reqEqpList;
                }
            }
        }
    }
    
}