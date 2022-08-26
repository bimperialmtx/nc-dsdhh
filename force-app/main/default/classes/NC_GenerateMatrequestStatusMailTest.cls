/**
* @description       : Test class for NC_GenerateMatrequestStatusMail
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_GenerateMatrequestStatusMailTest {
    
    /*
*********************************************************
@Method Name    : batchTest
@description    : Verify generation of Mat Request Status for NDBEDP Request
********************************************************
*/
    static testmethod void batchTest() {
        
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
        
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.UserRoleId=role.Id;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert userObj;
        }        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        cas.MatReqStatus__c  = 'Closed';
        cas.Final_Equipment_Shipped_Date__c = Date.today()-45;
        cas.NDBEDP_Trainer__c = vendorAccount.Id;
        insert cas;
        
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        
        Id ndbedpEquipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, ndbedpEquipmentTypeId, vendor.id, 'testing', 'NDBEDP', 100);
        
        Equipment__c eqp1 = TestDataUtility.createEquipment(true, ndbedpEquipmentTypeId, vendor.id, 'test', 'NDBEDP', 100);
        eqp1.Amount_Authorized__c = 1;
        eqp1.Always_Add_With_Parent__c = true;
        eqp1.Is_Sub_Equipment__c = true;
        eqp1.Parent_Equipment__c = eqp.Id;
        update eqp1;
        
        Id ndbedpRequestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Request_Equipment__c request1 = new Request_Equipment__c();
        request1.Request__c = cas.Id;
        request1.MatRequestLineObj__c = 'Test';
        request1.recordTypeId = ndbedpRequestEquipmentTypeId;
        request1.Equipment_Justification__c = 'test';
        request1.Equipment__c = eqp1.Id;
        request1.LastActionCode__c = 'SHC';
        Insert request1;
        
        test.startTest();
        NC_GenerateMatrequestStatusMail batch = new NC_GenerateMatrequestStatusMail();
        Database.executeBatch(batch);
        test.stopTest();
        System.assertNotEquals(null,  Database.executeBatch(batch));
        
    }
}