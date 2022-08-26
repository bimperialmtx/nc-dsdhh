/**
* @description       : Test class for NC_AuthorizationTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_AuthorizationTriggerHandlerTest {
    /*
*********************************************************
@Method Name    : makeData
@description    : Verify Authorization validation and related operations
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
        auth.Status__c='Cancelled';
        auth.Cancelled_Comment__c='Test';
        update auth;
        
        Authorization__c auth1 = TestDataUtility.createAuthorization(true, authAssessmentId);
        auth1.Status__c='Returned';
        update auth1;
        
       /* Id EquipmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();   
        Authorization__c auth2 = TestDataUtility.createAuthorization(true, EquipmentId);
        auth2.Status__c='Returned';
        update auth2;*/
        
        Id AuthorizationTrainingVendorIncoiveId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Training_Vendor');
        Authorization__c auth3 = TestDataUtility.createAuthorization(true, AuthorizationTrainingVendorIncoiveId);
        auth3.Cancelled_Reason__c = 'Cancelled due to Weather';
        auth3.Status__c='Cancelled';
        auth3.Cancel_Authorization__c = true;
        auth3.Cancelled_Comment__c='Test1';
        update auth3;
        
        
        Id AuthorizationCommunicationrequestId = NC_Utility.RecordTypeUtilityMethod('Authorization__c',NC_Constant.COMMUNICATION_ACCESS_REQUEST);    
        Authorization__c auth4 = TestDataUtility.createAuthorization(true, AuthorizationTrainingVendorIncoiveId);
        auth4.Cancelled_Reason__c = 'Cancelled due to Weather';
        auth4.Status__c='Cancelled';
        auth4.Cancel_Authorization__c = true;
        auth4.Cancelled_Comment__c=auth3.Cancelled_Comment__c;
        update auth4;
        Delete auth4;   
        undelete auth4;
        
        
        System.assertEquals('Test1', auth4.Cancelled_Comment__c);
    }
    
    /*
*********************************************************
@Method Name    : updateRelatedInvoicesTest
@description    : Verify Authorization related invoices operation
********************************************************
*/
    @isTest
    public static void updateRelatedInvoicesTest(){
        
        Id AuthorizationCommunicationrequestId = NC_Utility.RecordTypeUtilityMethod('Authorization__c',NC_Constant.COMMUNICATION_ACCESS_REQUEST);    
        Authorization__c auth = TestDataUtility.createAuthorization(true, AuthorizationCommunicationrequestId);
        List<Authorization__c> authList=new List <Authorization__c>();
        authList.add(auth); 
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Vendor_Type__c = 'CART';
        insert invoice;
        
        test.startTest();
        NC_AuthorizationTriggerHandler.updateRelatedInvoices(authList);
        NC_AuthorizationTriggerHandler.rollUpOnDelete(authList);
        Authorization__c authorization = [SELECT Id,Vendor_Status__c,Total_Authorized_Amount__c,Update_If_Vendor_Inactive__c,RecordTypeId,All_Inclusive_Flat_Fee__c, Vendor__c,Vendor__r.MM102_error_reason__c  FROM Authorization__c WHERE Id =: auth.Id];
        System.assertEquals(false, authorization.All_Inclusive_Flat_Fee__c);
        System.assertEquals(false, authorization.Update_If_Vendor_Inactive__c);
        Invoice__c inv=[SELECT Id,Authorization__c,Status__c FROM Invoice__c WHERE Authorization__c=:auth.Id];
        System.assertEquals('Returned', inv.Status__c);
        test.stopTest();
        
    }
    
}