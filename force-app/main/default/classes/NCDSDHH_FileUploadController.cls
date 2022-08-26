/*
*   Class Name: NCDSDHH_FileUploadController
*   Description: File Uploader Class for Any Object
*
*   Date            New/Modified         User                 Identifier                Description
*   24/04/2020         New             Gourav(mtx)
*   24/04/2020         Modified        Shubham(mtx)                                     (Added New Method mapRelatedFields, deleteDocumentName)
*   
*/

public without sharing class NCDSDHH_FileUploadController {

    /*
    *********************************************************
    @Method Name    : mapRelatedFields
    @description    : Map loopkup Fields to Their API Name
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> mapRelatedFields(Id recordId){
        Map<String,Object> mapOfFieldApiNameWithId = new Map<String, Id>();
        Map<String,Object> result = new Map<String, Object>();
        String Fields= '';

        //Get Object Name From Describe
        String objctName = recordId.getSobjectType().getDescribe().getName();

        //Get All Field From Object
        for(Schema.sObjectField fieldvalues : recordId.getSobjectType().getDescribe().fields.getMap().values()){
            //Validating Field is Lookup/MasterDetail - iF Yes The Add their API name in a String
            IF(fieldvalues.getDescribe().getType() == Schema.DisplayType.reference){
                Fields += Fields =='' ? fieldvalues.getDescribe().getName() : ', ' +  fieldvalues.getDescribe().getName();
                mapOfFieldApiNameWithId.put(fieldvalues.getDescribe().getName(), null);
            }
        }
        //Creating a dynamic Query
        String Query = 'SELECT '+ String.escapeSingleQuotes(Fields) +' FROM ' + String.escapeSingleQuotes(objctName) + ' WHERE Id=\'' + String.escapeSingleQuotes(recordId) + '\'';
        //Using Database.query fetch all Details
        List<Sobject> istOfSobjects = Database.query(Query);
        If(!istOfSobjects.IsEmpty()){
            Sobject recordObject = istOfSobjects[0];
            for(String fieldName : mapOfFieldApiNameWithId.keySet()){
                mapOfFieldApiNameWithId.put(fieldName,recordObject.get(fieldName));
            }
        }

        //Return Result Object to Lightning Component
        result.put('FieldValues',mapOfFieldApiNameWithId);
        return result;
    }

    /*
    *********************************************************
    @Method Name    : retrieveDocumentInfo
    @description    : Retrive Document Uploaded on Object
    @param          : String fileName, Id objectId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveDocumentInfo(String fileName, Id objectId){
        Map<String,Object> result = new Map<String,Object>();
        List<ContentDocumentLink> documentsList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocument.Title =: fileName AND LinkedEntityId =: objectId WITH SECURITY_ENFORCED];
        result.put('documentId',documentsList.size() > 0 ? documentsList[0].Id : null);
        result.put('contentDocumentId',documentsList.size() > 0 ? documentsList[0].ContentDocumentId : null);
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
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static string updateDocumentName(Id documentId, String fileName, Id objectId, String fieldApiName, Id currentObjectId){
        // Create Contenet Document Object
        ContentDocument doc = new ContentDocument();
        doc.Id = documentId;
        doc.Title = fileName;
        try {
            //Update Content Document Name
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('ContentDocument', new List<ContentDocument>{doc}, 'update', true,'NCDSDHH_FileUploadController','updateDocumentName');
            update decision.getRecords();

            updateRelatedRecords(true, fileName, objectId, fieldApiName, currentObjectId);
            return 'success';
        } catch(DMLException ex) {
            return ex.getDMLMessage(0);
        }
    }

    /*
    *********************************************************
    @Method Name    : updateRelatedRecords
    @description    : Update related object fields
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
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NCDSDHH_FileUploadController','updateRelatedRecords');
            update decision.getRecords();
        }

        //Check for Field Api Name Exist on current Object
        if(mapOfCurrentObjectFields.containsKey(fieldApiName) && mapOfCurrentObjectFields.get(fieldApiName).getDescribe().isUpdateable()){
            //If Yes Then updated the current field Checkbox
            Sobject obj = currentObjectId.getSobjectType().newSObject(currentObjectId);
            obj.put(fieldApiName,chkbkVal);
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NCDSDHH_FileUploadController','updateRelatedRecords');
            update decision.getRecords();
        }
    }
}