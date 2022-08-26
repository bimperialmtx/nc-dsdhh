/**
* @description       : Test class for NC_AssetTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_AssetTriggerHandlerTest {
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Verify Asset validation and related operations
    ********************************************************
    */
    @IsTest
    public static void makeData(){
        
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.Name='TestA';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        acc.Hearing_Aid_Provider__c = true;
        insert acc;
        
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
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Contact con=new Contact();   
        con.LastName='Test Con';
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas;
        
        Attendees__c attendess = new Attendees__c();
        Insert attendess;
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();   
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, equipmentTypeId, null, 'Test', 'Hearing Aid', 100);
                
        Asset__c asset = new Asset__c();
        asset.Authorization__c = auth.Id;
        Insert asset;
        
        asset.Status__c = 'Cancelled';
        asset.Returned_Equipment__c = true;
        asset.Equipment_Received_Date__c = Date.today();
        asset.Consumer_Equipment_Received_Details__c = 'Consumer Pick Up';
        asset.Consumer_Pickup_Detail__c = 'test';
        asset.Signature_ID__c  = 'test';
        asset.Equipment__c = eqp.Id;
        asset.Request__c = cas.Id;
        update asset;
        
        Asset__c asset1 = new Asset__c();
        asset1.Authorization__c = auth.Id;
        Insert asset1;
        
        asset1.Status__c = 'Equipment Unavailable';
        asset1.Returned_Equipment__c = true;
        asset1.Equipment_Received_Date__c = Date.today();
        asset1.Consumer_Equipment_Received_Details__c = 'Consumer Pick Up';
        asset1.Consumer_Pickup_Detail__c = 'test';
        asset1.Signature_ID__c  = 'test';
        // asset1.Equipment__c = eqp.Id;
        update asset1;
        
        Asset__c asset2 = new Asset__c();
        asset2.Authorization__c = auth.Id;
        asset2.Status__c = 'Cancelled';
        Insert asset2;
        
        asset2.Status__c = 'Equipment Unavailable';
        update asset2; 
        
        
        Asset__c asset3 = new Asset__c();
        asset3.Authorization__c = auth.Id;
        asset3.Status__c = 'Cancelled';
        asset3.RecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Asset').getRecordTypeId();
        Insert asset3;
        
        asset3.Status__c = 'Shipped';
        update asset3;
        
        Asset__c asset4 = new Asset__c();
        asset4.Authorization__c = auth.Id;
        asset4.Status__c = 'Cancelled';
        asset4.RecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Asset').getRecordTypeId();
        Insert asset4;
        
        asset4.Status__c = 'Shipped';
        asset4.Parent_Asset__c=asset3.Id;
        update asset4;
        
        Asset__c ass=[SELECT Id,Status__c FROM Asset__c LIMIT 1];
        System.assertEquals('Returned', ass.Status__c);
        
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        List<Asset__c> assetList=new List<Asset__c>();
        assetList.add(asset);
        assetList.add(asset1);
        assetList.add(asset2);
        assetList.add(asset3);
        assetList.add(asset4);
        NC_AssetTriggerHandler.updateInvoiceLineItem(assetList);
        NC_AssetTriggerHandler.deleteSubEquipment(assetList);
        System.assertEquals(1000, invLineItem1.Amount_Authorized__c);
        Delete asset;
    }
}