/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   06-21-2021   kavya.konagonda@mtxb2b.com   Initial Version
**/
public without sharing class  NC_SignatureController {
    /*
    *********************************************************
    @Method Name    : saveSignature
    @description    : insert or update signature attachment and update attachment id in parent record
    @param          : String signatureBody, Id applicationId, String customField
    @return         : Id
    ********************************************************
    */
    @AuraEnabled
    public static Id saveSignature(String signatureBody, Id applicationId, String customField) {

        String docName = 'Consumer Esignature';
        docName = String.isNotBlank(customField) ? docName + customField : docName;
        List <Attachment> att = [SELECT Id, Name, Body, ContentType, ParentId From Attachment where ParentId =: applicationId AND Name =: docName WITH SECURITY_ENFORCED LIMIT 1];

        Attachment a = new Attachment();
        if (!att.isEmpty()) {
            // a.parentId = att[0].ParentId;
            // a.Id = att[0].Id;
            // a.Body = EncodingUtil.base64Decode(signatureBody);
            // update a;
            delete att[0];

            a.ParentId = applicationId; // record id of object.
            a.Body = EncodingUtil.base64Decode(signatureBody);
            a.ContentType = 'image/jpeg';
            a.Description = 'Sign';
            a.Name = docName;//'Consumer Esignature';
            //insert a;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Attachment', new List<Attachment>{a}, 'insert', true,'NC_SignatureController','saveSignature');
            insert decision.getRecords();
            a.id = decision.getRecords()[0].id;

        } else {
            //Attachment a = new Attachment();
            a.ParentId = applicationId; // record id of object.
            a.Body = EncodingUtil.base64Decode(signatureBody);
            a.ContentType = 'image/jpeg';
            a.Description = 'Sign';
            a.Name = docName;//'Consumer Esignature';
            //insert a;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Attachment', new List<Attachment>{a}, 'insert', true,'NC_SignatureController','saveSignature');
            insert decision.getRecords();
            a.id = decision.getRecords()[0].id;
        }
        // saveDocumentWithSign(applicationId);

        Map<String, Schema.SobjectField> mapOfCurrentObjectFields  = applicationId.getSobjectType().getDescribe().fields.getMap();
        /*
        if(mapOfCurrentObjectFields.containsKey('Signature_Id__c')) {
            Sobject obj = applicationId.getSobjectType().newSObject(applicationId);
            obj.put('Signature_Id__c', a.id);
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NC_SignatureController','saveSignature');
            update decision.getRecords();
        }*/
        if(mapOfCurrentObjectFields.containsKey(customField)) {
            Sobject obj = applicationId.getSobjectType().newSObject(applicationId);
            obj.put(customField, a.id);
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NC_SignatureController','saveSignature');
            update decision.getRecords();
        }
        return a.id;
    }  

    /*
    *********************************************************
    @Method Name    : getImage
    @description    : get all attachments of parent record
    @param          : String applicationId
    @return         : list < Attachment >
    ********************************************************
    */
    @AuraEnabled
    public static list < Attachment > getImage(String applicationId) {
      return [select Id, Name, ContentType, body from Attachment
            where parentid =: applicationId and ContentType in ('image/png', 'image/jpeg', 'image/gif') WITH SECURITY_ENFORCED
        ];
    }
    
    /*
    *********************************************************
    @Method Name    : checkFilter
    @description    : Check if query filer returns record or not
    @param          : String recordId, String filter
    @return         : boolean
    ********************************************************
    */
    @AuraEnabled
    public static boolean checkFilter(String recordId, String filter) {
        boolean result = false;
        if(String.isNotBlank(recordId) && String.isNotBlank(filter)) {
         	String objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            String query = 'SELECT id FROM '+ objectName + ' WHERE id =: recordId AND ' + filter;
            try{
                List<SObject> sObjList = (List<SObject>)Database.query(query);
                result = !sObjList.isEmpty() ? true : false;
            } catch(Exception e) {
                throw new AuraHandledException('Error: '+e.getMessage());
                        }
        }
        return result;
    }
    
    @AuraEnabled
    public static Id uploadSign(String contentDocumentId, String recordId, String customField) {
        Id resultId;
        List<ContentVersion> cvList = [select VersionData from ContentVersion WHERE ContentDocumentId =: contentDocumentId];
        if(!cvList.isEmpty()) {
            System.debug('test-->'+EncodingUtil.base64Encode(cvList[0].VersionData));
            resultId = saveSignature(EncodingUtil.base64Encode(cvList[0].VersionData), recordId, customField);
            ContentDocument cd = new Contentdocument(Id = contentDocumentId);
            delete cd;
        }
        return resultId;
    }
}