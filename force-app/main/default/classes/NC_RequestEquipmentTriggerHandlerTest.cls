/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_RequestEquipmentTriggerHandlerTest {
    
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Create data to be tested in this class
    ********************************************************
    */
    @TestSetup
    public static void makeData(){
        
        
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.First_Name__c='Test';
        acc.Last_Name__c= 'first';
        acc.Name = 'few';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        acc.Hearing_Aid_Provider__c = true;
        acc.Is_Vendor_on_Portal__c = true;
        insert acc;
        
        Account vendorAccount = TestDataUtility.createNDBEDPTrainer(true);
        
        
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
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        
        insert cas;
        
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
    
        Assessment__c ass =new Assessment__c();
        ass.Request__c =cas.Id;
        Insert ass;        
    }
    
    /*
    *********************************************************
    @Method Name    : insertRequestEquipmentMethod1
    @description    : Verify creation of equipment for NDBEDP request
    ********************************************************
    */
    @IsTest
    public static void insertRequestEquipmentMethod1(){
        Id vendorId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        Account vendor = [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId =:vendorId LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, equipmentTypeId, vendor.id, 'test1', 'Speech Equipment', 100);
        
        
        Request_Equipment__c request = new Request_Equipment__c();
        request.Request__c = cas.Id;
        request.MatRequestLineObj__c = 'Test';
        request.Equipment_Justification__c = 'test';
        request.Equipment__c = eqp.Id;
        Insert request;
        request.LastActionCode__c = 'SHC';
        update request;
        Test.stopTest();
        System.assertEquals(false, request.Unique_Id__c!=null);
        
    }

    /*
    *********************************************************
    @Method Name    : updateCaseStatus
    @description    : Verify ndbedp request status
    ********************************************************
    */
    @IsTest
    public static void updateCaseStatus(){
        Case cas = [SELECT Id,Email_address__c FROM Case LIMIT 1];
        cas.Status = 'Approved';
        Test.startTest();
        update cas;
        System.assertEquals('test@gmail.com',cas.Email_address__c);
        Test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : insertRequestEquipmentMethod2
    @description    : Verify request equipment creation for ndbedp request
    ********************************************************
    */
    @IsTest
    public static void insertRequestEquipmentMethod2(){
        Id vendorId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        Account vendor = [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId =:vendorId LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = [SELECT Id,Status FROM Case LIMIT 1];
        
        Test.startTest();
        
        Id ndbedpEquipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Equipment__c eqp1 = TestDataUtility.createEquipment(true, ndbedpEquipmentTypeId, vendor.id, 'test', 'NDBEDP', 100);
        eqp1.Amount_Authorized__c = 1;
        update eqp1;
        
        Id ndbedpRequestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Request_Equipment__c request1 = new Request_Equipment__c();
        request1.Request__c = cas.Id;
        request1.MatRequestLineObj__c = 'Test';
        request1.recordTypeId = ndbedpRequestEquipmentTypeId;
        request1.Equipment_Justification__c = 'test';
        request1.Equipment__c = eqp1.Id;
        request1.LastActionCode__c = 'SBC';
        Insert request1;
        request1.LastActionCode__c = 'SHC';
        request1.LineStatus__c = 'Closed';
        request1.UnitPrice__c = 10;
        // request1.Request_Status__c = 'Approved';
        update request1;        
        
        Asset__c result = NC_RequestEquipmentTriggerHandler.createAssetUtils(eqp1.Id, con.Id, cas.Id, cas.Id, 10, '10', cas.Id);
        System.assertEquals('10', result.Quantity__c);
        //Delete request1;
        Test.stopTest();
        
    }

    /*
    *********************************************************
    @Method Name    : insertRequestEquipmentMethod3
    @description    : Verify request equipment creation for ndbedp request
    ********************************************************
    */
    @IsTest
    public static void insertRequestEquipmentMethod3(){
        Id vendorId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        Account vendor = [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId =:vendorId LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case cas = [SELECT Id,Status FROM Case LIMIT 1];
        
        
        Id ndbedpEquipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Equipment__c eqp1 = TestDataUtility.createEquipment(true, ndbedpEquipmentTypeId, vendor.id, 'test', 'NDBEDP', 100);
        eqp1.Amount_Authorized__c = 1;
        update eqp1;
        
        Id ndbedpRequestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Request_Equipment__c request1 = new Request_Equipment__c();
        request1.Request__c = cas.Id;
        request1.MatRequestLineObj__c = 'Test';
        request1.recordTypeId = ndbedpRequestEquipmentTypeId;
        request1.Equipment_Justification__c = 'test';
        request1.Equipment__c = eqp1.Id;
        request1.LastActionCode__c = 'SBC';
        Test.startTest();
        Insert request1;
        Delete request1;
        Test.stopTest();
        System.assertEquals('Test', request1.MatRequestLineObj__c);  
    }
}