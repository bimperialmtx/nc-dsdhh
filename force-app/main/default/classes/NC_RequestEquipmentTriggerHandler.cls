/*
**   Class Name: NC_RequestEquipmentTriggerHandler
**   Description: Trigger on Request Equipment
**
**     Date            New/Modified           User                 Identifier                Description
**   05-11-2020             New          Shubham Dadhich(mtx)
*/

public without sharing class NC_RequestEquipmentTriggerHandler {
    
    public static Id ndbedpEqpRecordType = NC_Utility.RecordTypeUtilityMethod('Request_Equipment__c','NDBEDP');
    public static Id ndbedpAssetRecordType = NC_Utility.RecordTypeUtilityMethod('Asset__c','NDBEDP_Asset');
    public static Id demoAssetRecordType = NC_Utility.RecordTypeUtilityMethod('Asset__c','Demo_Asset');
    public static Id authorizationEquipmentRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c',NC_Constant.AUTHORIZATION_EQUIPMENT_RECORDTYPE);
    public static Set<Id> assetTypeIds = new Set<Id>{ndbedpAssetRecordType, demoAssetRecordType};
    
    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before Insert' trigger event
    @param          : List<Request_Equipment__c> newRequestEquipmentList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Request_Equipment__c> newRequestEquipmentList){
        List<Request_Equipment__c> listOfRequestEquipment = new List<Request_Equipment__c>(); 
        for(Request_Equipment__c requestEquipmentRecord : newRequestEquipmentList){
            if(requestEquipmentRecord.Sub_Equipment__c == null){
                listOfRequestEquipment.add(requestEquipmentRecord);
            }
        }

        if(!listOfRequestEquipment.isEmpty()){
            populateSubEquipment(listOfRequestEquipment);
        }
        validateDuplicateRequestEquipment(newRequestEquipmentList);
        validateEquipmentType(newRequestEquipmentList);
        equipmentRequestValidation(newRequestEquipmentList);
        equipmentJustificationValidation(newRequestEquipmentList);
    }

    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Request_Equipment__c> newRequestEquipmentList,Map<Id,Request_Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Request_Equipment__c> newRequestEquipmentList,Map<Id,Request_Equipment__c> oldMap){
        validateLineItems(newRequestEquipmentList,oldMap);

    }

    /*
    *********************************************************
    @Method Name    : validateLineItems
    @description    : Validate line item update/cancellation
    @param          : List<Request_Equipment__c> newRequestEquipmentList,Map<Id,Request_Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateLineItems(List<Request_Equipment__c> newRequestEquipmentList,Map<Id,Request_Equipment__c> oldMap){
        Id rtIDNDBEDP = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByName().get('NDBEDP').getRecordTypeId();
        List<String> actionCodes= new List<String>{'AGT' , 'POB', 'APPROV', 'APPRV','APPAG' , 'WLFND' , 'WLCNS','WLAGT' , 'WLEQP'};
        List<String> actionCodes2= new List<String>{'SHC','SHP', 'PO', 'POC', 'ASG','WIP'};
        for(Request_Equipment__c reqEquip : newRequestEquipmentList) {
            if (UserInfo.getUserId() != Label.Integration_User) {
                if (oldMap.get(reqEquip.Id).LineStatus__c!=null && reqEquip.LineStatus__c!=null && reqEquip.MatRequestLineObj__c!=null
                        && reqEquip.LineStatus__c=='Cancelled' && reqEquip.RecordTypeId == rtIDNDBEDP && actionCodes2.contains(reqEquip.LastActionCode__c)) {
                    reqEquip.addError('Line Items cannot be cancelled.');
                }
                if ((reqEquip.MatRequestLineObj__c!=null && oldMap.get(reqEquip.Id).Quantity__c != reqEquip.Quantity__c && actionCodes2.contains(reqEquip.LastActionCode__c)) || reqEquip.MatReqStatus__c=='Closed') {
                    //reqEquip.addError('Line Items update not allowed.');
                }
                if ((reqEquip.MatRequestLineObj__c!=null && oldMap.get(reqEquip.Id).Quantity__c != reqEquip.Quantity__c && actionCodes2.contains(reqEquip.LastActionCode__c)) || reqEquip.LineStatus__c=='Closed') {
                    //reqEquip.addError('Line Items update not allowed.');
                }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'after insert' trigger event
    @param          : List<Request_Equipment__c> newList
    @return         : void
    ********************************************************
    */
    public static void afterInsert(List<Request_Equipment__c> newList){
        Map<String, Set<Id>> requestEqpMap = new Map<String, Set<Id>>();

        for(Request_Equipment__c requestEqp : newList) {
            //new line item
            if (requestEqp.MatRequestObj__c!=null && requestEqp.MatRequestLineObj__c==NULL) {
                if(requestEqpMap.containsKey(requestEqp.Request__c)) {
                    requestEqpMap.get(requestEqp.Request__c).add(requestEqp.id);
                } else {
                    requestEqpMap.put(requestEqp.Request__c + '', new Set<Id>{requestEqp.id});
                }
            }
        }

        //Sync new line items with NDBEDP if Order was synced earlier
        for(String requestId: requestEqpMap.keySet()) {
            NC_NDBEDPEquipmentCatalog.sendEquipmentRequest(requestEqpMap.get(requestId), requestId);
        }

        //Sync Asset and NDBEDP Equipment
        addNDBEDPAssetUsingEquipment(newList);
    }

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after update' trigger event
    @param          : List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap){
        updateNDBEDPAsset(newList, oldMap);
        updateNDBEDPInvoices(newList, oldMap);
        Set<Id> requestEquipmentIds = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        for(Request_Equipment__c equipment : newList) {
            if (equipment.MatRequestLineObj__c!=null && oldMap.get(equipment.Id).LineStatus__c != equipment.LineStatus__c && equipment.LineStatus__c=='Cancelled') {
                requestEquipmentIds.add(equipment.Id);
                caseIdSet.add(equipment.Request__c);
            }
            if (equipment.MatRequestLineObj__c!=null && oldMap.get(equipment.Id).Quantity__c != equipment.Quantity__c) {
                requestEquipmentIds.add(equipment.Id);
                caseIdSet.add(equipment.Request__c);
            }
        }
        //sync/update lineItems to NDBEDP
        if (requestEquipmentIds.size()>0) {
            System.enqueueJob(new NC_NDBEDPUpdateLineItems(requestEquipmentIds));
        }
                getRequestEquipmentLastActionCode(newList, oldMap);

    }
    
    /*
    *********************************************************
    @Method Name    : getRequestEquipmentLastActionCode
    @description    : update equipment shipped date on case
    @param          : List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
      public static void getRequestEquipmentLastActionCode(List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap){
        Set<Id> requestIdSet=new Set<Id>();
        List<Case> caseList=new List<Case>();
        for(Request_Equipment__c reqEqp: newList) {
            if(reqEqp.LastActionCode__c != oldMap.get(reqEqp.id).LastActionCode__c && reqEqp.LastActionCode__c == 'SHC'){
                requestIdSet.add(reqEqp.Request__c);
            }
        }
        if(requestIdSet.size()>0){
        for(Id requestId: requestIdSet){
               Case cas=new Case();
               cas.Id=requestId;
               cas.Final_Equipment_Shipped_Date__c=System.today();
               caseList.add(cas);
        }
        if(caseList.size()>0){
            //update caseList;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', caseList, 'update', true,'NC_RequestEquipmentTriggerHandler','getRequestEquipmentLastActionCode');
            update decision.getRecords();
        }
       }
        
    }
    
    /*
    *********************************************************
    @Method Name    : updateNDBEDPAsset
    @description    : update ndbedp asset status to shipped
    @param          : List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateNDBEDPAsset(List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap) {
        List<Asset__c> assetList = new List<Asset__c>();
        Map<Id, Request_Equipment__c> reqEqpMap = new Map<Id, Request_Equipment__c>();
        Set<Id> requestIds = new Set<Id>();
        for(Request_Equipment__c reqEqp: newList) {
           
            if(reqEqp.recordTypeId == ndbedpEqpRecordType
                && reqEqp.LastActionCode__c != oldMap.get(reqEqp.id).LastActionCode__c
                && reqEqp.LastActionCode__c == 'SHC'
              	&& reqEqp.LineStatus__c == 'Closed') {
                    reqEqpMap.put(reqEqp.id, reqEqp);
                    requestIds.add(reqEqp.Request__c);
                }
        }
        for(Asset__c asset: [SELECT Request__c, Equipment__c FROM Asset__c WHERE Request__c IN: requestIds AND recordTypeId IN: assetTypeIds WITH SECURITY_ENFORCED]) {
            for(Id eqpId: reqEqpMap.keySet()) {
                if(reqEqpMap.get(eqpId).Request__c == asset.Request__c && reqEqpMap.get(eqpId).Equipment__c == asset.Equipment__c) {
                    asset.Status__c = 'Shipped';
                    asset.Is_Valid__c = true;
                    assetList.add(asset);
                }
            }
        }
        if(assetList.size() > 0) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Asset__c', assetList, 'update', true, 'NC_RequestEquipmentTriggerHandler', 'updateNDBEDPAsset');
            update objectDecision.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : validateDuplicateRequestEquipment
    @description    : Validation To Stop Duplicate Records Creation
    @param          : List<Request_Equipment__c> newRequestEquipmentList
    @return         : void
    ********************************************************
    */
    public static void validateDuplicateRequestEquipment(List<Request_Equipment__c> newRequestEquipmentList){
        Set<String> requestIdSet = new Set<String>();
        Set<String> uniqueIdSet = new Set<String>();
        for(Request_Equipment__c requestEquipment : newRequestEquipmentList){
            if(requestEquipment.Equipment__c != null) {
             	String uniqueId = String.valueOf(requestEquipment.Equipment__c).substring(0, 15) + '' +  String.valueOf(requestEquipment.Request__c).substring(0, 15);
            	requestIdSet.add(uniqueId);   
            }
        }
        
        if(requestIdSet.size() > 0) {
         	for(Request_Equipment__c requestEquipment : [SELECT Id, Name,Equipment__c,Unique_Id__c,Request__c FROM Request_Equipment__c WHERE Unique_Id__c IN : requestIdSet WITH SECURITY_ENFORCED]){
                uniqueIdSet.add(requestEquipment.Unique_Id__c);
            }
        }
        
        for(Request_Equipment__c requestEquipment : newRequestEquipmentList){
            if(requestEquipment.Equipment__c != null) {
                String uniqueId = String.valueOf(requestEquipment.Equipment__c).substring(0, 15) + '' +  String.valueOf(requestEquipment.Request__c).substring(0, 15);
                if(uniqueIdSet.contains(uniqueId)){
                    requestEquipment.addError('This Equipment is already added.');
                }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : validateEquipmentType
    @description    : Validate Equipment Type on Request and Equipment to be same
    @param          : List<Request_Equipment__c> newRequestEquipmentList
    @return         : void
    ********************************************************
    */
    public static void validateEquipmentType(List<Request_Equipment__c> newRequestEquipmentList){
        Set<String> requestIdSet = new Set<String>();
        Set<String> equipmentIdSet = new Set<String>();
        Map<String,List<String>> mapOfRequestandEquipmentType = new Map<String,List<String>>();
        Map<String,String> mapOfEquipmentandEquipmentType = new Map<String,String>(); 
        
        for(Request_Equipment__c requestEquipment : newRequestEquipmentList){
            requestIdSet.add(requestEquipment.Request__c);
            equipmentIdSet.add(requestEquipment.Equipment__c);
        }
        
        for(Case request : [SELECT Id, Equipment_Types__c FROM Case WHERE Id IN: requestIdSet WITH SECURITY_ENFORCED]){
            List<String> equipmentTypeList = new List<String>();
            if(request.Equipment_Types__c != NULL){
                equipmentTypeList = request.Equipment_Types__c.Split(';');
                mapOfRequestandEquipmentType.put(request.Id, equipmentTypeList);
            }
        }

        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Equipment__c','NDBEDP');
        
        for(Equipment__c equipment : [SELECT Id, recordTypeId, Equipment_Type__c FROM Equipment__c WHERE Id IN: equipmentIdSet AND recordTypeId != :ndbedpRecordTypeId WITH SECURITY_ENFORCED]){
                mapOfEquipmentandEquipmentType.put(equipment.Id, equipment.Equipment_Type__c);
        }

        for(Request_Equipment__c requestEquipment : newRequestEquipmentList){
            if(mapOfRequestandEquipmentType.containsKey(requestEquipment.Request__c)){
            if(mapOfEquipmentandEquipmentType.size() > 0 && !mapOfRequestandEquipmentType.get(requestEquipment.Request__c).contains(mapOfEquipmentandEquipmentType.get(requestEquipment.Equipment__c))){
                requestEquipment.addError('Equipment is not of Correct Type. You can only select following type of Equipment: '+mapOfRequestandEquipmentType.get(requestEquipment.Request__c));
            }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : populateSubEquipment
    @description    : To Add Sub Equipment On Request Equipment
    @param          : List<Request_Equipment__c> newRequestEquipmentList
    @return         : void
    ********************************************************
    */
    public static void populateSubEquipment(List<Request_Equipment__c> newRequestEquipmentList){
        Set<Id> setOfEquipmentId = new Set<Id>();
        Map<Id, Id> mapOfEquipmentIdWithSubEwuipmentId = new Map<Id, Id>();
        
        for(Request_Equipment__c requestEquipmentRecord : newRequestEquipmentList ){
            setOfEquipmentId.add(requestEquipmentRecord.Equipment__c);
        }

        for(Equipment__c equipmentRecord : [SELECT Id, Parent_Equipment__c, Always_Add_With_Parent__c FROM Equipment__c WHERE Parent_Equipment__c IN: setOfEquipmentId AND Always_Add_With_Parent__c = true WITH SECURITY_ENFORCED]){
            mapOfEquipmentIdWithSubEwuipmentId.put(equipmentRecord.Parent_Equipment__c, equipmentRecord.Id);
        }

        for(Request_Equipment__c requestEquipmentRecord : newRequestEquipmentList ){
            if(mapOfEquipmentIdWithSubEwuipmentId.containsKey(requestEquipmentRecord.Equipment__c)){
                requestEquipmentRecord.Sub_Equipment__c = mapOfEquipmentIdWithSubEwuipmentId.get(requestEquipmentRecord.Equipment__c);
            }
        }

    }
    
    /*
    *********************************************************
    @Method Name    : equipmentRequestValidation
    @description    : check where the justification on case field is required, throw error for the same
    @param          : List<Request_Equipment__c> newRequestEquipmentList
    @return         : void
    ********************************************************
    */
    public static void equipmentRequestValidation(List<Request_Equipment__c> newRequestEquipmentList){
        Set<Id> requestIdSet = new Set<Id>();
        Map<Id, Id> mapOfContactIdWithEquipmentId = new Map<Id, Id>();
        Map<Id, Id> mapORequestIdQithContactId = new Map<Id, Id>();
    

        for(Request_Equipment__c requestEquipment : newRequestEquipmentList){
            requestIdSet.add(requestEquipment.Request__c);
        }

        for(Case requestCase : [SELECT Id, ContactId FROM Case WHERE Id IN: requestIdSet WITH SECURITY_ENFORCED]){
            mapORequestIdQithContactId.put(requestCase.Id, requestCase.ContactId);
        }

        for(Asset__c assetRecord : [SELECT Id, Contact__c, Equipment__c FROM Asset__c WHERE Contact__c IN : mapORequestIdQithContactId.values() AND Usage_End_Date__c >: System.today() WITH SECURITY_ENFORCED]){
            mapOfContactIdWithEquipmentId.put(assetRecord.Contact__c, assetRecord.Equipment__c);
        }

        for(Request_Equipment__c requestEquipment : newRequestEquipmentList){
            if(mapOfContactIdWithEquipmentId.get(mapORequestIdQithContactId.get(requestEquipment.Request__c)) == requestEquipment.Equipment__c){
                if(requestEquipment.Equipment_Justification__c == null){
                    requestEquipment.addError('Before requesting new Equipment please add Equipment Justification on Request');
                }
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : equipmentJustificationValidation
    @description    : check where the equipment justification field is required, throw error for the same
    @param          : List<Request_Equipment__c> newRequestEquipmentList
    @return         : void
    ********************************************************
    */
    public static void equipmentJustificationValidation(List<Request_Equipment__c> newRequestEquipmentList){
        Map<String,String> mapofTypeByName = new Map<String,String>();
        Map<String,String> mapofTypeByClientArchive = new Map<String,String>();
        for(Request_Equipment__c requestEquipment : newRequestEquipmentList){
            if(requestEquipment.Equipment_Type__c != null && requestEquipment.Equipment_Name__c !=null){
                mapofTypeByName.put(requestEquipment.Equipment_Type__c,requestEquipment.Equipment_Name__c);
            }
        } 
        if(mapofTypeByName.size() > 0){
            for(Client_Archive__c clientArchive : [SELECT Id, Equipment_Type__c, Equipment_Name__c, Equipment_Code__c FROM Client_Archive__c 
                                                                            WHERE Equipment_Name__c IN : mapofTypeByName.values() 
                                                                            AND Equipment_Type__c IN : mapofTypeByName.keyset()
                                                                            AND Service_Date_Completed__c = 'No' WITH SECURITY_ENFORCED
                                                                            ]){
                mapofTypeByClientArchive.put(clientArchive.Equipment_Type__c,clientArchive.Equipment_Name__c);                                                                
            }
        }
        for(Request_Equipment__c requestEquipment : newRequestEquipmentList){
            if(mapofTypeByClientArchive.containsKey(requestEquipment.Equipment_Type__c) 
                && mapofTypeByClientArchive.get(requestEquipment.Equipment_Type__c) == requestEquipment.Equipment_Name__c){
                if(requestEquipment.Equipment_Justification__c == null){
                    requestEquipment.addError('Before requesting new Equipment please add Equipment Justification on Request');
                }
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : afterDelete
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Request_Equipment__c> oldList
    @return         : void
    ********************************************************
    */
    public static void afterDelete(List<Request_Equipment__c> oldList){
        Set<Id> requestIds = new Set<Id>();
        Set<Id> equipmentIds = new Set<Id>();
        for(Request_Equipment__c reqEqp: oldList) {
            requestIds.add(reqEqp.Request__c);
            equipmentIds.add(reqEqp.Equipment__c);
        }
        List<Asset__c> assetList = [SELECT id FROM Asset__c WHERE Request__c IN: requestIds AND Equipment__c IN: equipmentIds WITH SECURITY_ENFORCED];
        if(!assetList.isEmpty()) {
            if(Schema.sObjectType.Asset__c.isDeletable()) {
             	delete assetList;   
            }
        }
    }
    
    /*
    public static void addNDBEDPAssetUsingEquipment(List<Request_Equipment__c> newList) {
        List<Asset__c> assetList = new List<Asset__c>();
        Map<Id, Request_Equipment__c> reqEqpMap = new Map<Id, Request_Equipment__c>();
        Set<Id> requestIds = new Set<Id>();
        for(Request_Equipment__c reqEqp: newList) {
            if(reqEqp.recordTypeId == ndbedpEqpRecordType
                && reqEqp.Request_Status__c == 'Approved') {
                    reqEqpMap.put(reqEqp.id, reqEqp);
                    requestIds.add(reqEqp.Request__c);
                }
        }
        Boolean isAuthFound = false;
        Authorization__c authRecordObj = new Authorization__c();
        Map<Id, Id> requestAuthMap = new Map<Id, Id>();
        if(requestIds.size() > 0) {
            for(Authorization__c authRecord: [SELECT id, Request__c, Consumer__c,RecordTypeId, Regional_Center__c, Status__c, Vendor__c, (SELECT id FROM Invoices__r) FROM Authorization__c WHERE Request__c IN:requestIds AND recordTypeId =: authorizationEquipmentRecordType]) {
                if(authRecord.Invoices__r.isEmpty()) {
                    isAuthFound = true;
                    requestAuthMap.put(authRecord.Request__c, authRecord.id);
                } else {
                    authRecordObj = authRecord.clone();
                }
            }
        }
        if(isAuthFound == false) {
            insert authRecordObj;
            requestAuthMap.put(authRecordObj.Request__c, authRecordObj.id);
        }
        for(Id reqEqpId: reqEqpMap.keySet()) {
            if(requestAuthMap.containsKey(reqEqpMap.get(reqEqpId).Request__c)) {
                String assetTypeId = reqEqpMap.get(reqEqpId).Equipment_Type__c == 'Demo' ? demoAssetRecordType : ndbedpAssetRecordType;
                assetList.add(createAssetUtils(reqEqpMap.get(reqEqpId).Equipment__c, reqEqpMap.get(reqEqpId).Request_Contact__c, reqEqpMap.get(reqEqpId).Request__c, assetTypeId, reqEqpMap.get(reqEqpId).Equipment_Amount_Authorized__c, reqEqpMap.get(reqEqpId).Quantity__c, requestAuthMap.get(reqEqpMap.get(reqEqpId).Request__c)));
            }
        }
        
        if(assetList.size() > 0) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Asset__c', assetList, 'insert', true, 'NC_RequestEquipmentTriggerHandler', 'addNDBEDPAssetUsingEquipment');
            insert objectDecision.getRecords();
        }
    }*/
    
    /*
    *********************************************************
    @Method Name    : addNDBEDPAssetUsingEquipment
    @description    : Add NDBEDP asset using equipment from case
    @param          : List<Request_Equipment__c> newList
    @return         : void
    ********************************************************
    */
    public static void addNDBEDPAssetUsingEquipment(List<Request_Equipment__c> newList) {
        List<Asset__c> assetList = new List<Asset__c>();
        Map<Id, Request_Equipment__c> reqEqpMap = new Map<Id, Request_Equipment__c>();
        Set<Id> requestIds = new Set<Id>();
        for(Request_Equipment__c reqEqp: newList) {
            if(reqEqp.recordTypeId == ndbedpEqpRecordType
                && reqEqp.Request_Status__c == 'Approved') {
                    reqEqpMap.put(reqEqp.id, reqEqp);
                    requestIds.add(reqEqp.Request__c);
                }
        }
        Map<Id, Id> requestAuthMap = new Map<Id, Id>();
        if(requestIds.size() > 0) {
            for(Authorization__c authRecord: [SELECT id, Request__c FROM Authorization__c WHERE Request__c IN:requestIds AND recordTypeId =: authorizationEquipmentRecordType WITH SECURITY_ENFORCED]) {
                requestAuthMap.put(authRecord.Request__c, authRecord.id);
            }
        }
        for(Id reqEqpId: reqEqpMap.keySet()) {
            if(requestAuthMap.containsKey(reqEqpMap.get(reqEqpId).Request__c)) {
                String assetTypeId = reqEqpMap.get(reqEqpId).Equipment_Type__c == 'Demo' ? demoAssetRecordType : ndbedpAssetRecordType;
                assetList.add(createAssetUtils(reqEqpMap.get(reqEqpId).Equipment__c, reqEqpMap.get(reqEqpId).Request_Contact__c, reqEqpMap.get(reqEqpId).Request__c, assetTypeId, reqEqpMap.get(reqEqpId).Equipment_Amount_Authorized__c, reqEqpMap.get(reqEqpId).Quantity__c, requestAuthMap.get(reqEqpMap.get(reqEqpId).Request__c)));
            }
        }
        
        if(assetList.size() > 0) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Asset__c', assetList, 'insert', true, 'NC_RequestEquipmentTriggerHandler', 'addNDBEDPAssetUsingEquipment');
            insert objectDecision.getRecords();
        }
    }
    
    /*
    *********************************************************
    @Method Name    : createAssetUtils
    @description    : Create Asset record util
    @param          : Id EquipmentId, Id ContactId, Id RequestId, Id RecordTypeId, Decimal AmountAuthorized, String quantity, Id authId
    @return         : Asset__c
    ********************************************************
    */
    public static Asset__c createAssetUtils(Id EquipmentId, Id ContactId, Id RequestId, Id RecordTypeId, Decimal AmountAuthorized, String quantity, Id authId){
        Asset__c assetRecord = new Asset__c();
        assetRecord.Equipment__c = EquipmentId;
        assetRecord.Contact__c = ContactId;
        assetRecord.Request__c = RequestId;
        assetRecord.RecordTypeId = RecordTypeId;
        assetRecord.Amount_Authorized__c = AmountAuthorized;
        assetRecord.Quantity__c = quantity;
        assetRecord.Authorization__c = authId;
        return assetRecord;
    }
    
  /*  public static void updateNDBEDPAssetAmount(List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap) {
        List<Asset__c> assetList = new List<Asset__c>();
        Map<Id, Request_Equipment__c> reqEqpMap = new Map<Id, Request_Equipment__c>();
        Set<Id> requestIds = new Set<Id>();
        for(Request_Equipment__c reqEqp: newList) {
            if(reqEqp.recordTypeId == ndbedpEqpRecordType
                && reqEqp.Total__c != oldMap.get(reqEqp.id).Total__c
                && reqEqp.Total__c > 0) {
                    reqEqpMap.put(reqEqp.id, reqEqp);
                    requestIds.add(reqEqp.Request__c);
                }
        }
        for(Asset__c asset: [SELECT Request__c, Equipment__c FROM Asset__c WHERE Request__c IN: requestIds AND recordTypeId IN: assetTypeIds WITH SECURITY_ENFORCED]) {
            for(Id eqpId: reqEqpMap.keySet()) {
                if(reqEqpMap.get(eqpId).Request__c == asset.Request__c && reqEqpMap.get(eqpId).Equipment__c == asset.Equipment__c) {
                    asset.Amount_Authorized__c = reqEqpMap.get(eqpId).Total__c;
                    assetList.add(asset);
                }
            }
        }
        if(assetList.size() > 0) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Asset__c', assetList, 'update', true, 'NC_RequestEquipmentTriggerHandler', 'updateNDBEDPAsset');
            update objectDecision.getRecords();
        }
    }*/
    
    /*
    *********************************************************
    @Method Name    : updateNDBEDPInvoices
    @description    : update NDBEDP invoice and line item from asset changes
    @param          : List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateNDBEDPInvoices(List<Request_Equipment__c> newList, Map<Id, Request_Equipment__c> oldMap) {
        Map<Id, Request_Equipment__c> equipmentRequestMap = new Map<Id, Request_Equipment__c>();
        Map<String, Request_Equipment__c> equipmentNameMap = new Map<String, Request_Equipment__c>();
        Map<Id, Request_Equipment__c> reqEqpMap = new Map<Id, Request_Equipment__c>();

        for(Request_Equipment__c reqEqp: newList) {
            if(reqEqp.recordTypeId == ndbedpEqpRecordType
                && ((reqEqp.UnitPrice__c != oldMap.get(reqEqp.id).UnitPrice__c
                && reqEqp.UnitPrice__c != null
                && reqEqp.UnitPrice__c != reqEqp.Equipment_Amount_Authorized__c)
                    || (reqEqp.Shipping__c != null && reqEqp.Shipping__c != oldMap.get(reqEqp.id).Shipping__c))) {
                    equipmentRequestMap.put(reqEqp.Equipment__c, reqEqp);
                    equipmentNameMap.put(reqEqp.Equipment_Name__c, reqEqp);
                    reqEqpMap.put(reqEqp.id, reqEqp);
                }
        }

        List<Equipment__c> updateEquipments = new List<Equipment__c>();
        if(equipmentRequestMap.size() > 0) {
            for(Id eqpId: equipmentRequestMap.keySet()) {
                Equipment__c eqp = new Equipment__c();
                eqp.id = eqpId;
                eqp.Amount_Authorized__c = equipmentRequestMap.get(eqp.id).UnitPrice__c;
                updateEquipments.add(eqp);
            }
        }

        List<Asset__c> assetList = new List<Asset__c>();
        if(equipmentRequestMap.size() > 0) {
            for(Asset__c asset: [SELECT Request__c, Equipment__c FROM Asset__c WHERE Request__r.Status = 'Approved' AND Equipment__c IN: equipmentRequestMap.keySet() AND recordTypeId IN: assetTypeIds WITH SECURITY_ENFORCED]) {
                Asset__c assetObj = new Asset__c();
                assetObj.id = asset.id;
                assetObj.Amount_Authorized__c = equipmentRequestMap.get(asset.Equipment__c).UnitPrice__c;
                assetList.add(assetObj);
            }
        }

        List<Invoice_Line_Item__c> updateLineItems = new List<Invoice_Line_Item__c>();
        if(equipmentNameMap.size() > 0) {
            Set<String> invoiceStatus = new Set<String>{'Approved', 'Paid', 'Submitted and Error', 'Canceled'};
            for(Invoice_Line_Item__c lineItem: [SELECT Equipment_Name__c FROM Invoice_Line_Item__c WHERE Equipment_Name__c IN: equipmentNameMap.keySet() AND Invoice__r.Status__c NOT IN: invoiceStatus WITH SECURITY_ENFORCED]) {
                lineItem.Amount_Authorized__c = equipmentNameMap.get(lineItem.Equipment_Name__c).UnitPrice__c * equipmentNameMap.get(lineItem.Equipment_Name__c).Ordered_Quantity__c;
                Decimal shippingCost = equipmentNameMap.get(lineItem.Equipment_Name__c).Shipping__c != null ? equipmentNameMap.get(lineItem.Equipment_Name__c).Shipping__c : 0;
                lineItem.Amount_Billed__c = lineItem.Amount_Authorized__c + shippingCost;
                updateLineItems.add(lineItem);
            }
        }

        if(updateEquipments.size() > 0) {
            update updateEquipments;
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Equipment__c', updateEquipments, 'update', true,'NC_RequestEquipmentTriggerHandler','updateNDBEDPInvoices');
            //update decision.getRecords();
        }
        if(assetList.size() > 0) {
            system.debug('asset list'+assetList);
            update assetList;
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Asset__c', assetList, 'update', true,'NC_RequestEquipmentTriggerHandler','updateNDBEDPInvoices');
            //update decision.getRecords();
        }
        if(updateLineItems.size() > 0) {
            update updateLineItems;
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', updateLineItems, 'update', true,'NC_RequestEquipmentTriggerHandler','updateNDBEDPInvoices');
            //update decision.getRecords();
        }
    }
    
}