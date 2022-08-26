/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class  NCDSH_SignatureController {
    /*
    *********************************************************
    @Method Name    : saveSignature
    @description    : create or update signature attachment and store attachment id in parent record
    @param          : String signatureBody, Id applicationId
    @return         : Id
    ********************************************************
    */
    @AuraEnabled
    public static Id saveSignature(String signatureBody, Id applicationId) {

        List < Attachment > att = [SELECT Id, Name, Body, ContentType, ParentId From Attachment where ParentId =: applicationId AND Name = 'Consumer Esignature' WITH SECURITY_ENFORCED
        LIMIT 1
        ];

        Attachment a = new Attachment();
            if (!att.isEmpty()) {
                a.parentId = att[0].ParentId;
                a.Id = att[0].Id;
                a.Body = EncodingUtil.base64Decode(signatureBody);
                //update a;
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Attachment', new List<Attachment>{a}, 'update', true,'NCDSH_SignatureController','saveSignature');
            	update decision.getRecords();

            } else {
                //Attachment a = new Attachment();
                a.ParentId = applicationId; // record id of object.
                a.Body = EncodingUtil.base64Decode(signatureBody);
                a.ContentType = 'image/jpeg';
                a.Description = 'Sign';
                a.Name = 'Consumer Esignature';
                //insert a;
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Attachment', new List<Attachment>{a}, 'insert', true,'NCDSH_SignatureController','saveSignature');
            	insert decision.getRecords();
                a = (Attachment)decision.getRecords()[0];
            }
            // saveDocumentWithSign(applicationId);

            Map<String, Schema.SobjectField> mapOfCurrentObjectFields  = applicationId.getSobjectType().getDescribe().fields.getMap();
            if(mapOfCurrentObjectFields.containsKey('Signature_Id__c')) {
                Sobject obj = applicationId.getSobjectType().newSObject(applicationId);
                obj.put('Signature_Id__c', a.id);
                //update obj;
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Sobject', new List<Sobject>{obj}, 'update', true,'NCDSH_SignatureController','saveSignature');
            	update decision.getRecords();
            }

            return a.id;

    }  

    /*
    *********************************************************
    @Method Name    : saveDocumentWithSign
    @description    : Save document viewer in files
    @param          : String applicationId
    @return         : void
    ********************************************************
    */
    public static void saveDocumentWithSign(String applicationId){
        PageReference pg;
        Blob body;
        pg = Page.NC_DocumentViewer;
        pg.getParameters().put('id',applicationId);
        try {
            body = pg.getContent();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        // Attachment attach = new Attachment();
        // attach.Body = body;
        // attach.Name = 'Accecptance.pdf';
        // attach.contentType = 'application/pdf';
        // attach.Description = 'Document';
        // attach.IsPrivate = false;
        // attach.parentId = applicationId;
        // insert attach;

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'Accecptance.pdf'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Accecptance'; // Display name of the files
        conVer.VersionData = body; // converting your binary string to Blog
        //INSERT conVer;    //Insert ContentVersion
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('ContentVersion', new List<ContentVersion>{conVer}, 'insert', true,'NCDSH_SignatureController','saveDocumentWithSign');
        insert decision.getRecords();
        conVer = (ContentVersion)decision.getRecords()[0];

        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id WITH SECURITY_ENFORCED].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = applicationId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        //INSERT conDocLink;
        SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('ContentDocumentLink', new List<ContentDocumentLink>{conDocLink}, 'insert', true,'NCDSH_SignatureController','saveDocumentWithSign');
        insert decision1.getRecords();
    }

    /*
    *********************************************************
    @Method Name    : getImage
    @description    : get all attachments under parent record
    @param          : String applicationId
    @return         : list <Attachment>
    ********************************************************
    */
    @AuraEnabled
    public static list < Attachment > getImage(String applicationId) {
      return [select Id, Name, ContentType, body from Attachment
            where parentid =: applicationId and ContentType in ('image/png', 'image/jpeg', 'image/gif') WITH SECURITY_ENFORCED
        ];
    }
}