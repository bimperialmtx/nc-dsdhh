/**
* @description       : Test class for NC_ContentDocumentLinkTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_ContentDocumentLinkTriggerHandlerTest {
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_CAR_Cart_Test
    @description    : Create document and contentdocumentlink validations and operations
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_Cart_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Cart', rc.id);
        commReq.File_Record_Id_s__c = 'text';
        update commReq;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = commReq.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Communication_Access_Request__c com=[Select Id,Files_Uploaded__c FROM Communication_Access_Request__c LIMIT 1];
        System.assertEquals(true, com.Files_Uploaded__c!=null);
        Delete documents[0];
    }
}