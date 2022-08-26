/*
*   Class Name: NCDSDHH_FileUploadController
*   Description: File Uploader Class for Any Object
*
*   Date            New/Modified         User                 Identifier                Description
*   24/04/2020         New             Gourav(mtx)
*   24/04/2020         Modified        Shubham(mtx)                                     (Added New Method mapRelatedFields, deleteDocumentName)
*   
*/

public without sharing class NC_FileUploadController {

    /*
    *********************************************************
    @Method Name    : mapRelatedFields
    @description    : Map loopkup Fields to Their API Name
    @param          : Id recordId, String fieldDisable, String fieldValue
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> mapRelatedFields(Id recordId, String fieldDisable, String fieldValue){
        Map<String,Object> mapOfFieldApiNameWithId = new Map<String, Id>();
        Map<String,Object> result = new Map<String, Object>();
        String Fields= '';
        Boolean isDisbaleField = false;

        //Get Object Name From Describe
        String objctName = recordId.getSobjectType().getDescribe().getName();

        //Get All Field From Object
        for(Schema.sObjectField fieldvalues : recordId.getSobjectType().getDescribe().fields.getMap().values()){
            if(fieldvalues.getDescribe().getName() == fieldDisable){
                isDisbaleField = true;
            }
            //Validating Field is Lookup/MasterDetail - iF Yes The Add their API name in a String
            IF(fieldvalues.getDescribe().getType() == Schema.DisplayType.reference){
                Fields += Fields =='' ? fieldvalues.getDescribe().getName() : ', ' +  fieldvalues.getDescribe().getName();
                mapOfFieldApiNameWithId.put(fieldvalues.getDescribe().getName(), null);
            }
        }
        //Creating a dynamic Query
        if(isDisbaleField){
            Fields += ',' + fieldDisable;
        }
        
        String Query = 'SELECT '+ String.escapeSingleQuotes(Fields) +' FROM ' + String.escapeSingleQuotes(objctName) + ' WHERE Id=\'' + String.escapeSingleQuotes(recordId) + '\'';
        //Using Database.query fetch all Details
        List<Sobject> istOfSobjects = Database.query(Query);

        Boolean isParentEditable = false;
        List<UserRecordAccess> recordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =: recordId WITH SECURITY_ENFORCED];
        if(recordAccess != null && recordAccess.size() > 0) {
            isParentEditable = recordAccess[0].HasEditAccess;
        }

        If(!istOfSobjects.IsEmpty()){
            Sobject recordObject = istOfSobjects[0];
            for(String fieldName : mapOfFieldApiNameWithId.keySet()){
                mapOfFieldApiNameWithId.put(fieldName,recordObject.get(fieldName));
            }
            if(isDisbaleField && recordObject.get(fieldDisable) == fieldValue){
                result.put('Disable', true);
            }else{
                result.put('Disable', false);
            }
            result.put('enableUpload', isParentEditable);
        }

        //Return Result Object to Lightning Component
        result.put('FieldValues',mapOfFieldApiNameWithId);
        return result;
    }

    /*
    *********************************************************
    @Method Name    : retrieveDocumentInfo
    @description    : Retrive Document Uploaded on Object
    @param          : String fileName, Id objectId, String filter
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveDocumentInfo(String fileName, Id objectId, String filter){
        Map<String,Object> result = new Map<String,Object>();
        Set<Id> setOfContentDocumentId = new Set<Id>();

        if(objectId != null && String.isNotBlank(filter)) {
            try {
                String objectName = objectId.getSobjectType().getDescribe().getName();
                String query = 'SELECT id FROM ' + objectName + ' WHERE Id =:objectId AND ' + filter;
                List<SObject> sObjList = Database.query(query);
                if(sObjList != null && sObjList.size() > 0) {
                    result.put('docVisible', true);
                } else {
                    result.put('docVisible', false);
                }
            } catch (Exception e) {
                result.put('docVisible', false);
            }
        } else {
            result.put('docVisible', true);
        }

        List<ContentDocumentLink> documentsList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocument.Title =: fileName AND LinkedEntityId =: objectId WITH SECURITY_ENFORCED];
        for(ContentDocumentLink contentDocumentLinkRecord : documentsList){
            setOfContentDocumentId.add(contentDocumentLinkRecord.ContentDocumentId);
        }

        List<ContentVersion> versionData = [SELECT Id, ContentDocumentId,Description, VersionNumber,FileExtension, Title, LastModifiedBy.Name, LastModifiedDate FROM ContentVersion WHERE ContentDocumentId IN: setOfContentDocumentId WITH SECURITY_ENFORCED ORDER By CreatedDate asc ];
        result.put('documentId',documentsList.size() > 0 ? documentsList[0].Id : null);
        result.put('contentDocumentId',versionData.size() > 0 ? versionData[0].ContentDocumentId : null);
        return result;
    }

    /*
    *********************************************************
    @Method Name    : deleteDocumentName
    @description    : Delete Document and Update the Document Uploaded Check Box
    @param          : Id documentId, String fileName, Id objectId, String fieldApiName, Id currentObjectId
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static string deleteDocumentName(Id documentId, String fileName, Id objectId, String fieldApiName, Id currentObjectId){
        try {
            //Delete Object Record Using its Id.
            Delete documentId.getSobjectType().newSObject(documentId);
            updateRelatedRecords(false, fileName, objectId, fieldApiName, currentObjectId);
            if(currentObjectId != null) {
                String idString = String.valueOf(currentObjectId);
                if(idString.substring(0, 3) == '001') {
                 	updateRelatedRecordsForRenew(false, fileName, fieldApiName, currentObjectId);      
                }
            }
            return 'success';
        } catch(DMLException ex) {
            return ex.getDMLMessage(0);
        }
    }

    /*
    *********************************************************
    @Method Name    : updateDocumentName
    @description    : Update Document Name and Update the Document Uploaded Check Box
    @param          : Id documentId, String fileName, Id objectId, String fieldApiName, Id currentObjectId
    @return         : Map<String, String>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, String> updateDocumentName(Id documentId, String fileName, Id objectId, String fieldApiName, Id currentObjectId){
        // Create Contenet Document Object
        Map<String, String> returnMap = new Map<String, String>();
        ContentDocument doc = new ContentDocument();
        doc.Id = documentId;
        doc.Title = fileName;
        try {
            //Update Content Document Name
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('ContentDocument', new List<ContentDocument>{doc}, 'update', true,'NC_FileUploadController','updateDocumentName');
            update decision.getRecords();
           // update doc;
           if(fieldApiName == 'Service_Documentation__c') {
            Sobject obj = currentObjectId.getSobjectType().newSObject(currentObjectId);
            obj.put(fieldApiName,true);
            SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NC_FileUploadController','updateRelatedRecords');
            update decision1.getRecords();
           } else {
            updateRelatedRecords(true, fileName, objectId, fieldApiName, currentObjectId);
           }
            //updateRelatedRecords(true, fileName, objectId, fieldApiName, currentObjectId);
            shareFileToExternalUser(documentId, new Set<Id>{objectId,currentObjectId});
            //return 'success';
            returnMap.put('success', 'success');
        } catch(DMLException ex) {
            returnMap.put('error', ex.getDMLMessage(0));
        }
        return returnMap;
    }

    /*
    *********************************************************
    @Method Name    : updateRelatedRecords
    @description    : update related record checkbox field
    @param          : Boolean chkbkVal, String fileName, Id objectId, String fieldApiName, Id currentObjectId
    @return         : void
    ********************************************************
    */
    public static void updateRelatedRecords(Boolean chkbkVal, String fileName, Id objectId, String fieldApiName, Id currentObjectId) {
        //Get all Fields from Object using its Id for Current Object
        Map<String, Schema.SobjectField> mapOfCurrentObjectFields  = currentObjectId.getSobjectType().getDescribe().fields.getMap();

        //Get all Fields from Object using its Id for Related Object
        Map<String, Schema.SobjectField> mapOFobjectId  = objectId.getSobjectType().getDescribe().fields.getMap();

        //Check for Field Api Name Exist on Related Object
        if(mapOFobjectId.containsKey(fieldApiName) && mapOFobjectId.get(fieldApiName).getDescribe().isUpdateable()){
            //If Yes Then updated the related field Checkbox
            Sobject obj = objectId.getSobjectType().newSObject(objectId);
            obj.put(fieldApiName,chkbkVal);
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true, 'NC_FileUploadController','updateRelatedRecords');
            update decision.getRecords();
        }

        //Check for Field Api Name Exist on current Object
        if(mapOfCurrentObjectFields.containsKey(fieldApiName) && mapOfCurrentObjectFields.get(fieldApiName).getDescribe().isUpdateable()){
            //If Yes Then updated the current field Checkbox
            Sobject obj = currentObjectId.getSobjectType().newSObject(currentObjectId);
            obj.put(fieldApiName,chkbkVal);
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NC_FileUploadController','updateRelatedRecords');
            update decision.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : updateFileRelatedField
    @description    : update file related field
    @param          : Boolean chkbkVal, Id documentId, String fileName, String fieldApiName, Id currentObjectId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void updateFileRelatedField(Boolean chkbkVal, Id documentId, String fileName, String fieldApiName, Id currentObjectId) {
        //Get all Fields from Object using its Id for Current Object
        Map<String, Schema.SobjectField> mapOfCurrentObjectFields  = currentObjectId.getSobjectType().getDescribe().fields.getMap();

        //Check for Field Api Name Exist on current Object
        if(mapOfCurrentObjectFields.containsKey(fieldApiName) && mapOfCurrentObjectFields.get(fieldApiName).getDescribe().isUpdateable()){
            //If Yes Then updated the current field Checkbox
            Sobject obj = currentObjectId.getSobjectType().newSObject(currentObjectId);
            obj.put(fieldApiName,chkbkVal);
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NC_FileUploadController','updateRelatedRecords');
            update decision.getRecords();
        }
        Delete documentId.getSobjectType().newSObject(documentId);
    }

    /*
    *********************************************************
    @Method Name    : shareFileToExternalUser
    @description    : Share file with portal users
    @param          : String contentDocumentId, Set<Id> linkedEntityIdSet
    @return         : void
    ********************************************************
    */
    public static void shareFileToExternalUser(String contentDocumentId, Set<Id> linkedEntityIdSet) {
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        try {
            if(String.isNotBlank(contentDocumentId) && linkedEntityIdSet != null && linkedEntityIdSet.size() > 0) {
                Set<String> supportedObjects = new Set<String>{'Account','Invoice__c','Case'};
                Set<String> linkedEntityIds = new Set<String>();
                for(Id parentId: linkedEntityIdSet) {
                    if(parentId != null) {
                        String keyCode  = String.valueOf(parentId).subString(0,3);
                        for(Schema.SObjectType objectInstance : Schema.getGlobalDescribe().values()) {
                            if(objectInstance.getDescribe().getKeyPrefix() == keyCode && supportedObjects.contains(objectInstance.getDescribe().getName())) {
                                linkedEntityIds.add(parentId+'');
                            }
                        }
                    }
                }
                for(ContentDocumentLink cdl: [SELECT id FROM ContentDocumentLink WHERE contentDocumentId =: contentDocumentId AND LinkedEntityId IN: linkedEntityIds WITH SECURITY_ENFORCED]) {
                    ContentDocumentLink newCdl = new ContentDocumentLink();
                    newCdl.Id = cdl.Id;
                    newCdl.Visibility = 'AllUsers';
                    cdlList.add(newCdl);
                }
                if(cdlList.size() > 0) {
                    SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('ContentDocumentLink', cdlList, 'update', true,'NC_FileUploadController','shareFileToExternalUser');
                    update decision.getRecords();
                    //update cdlList;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error: '+e.getMessage());
                }
    }

    /*
    *********************************************************
    @Method Name    : updateContentVersion
    @description    : update content version
    @param          : String uploadId, String recordId, String fileName, String fieldApiName, Id currentObjectId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void updateContentVersion(String uploadId, String recordId, String fileName, String fieldApiName, Id currentObjectId){
        Boolean isSuccess = false;
        String parentId = '';
        String sObjectName = 'Account';
        ContentVersion newConterntVersion = new ContentVersion();
        
        List<ContentDocument> cdList = new List<ContentDocument>();
        for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId AND ContentDocument.Title =: fileName]) {
            ContentDocument cd = new ContentDocument();
            cd.id = cdl.ContentDocumentId;
            cdList.add(cd);
        }
        if(cdList.size() > 0) {
            delete cdList;
        }
        
        ContentDocument doc = new ContentDocument();
        doc.Id = uploadId;
        doc.Title = fileName;
       update doc;
      //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('ContentDocument', new List<ContentDocument>{doc}, 'update', true, 'NC_FileUploadController','updateContentVersion');
      //update decision.getRecords();
        // Get the parentId of the content document which is recently uploaded
        List<ContentDocumentLink> contentDocumentRecordList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId =: uploadId];//WITH SECURITY_ENFORCED
        for(ContentDocumentLink contentDocumentRecord : contentDocumentRecordList){
            if(contentDocumentRecord.LinkedEntityId != null && ID.valueOf(contentDocumentRecord.LinkedEntityId).getSobjectType().getDescribe().getName() == sObjectName){
                parentId = String.valueOf(contentDocumentRecord.LinkedEntityId);
            }
        }

        if(parentId != null && parentId != ''){
            // Insert the content version for the existing content document
            List<ContentDocumentLink> contentDocumentFile = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:parentId];//WITH SECURITY_ENFORCED
            for(ContentVersion contentVersionRecord  : [SELECT Id, ContentDocumentId,LastModifiedById, ContentBodyId, VersionNumber,Title, PathOnClient, OwnerId, FileType, VersionData, ContentSize, FileExtension, FirstPublishLocationId, Origin, ContentLocation,Checksum FROM ContentVersion WHERE ContentDocumentId =: uploadId //WITH SECURITY_ENFORCED 
                                                        ORDER BY VersionNumber ]){
                newConterntVersion = contentVersionRecord.clone();
            }
            newConterntVersion.Id = null;
            newConterntVersion.ContentBodyId = null;
            newConterntVersion.ContentDocumentId = contentDocumentFile[0].ContentDocumentId;
            newConterntVersion.FirstPublishLocationId = null;
            insert newConterntVersion;
           // SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('ContentVersion', new List<ContentVersion>{newConterntVersion}, 'insert', true, 'NC_FileUploadController','updateContentVersion');
           // insert decision1.getRecords();
            updateRelatedRecordsForRenew(true, fileName, fieldApiName, currentObjectId); 
        }else{
            // Delete ContentDocument of the uploaded file
            //DELETE [SELECT Id FROM ContentDocument WHERE Id =: uploadId ];
        }
    }

    /*
    *********************************************************
    @Method Name    : updateRelatedRecordsForRenew
    @description    : update Related Records for Renew
    @param          : Boolean chkbkVal, String fileName, String fieldApiName, Id currentObjectId
    @return         : void
    ********************************************************
    */
    public static void updateRelatedRecordsForRenew(Boolean chkbkVal, String fileName, String fieldApiName, Id currentObjectId) {
        //Get all Fields from Object using its Id for Current Object
        Map<String, Schema.SobjectField> mapOfCurrentObjectFields  = currentObjectId.getSobjectType().getDescribe().fields.getMap();
        String objctName = currentObjectId.getSobjectType().getDescribe().getName();
         //Check for Field Api Name Exist on current Object
        String fieldApiNameForRenew = fieldApiName.substring(0,fieldApiName.length()-3) + '_Renew__C';
        Sobject obj = currentObjectId.getSobjectType().newSObject(currentObjectId);
        Boolean updateRecord = false;

        if(mapOfCurrentObjectFields.containsKey(fieldApiNameForRenew) && mapOfCurrentObjectFields.get(fieldApiNameForRenew).getDescribe().isUpdateable()){
            //If Yes Then updated the current field Checkbox
            
            if(objctName == 'Account'){
                Account accountRecord = [SELECT Id, Status__c, Document_In_Renewal_Process__c FROM Account Where Id=: currentObjectId WITH SECURITY_ENFORCED];
                if((accountRecord.Status__c == 'Approved' || accountRecord.Status__c == 'Renewal Submitted' ) && accountRecord.Document_In_Renewal_Process__c){
                    if(accountRecord.Status__c == 'Approved'){
                        obj.put('Status__c','Renewal Submitted');
                    }
                    obj.put(fieldApiNameForRenew,chkbkVal);
                    updateRecord = true;
                }
            }
        }
        //Check for Field Api Name Exist on current Object
        if(mapOfCurrentObjectFields.containsKey(fieldApiName) && mapOfCurrentObjectFields.get(fieldApiName).getDescribe().isUpdateable()){
            //If Yes Then updated the current field Checkbox
            obj.put(fieldApiName,chkbkVal);
            updateRecord = true;
        }
        if(updateRecord){
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NC_FileUploadController','updateRelatedRecordsForRenew');
            update decision.getRecords();
        }

    }

}