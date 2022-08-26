/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_CaseTriggerHandlerTest {
    /*
*********************************************************
@Method Name    : updateDocumentNameTest
@description    : verify update of document
********************************************************
*/
    @TestSetup
    public static void updateDocumentNameTest() {
        
        Contact con = TestDataUtility.createConsumer(true);
        
        Case request = TestDataUtility.createNDBEDPCase(true, con.id);
        
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Generic').getRecordTypeId();
        Case request1 = TestDataUtility.createCase(true, requestTypeId, con.id, 'EDS', 'Telephone');
        System.assertEquals('NDBEDP', request.Equipment_Types__c);
        
    }
    
    /*
*********************************************************
@Method Name    : getNDBEDPCase
@description    : verify NDBEDP case creation and validation
********************************************************
*/
    @IsTest
    public static void getNDBEDPCase(){
        try{
            Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
            List<Case> caseList = new List<Case>();
            Map<Id,Case> caseMap = new Map<Id,Case>();
            Test.startTest(); 
            Case casevalue = [SELECT Id,Status,RecordTypeId,Check_TRP_Reject__c,Check_Pending_Condition_Of_Acceptance__c FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
            
            casevalue.Check_TRP_Reject__c = true;
            casevalue.Check_Pending_Condition_Of_Acceptance__c = true;
            update caseValue;
            
            Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
            
            Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
            Request_Equipment__c requestEquipment = TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, casevalue.id, eqp.id);
            
            Id authWRId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
            Authorization__c auth = TestDataUtility.createAuthorization(true, authWRId);
            
            Id assetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Generic_Asset').getRecordTypeId();
            Asset__c asset = TestDataUtility.createAsset(true, assetTypeId, auth.Id, eqp.id, casevalue.Id);
            
            
            caseList.add(casevalue);
            caseMap.put(casevalue.Id,casevalue); 
            NC_CaseTriggerHandler.cancelMatRequest(caseList,caseMap);
            System.assertEquals(true,casevalue.Check_TRP_Reject__c);
            Test.stopTest();
        }
        Catch(Exception e){
        }
        
    }
    
    /*
*********************************************************
@Method Name    : validateRequiredFieldForCNDSSyncTest
@description    : verify required field for CNDS
********************************************************
*/
    @IsTest
    public static void validateRequiredFieldForCNDSSyncTest(){
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            List<Case> casevalue = [SELECT Id,RecordTypeId,Status FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
            caseValue[0].Status = 'Documents Review';
            update caseValue[0];  
            caseList.add(casevalue[0]);
            caseMap.put(casevalue[0].Id,casevalue[0]);
            NC_CaseTriggerHandler.cancelMatRequest(caseList,caseMap);
            System.assertEquals(null,casevalue[0].MatReqStatus__c);
            Test.stopTest();
        }
        Catch(Exception e){
        }
        
    }
    
    /*
*********************************************************
@Method Name    : checkFamilyDetailsFilledTest
@description    : verify family details records present or not
********************************************************
*/
    @IsTest
    public static void checkFamilyDetailsFilledTest(){
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            List<Case> casevalue = [SELECT Id,RecordTypeId,Status,ContactId FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
            
            Contact con = new Contact();
            con.Id = casevalue[0].ContactId;
            con.Proof_of_Income_Provided_By__c = 'Work First';
            update con;
            
            Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
            
            Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
            Request_Equipment__c requestEquipment = TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, casevalue[0].id, eqp.id);
            casevalue[0].Status = 'Pending Disability Determination';
            casevalue[0].Internal_Comments__c = 'test';
            update caseValue[0];  
            caseList.add(casevalue[0]);
            caseMap.put(casevalue[0].Id,casevalue[0]);
            NC_CaseTriggerHandler.checkFamilyDetailsFilled(caseList,caseMap);
            System.assertEquals(true, casevalue[0].Total_Family_Income__c!=null);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
    }
    
    /*
*********************************************************
@Method Name    : createAssetTest
@description    : verify asset and authorization creation
********************************************************
*/
    @IsTest
    public static void createAssetTest(){
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            List<Case> casevalue = [SELECT Id,RecordTypeId,Status,ContactId,Equipment_Types__c,Regional_Center__c,Vendor__c FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
            
            Contact con = new Contact();
            con.Id = casevalue[0].ContactId;
            con.Proof_of_Income_Provided_By__c = 'Work First';
            update con;
            
            Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
            
            Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
            Request_Equipment__c requestEquipment = TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, casevalue[0].id, eqp.id);
            
            caseList.add(casevalue[0]);
            caseMap.put(casevalue[0].Id,casevalue[0]);
            NC_CaseTriggerHandler.createAsset(caseMap);
            System.assertEquals(true, casevalue[0].AssetId!=null);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
    }
    
    /*
*********************************************************
@Method Name    : createAssetTest
@description    : verify asset and authorization creation with validation
********************************************************
*/
    @IsTest
    public static void createAssettTest(){
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            List<Case> casevalue = [SELECT Id,RecordTypeId,Status,ContactId,Equipment_Types__c,Regional_Center__c,Vendor__c FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
            
            Contact con = new Contact();
            con.Id = casevalue[0].ContactId;
            con.Proof_of_Income_Provided_By__c = 'Work First';
            update con;
            
            Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
            
            Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
            Request_Equipment__c requestEquipment = TestDataUtility.createRequestEquipment(false, requestEquipmentTypeId, casevalue[0].id, eqp.id);
            requestEquipment.Quantity__c = '1';
            insert requestEquipment;
            
            Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
            Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
            
            Id assetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Asset').getRecordTypeId();
            Asset__c asset = TestDataUtility.createAsset(false, assetTypeId, auth.id, eqp.id, casevalue[0].id);
            asset.Status__c = 'Available For Reassignment';
            insert asset;
            
            caseList.add(casevalue[0]);
            caseMap.put(casevalue[0].Id,casevalue[0]);
            NC_CaseTriggerHandler.createAsset(caseMap);
            System.assertEquals(true, casevalue[0].AssetId!=null);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPBudgetTest
@description    : verify ndbedp request budget validation
********************************************************
*/
    @IsTest
    public static void updateNDBEDPBudgetTest(){
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            List<Case> casevalue = [SELECT Id,RecordTypeId,Status,ContactId FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
            casevalue[0].Food__c  = 10;
            casevalue[0].Status = 'Pending Documents';
            casevalue[0].Check_Document_Review__c = true;
            casevalue[0].Approve_or_Reject__c = false;
            casevalue[0].Check_TRP_Reject__c = true;
            update casevalue[0];
            Contact con = new Contact();
            con.Id = casevalue[0].ContactId;
            con.Proof_of_Income_Provided_By__c = 'Work First';
            update con;
            
            Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
            
            Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
            Request_Equipment__c requestEquipment = TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, casevalue[0].id, eqp.id);
            
            //  caseList.add(casevalue[0]);
            caseMap.put(casevalue[0].Id,casevalue[0]);
            NC_CaseTriggerHandler.updateNDBEDPBudget(caseList,caseMap);
            System.assertEquals(true, casevalue[0].NDBEDP_Total_Cost__c!=null);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPBudgetTest2
@description    : verify ndbedp request budget update
********************************************************
*/
    @IsTest
    public static void updateNDBEDPBudgetTest2(){
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            List<Case> casevalue = [SELECT Id,RecordTypeId,Status,ContactId FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
            Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
            TestDataUtility.createBudgetAmount(true, budget.id, 100000);
            Contact con = new Contact();
            con.Id = casevalue[0].ContactId;
            con.Proof_of_Income_Provided_By__c = 'Work First';
            con.Race__c = 'White';
            update con;
            
            casevalue[0].Food__c  = 10;
            casevalue[0].Status = 'Pending Documents';
            casevalue[0].Check_Document_Review__c = true;
            update casevalue[0];
            caseMap.put(casevalue[0].Id,casevalue[0]);
            NC_CaseTriggerHandler.updateNDBEDPBudget(null,caseMap);
            System.assertEquals(true, casevalue[0].NDBEDP_Total_Cost__c!=null);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPBudgetTest2
@description    : verify sharing of authorization and request
********************************************************
*/
    @IsTest
    public static void shareAuthorizationsAndRequestTest(){
        Test.startTest();
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
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert userObj;
        }
        
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        List<Case> casevalue = [SELECT Id,RecordTypeId,Status,ContactId FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId, casevalue[0].id, null, casevalue[0].ContactId);
        auth.Trainer_Administrator_User__c = userObj.id;
        insert auth;
        
        NC_CaseTriggerHandler.shareAuthorizationsAndRequest(new List<Authorization__c>{auth});
        System.assertEquals(true,auth.Trainer_Administrator_User__c!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPBudgetTest2
@description    : verify sharing of ndbedp authorization
********************************************************
*/
    @IsTest
    public static void shareAuthorizationsTest(){
        Test.startTest();
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
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert userObj;
        }
        
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        List<Case> casevalue = [SELECT Id,RecordTypeId,Status,ContactId FROM Case WHERE RecordTypeId=:requestTypeId LIMIT 1];
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId, casevalue[0].id, null, casevalue[0].ContactId);
        auth.Internal_Assessor__c = userObj.id;
        insert auth;
        
        NC_CaseTriggerHandler.shareAuthorizations(new List<Authorization__c>{auth});
        System.assertEquals(false,auth.Trainer_Administrator_User__c!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPBudgetTest2
@description    : verify EDS request validations
********************************************************
*/
    @IsTest
    public static void validateEDSRquestStatusTest(){
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Id requestTypeIdDemo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
            Case caseValue = TestDataUtility.createCase(true, requestTypeIdDemo, con.id, 'EDS', 'Telephone');
            caseMap.put(caseValue.Id,caseValue); 
            caseValue.Status = 'Submitted';
            caseValue.Approve_or_Reject__c = false;
            caseValue.Submit_for_Approval__c = true;
            update caseValue;
            caseValue.Status = 'In Progress';
            update caseValue;
            caseValue.Status = 'Pending Documents';
            update caseValue;
            caseValue.Status = 'Pending Condition of Acceptance';
            update caseValue;
            caseValue.Status = 'Pending EDS Program Assistant';
            update caseValue;
            caseValue.Status = 'Appeal Pending';
            update caseValue;
            caseList.add(caseValue);
            
            NC_CaseTriggerHandler.validateEDSRquestStatus(caseList,caseMap);
            System.assertEquals(true, caseValue.Submit_for_Approval__c);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
        
    }
    
    
    
    /*
*********************************************************
@Method Name    : validateNdbedpServiceRequestTest
@description    : verify NDBEDP service request validations
********************************************************
*/
    @IsTest
    public static void validateNdbedpServiceRequestTest(){
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        Map<Id,Id> caseId = new Map<Id,Id>();
        try{
            Test.startTest(); 
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Id requestTypeIdDemo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
            Case caseValue = TestDataUtility.createCase(true, requestTypeIdDemo, con.id, 'EDS', 'Telephone');
            caseValue.Status = 'Submitted';
            caseValue.Approve_or_Reject__c = false;
            caseValue.Submit_for_Approval__c = true;
            caseValue.NDBEDP_FollowUp_Rejection__c = true;
            update caseValue;
            caseList.add(caseValue);
            caseMap.put(caseValue.Id,caseValue); 
            caseId.put(caseValue.Id,caseValue.Id);
            NC_CaseTriggerHandler.validateNdbedpServiceRequest(caseMap,caseId,true);
            System.assertEquals(true, caseValue.Approve_or_Reject__c);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
        
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessmentFormTest
@description    : verify Assessment form completion and email
********************************************************
*/
    @IsTest
    public static void sendEmailForAssessmentFormTest(){
        try{
            test.startTest();
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
            // cas.NDBEDP_Trainer__c = vendorAccount.Id;
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Status = 'Pending Assessment';
            cas.Assessor_Result__c = 'Accept';
            cas.Assessor_Invitation_Accepted_Date__c = Date.today();
            update cas;
            System.assertEquals('Test first', cas.External_Assessor__c);
            test.stopTest();
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPDemoRquestStatusTest
@description    : verify NDBEDP Demo request status validation
********************************************************
*/
    @IsTest
    public static void validateNDBEDPDemoRquestStatusTest(){
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Id requestTypeIdDemo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Demo').getRecordTypeId();
            Case caseValue = TestDataUtility.createCase(true, requestTypeIdDemo, con.id, 'EDS', 'Demo');
            caseValue.Approve_or_Reject__c = false;
            caseValue.Submit_for_Approval__c = true;
            update caseValue;
            caseValue.Status = 'Pending NDBEDP Coordinator';
            update caseValue;
            caseValue.Status = 'Pending TRC';
            update caseValue;
            caseList.add(caseValue);
            caseMap.put(caseValue.Id,caseValue); 
            NC_CaseTriggerHandler.validateNDBEDPDemoRquestStatus(caseList,caseMap);
            System.assertEquals(false, caseValue.Submit_for_Approval__c);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
        
    }
    
    /*
*********************************************************
@Method Name    : approveCaseRecordsTest
@description    : verify approval of case records
********************************************************
*/
    @IsTest
    public static void approveCaseRecordsTest(){
        List<Id> caseList = new List<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        try{
            Test.startTest(); 
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Id requestTypeIdDemo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Demo').getRecordTypeId();
            Case caseValue = TestDataUtility.createCase(true, requestTypeIdDemo, con.id, 'EDS', 'Demo');
            caseList.add(caseValue.Id);
            caseMap.put(caseValue.Id,caseValue);
            NC_CaseTriggerHandler.approveCaseRecords(caseList);
            System.assertEquals(false, (NC_CaseTriggerHandler.approveCaseRecords(caseList))!=null);
            Test.stopTest();
        }
        Catch(Exception e){
        } 
        
    }
    
    /*
*********************************************************
@Method Name    : createAuthorizationTest
@description    : verify creation of ndbedp authorizations
********************************************************
*/
    @IsTest
    public static void createAuthorizationTest(){
        List<Id> caseList = new List<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        
        Test.startTest(); 
        Id authorizationRecordId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Account acc = TestDataUtility.createAssessor(true);
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account vendor = TestDataUtility.createVendor(true);
        Account regionalCenter =  TestDataUtility.createRegionalCenter(true);
        Id requestTypeIdDemo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Demo').getRecordTypeId();
        Case caseValue = TestDataUtility.createCase(true, requestTypeIdDemo, con.id, 'EDS', 'Demo');
        Authorization__c result = NC_CaseTriggerHandler.createAuthorization(vendor.Id,con.Id,casevalue.Id,'Vendor Update In Progress',regionalCenter.Id,authorizationRecordId,true,'test');
        System.assertEquals(true, result!=null);
        Test.stopTest();     
    }
    
    /*
*********************************************************
@Method Name    : createAssetUtilsTest
@description    : verify creation of asset records related to authorizations
********************************************************
*/
    @IsTest
    public static void createAssetUtilsTest(){
        List<Id> caseList = new List<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        
        Test.startTest(); 
        Id assetRecordId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Account acc = TestDataUtility.createAssessor(true);
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account vendor = TestDataUtility.createVendor(true);
        Account regionalCenter =  TestDataUtility.createRegionalCenter(true);
        Id requestTypeIdDemo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Demo').getRecordTypeId();
        Case caseValue = TestDataUtility.createCase(true, requestTypeIdDemo, con.id, 'EDS', 'Demo');
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, equipmentTypeId, null, 'Test', 'Hearing Aid', 100);
        Asset__c result = NC_CaseTriggerHandler.createAssetUtils(eqp.Id,con.Id,casevalue.Id,assetRecordId,100,vendor.Id);
        System.assertEquals(true, result!=null);
        Test.stopTest();     
    }
    
    /*
*********************************************************
@Method Name    : createNoCostAuthorizationUtilsTest
@description    : verify creation of no cost authorizations
********************************************************
*/
    @IsTest
    public static void createNoCostAuthorizationUtilsTest(){
        List<Id> caseList = new List<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        
        Test.startTest(); 
        Id assetRecordId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Account acc = TestDataUtility.createAssessor(true);
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account vendor = TestDataUtility.createVendor(true);
        Account regionalCenter =  TestDataUtility.createRegionalCenter(true);
        Id requestTypeIdDemo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Demo').getRecordTypeId();
        Case caseValue = TestDataUtility.createCase(true, requestTypeIdDemo, con.id, 'EDS', 'Demo');
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, equipmentTypeId, null, 'Test', 'Hearing Aid', 100);
        Authorization__c result = NC_CaseTriggerHandler.createNoCostAuthorizationUtils(eqp.Id,vendor.Id,con.Id,caseValue.Id);
        System.assertEquals(true, result!=null);
        Test.stopTest();     
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptanceTest
@description    : verify external assessor acceptance email
********************************************************
*/
    @IsTest
    public static void sendEmailForAssessorAcceptanceTest(){
        try{
            Test.startTest(); 
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
            
            
            Contact con=new Contact();   
            con.LastName='Test Con';
            con.AccountId = acc.Id;
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.External_Assessor__c=acc.Id;
            update cas;
            System.assertEquals('NDBEDP', cas.Equipment_Types__c);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptanceInternalTest
@description    : verify internal assessor acceptance email
********************************************************
*/
    @IsTest
    public static void sendEmailForAssessorAcceptanceInternalTest(){
        test.startTest();   
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        insert userObj;
        
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Case cas= new Case();
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Internal_Assessor__c=userObj.Id;
            update cas;
            System.assertEquals(null, cas.Equipment_Types__c);
        }
        test.stopTest(); 
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptanceInternalTest
@description    : verify NDBEDP Trainer acceptance email
********************************************************
*/
    @IsTest
    public static void sendEmailForAssessorAcceptanceNDBEDPTrainingTest(){
        try{
            Test.startTest(); 
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
            
            
            Contact con=new Contact();   
            con.LastName='Test Con';
            con.AccountId = acc.Id;
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Additional_Training');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.NDBEDP_Trainer__c = acc.Id;
            update cas;
            System.assertEquals('NDBEDP', cas.Equipment_Types__c);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPAcceptTest
@description    : verify NDBEDP case assessor acceptance
********************************************************
*/
    @IsTest
    public static void sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPAcceptTest(){
        
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
        
        Test.startTest();
        Contact con=new Contact();   
        con.LastName='Test Con';
        
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        cas.Status = 'Pending Assessor';
        insert cas;
        
        cas.Assessor_Result__c ='Accept';
        update cas;
        System.assertEquals(false, cas.External_Assessor__c!=null);
        Test.stopTest(); 
        
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPRejectTest
@description    : verify NDBEDP case assessor reject
********************************************************
*/
    @IsTest
    public static void sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPRejectTest(){
        try{
            Test.startTest(); 
            Contact con=new Contact();   
            con.LastName='Test Con';
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Assessor_Result__c ='Reject';
            update cas;
            System.assertEquals(false, cas.External_Assessor__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPFOllowUpAcceptTest
@description    : verify NDBEDP Follow up assessor accept
********************************************************
*/
    @IsTest
    public static void sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPFOllowUpAcceptTest(){
        try{
            Test.startTest(); 
            Contact con=new Contact();   
            con.LastName='Test Con';
            
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Assessor_Result__c ='Accept';
            update cas;
            System.assertEquals(false, cas.Internal_Assessor__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPFollowUPRejectTest
@description    : verify NDBEDP Follow up assessor reject
********************************************************
*/
    @IsTest
    public static void sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPFollowUPRejectTest(){
        try{
            Test.startTest(); 
            Contact con=new Contact();   
            con.LastName='Test Con';
            
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Assessor_Result__c ='Reject';
            update cas;
            System.assertEquals(false, cas.Internal_Assessor__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPAdditionalAcceptTest
@description    : verify NDBEDP Additional Request assessor accept
********************************************************
*/
    @IsTest
    public static void sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPAdditionalAcceptTest(){
        try{
            Test.startTest(); 
            Contact con=new Contact();   
            con.LastName='Test Con';
            
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Additional_Training');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Assessor_Result__c ='Accept';
            update cas;
            System.assertEquals(false, cas.External_Assessor__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPAdditionalTrainingRejectTest
@description    : verify NDBEDP Additional Training Request assessor reject
********************************************************
*/
    @IsTest
    public static void sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPAdditionalTrainingRejectTest(){
        try{
            Test.startTest(); 
            Contact con=new Contact();   
            con.LastName='Test Con';
            
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Additional_Training');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Assessor_Result__c ='Reject';
            update cas;
            System.assertEquals(false, cas.External_Assessor__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPRepaireAcceptTest
@description    : verify NDBEDP Repair Request assessor accept
********************************************************
*/
    @IsTest
    public static void sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPRepaireAcceptTest(){
        try{
            Test.startTest(); 
            Contact con=new Contact();   
            con.LastName='Test Con';
            
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Assessor_Result__c ='Accept';
            update cas;
            System.assertEquals(false, cas.External_Assessor_User__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPRepairRejectTest
@description    : verify NDBEDP Repair Request assessor reject
********************************************************
*/
    @IsTest
    public static void sendEmailForInvitationForAssessorAfterAcceptanceNDBEDPRepairRejectTest(){
        try{
            Test.startTest(); 
            Contact con=new Contact();   
            con.LastName='Test Con';
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Assessor_Result__c ='Reject';
            update cas;
            System.assertEquals(false, cas.Internal_Assessor__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendNDBEDPEquipmentRequestTest
@description    : verify NDBEDP request sent to KLAS
********************************************************
*/
    @IsTest
    public static void sendNDBEDPEquipmentRequestTest(){
        try{
            Test.startTest(); 
            Contact con=new Contact();   
            con.LastName='Test Con';
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
            insert cas;
            
            cas.Send_to_KLAS__c =true;
            cas.Status = 'Approved';
            update cas;
            System.assertEquals(false, cas.External_Assessor__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : getAvailableForReassignmentAssetTest
@description    : verify NDBEDP request asset available for reassignment
********************************************************
*/
    @IsTest
    public static void getAvailableForReassignmentAssetTest(){
        Test.startTest();
        Map<Id, Map<Id, Integer>> assetToEqpMap = new Map<Id, Map<Id, Integer>> ();
        Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>();
        Map<Id, Integer> IntegerMap = new Map<Id, Integer>();
        Case cas= new Case();
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        insert cas;
        Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Request_Equipment__c requestEquipment = TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, cas.id, eqp.id);
        Id authWRId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authWRId);
        
        Id assetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Generic_Asset').getRecordTypeId();
        Asset__c asset = TestDataUtility.createAsset(true, assetTypeId, auth.Id, eqp.id, cas.Id);
        IntegerMap.put(asset.Id,3);
        assetToEqpMap.put(asset.Id,IntegerMap);
        assetMap.put(asset.Id,asset);
        Map<String, Object> result = NC_CaseTriggerHandler.getAvailableForReassignmentAsset(requestEquipment,assetToEqpMap,assetMap);
        System.assertEquals(true, result.size()>0);
        Test.stopTest(); 
        
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptanceInternalFollowUpTest
@description    : verify email for NDBEDP follow up request acceptance
********************************************************
*/
    @IsTest
    public static void sendEmailForAssessorAcceptanceInternalFollowUpTest(){
        test.startTest();   
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        insert userObj;
        
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Case cas= new Case();
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
            // cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Internal_Assessor__c=userObj.Id;
            System.assertEquals(false,cas.External_Assessor__c!=null);
            update cas;
            
        }
        test.stopTest(); 
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptanceInternalNDBEDPRepairTest
@description    : verify email for NDBEDP Repair up request acceptance
********************************************************
*/
    @IsTest
    public static void sendEmailForAssessorAcceptanceInternalNDBEDPRepairTest(){
        test.startTest();   
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        insert userObj;
        
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Case cas= new Case();
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.Internal_Assessor__c=userObj.Id;
            System.assertEquals(false,cas.External_Assessor__c!=null);
            update cas;
            
        }
        test.stopTest(); 
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptanceFollowUpTest
@description    : verify email for NDBEDP Follow up request acceptance
********************************************************
*/
    @IsTest
    public static void sendEmailForAssessorAcceptanceFollowUpTest(){
        try{
            Test.startTest(); 
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
            
            
            Contact con=new Contact();   
            con.LastName='Test Con';
            con.AccountId = acc.Id;
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
            // cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.External_Assessor__c=acc.Id;
            System.assertEquals(false,cas.Internal_Assessor__c!=null);
            update cas;
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptanceRepaireRequestTest
@description    : verify email for NDBEDP Repair request acceptance
********************************************************
*/
    @IsTest
    public static void sendEmailForAssessorAcceptanceRepaireRequestTest(){
        try{
            Test.startTest(); 
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
            
            
            Contact con=new Contact();   
            con.LastName='Test Con';
            con.AccountId = acc.Id;
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
            cas.Status = 'Pending Assessor';
            insert cas;
            
            cas.External_Assessor__c=acc.Id;
            update cas;
            System.assertEquals(false,cas.Internal_Assessor__c!=null);
            Test.stopTest(); 
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : createAssessorAuthorizationTest
@description    : verify creation of Assessor Authorization
********************************************************
*/
    @IsTest
    public static void createAssessorAuthorizationTest(){
        Test.startTest();  
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
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        cas.Status = 'Pending Assessor';
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        insert cas;
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();   
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        auth.Request__c = cas.Id;
        update auth;
        
        cas.Status = 'Pending Assessment';
        update cas;
        System.assertEquals(false,cas.Internal_Assessor__c!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : createNDBEDPFollowAuthorizationTest
@description    : verify creation of NDBEDP Follow up Authorization
********************************************************
*/
    @IsTest
    public static void createNDBEDPFollowAuthorizationTest(){
        Test.startTest();  
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
        
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        // cas.Status = 'Pending Assessor';
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        insert cas;
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Follow_Up').getRecordTypeId();   
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        auth.Request__c = cas.Id;
        update auth;
        
        cas.Status = 'Assessor scheduled';
        update cas;
        System.assertEquals(false, cas.Internal_Assessor__c!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : createNDBEDPAdditionalTrainingAuthorizationTest
@description    : verify creation of NDBEDP Training Authorization
********************************************************
*/
    @IsTest
    public static void createNDBEDPAdditionalTrainingAuthorizationTest(){
        Test.startTest();  
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
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Additional_Training');
        // cas.Status = 'Pending Assessor';
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        insert cas;
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Additional_Training').getRecordTypeId();   
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        auth.Request__c = cas.Id;
        update auth;
        
        cas.Status = 'Trainer scheduled';
        update cas;
        System.assertEquals(null, auth.Cancelled_Comment__c);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : createAssessorTraingingInstallationAuthorizationTest
@description    : verify creation of Assessor Training and Installation Authorization
********************************************************
*/
    @IsTest
    public static void createAssessorTraingingInstallationAuthorizationTest(){
        try{
            Test.startTest();  
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
            
            Contact con=new Contact();   
            con.LastName='Testing Con';
            con.AccountId = acc.Id;
            insert con;
            
            Case cas= new Case();
            cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
            // cas.Status = 'Pending Assessor';
            cas.External_Assessor__c = acc.Id;
            cas.Assessor_Result__c = 'Accept';
            insert cas;
            
            Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessor_Training_Installation').getRecordTypeId();   
            Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
            auth.Request__c = cas.Id;
            update auth;
            
            cas.Status = 'Pending Equipment Order';
            update cas;
            System.assertEquals(null, auth.Cancelled_Comment__c);
            Test.stopTest();
        }
        Catch(Exception e){
        }
    }
    
    /*
*********************************************************
@Method Name    : createNDBEDPPickupAuthorizationTest
@description    : verify creation of NDBEDP Pick up Authorization
********************************************************
*/
    @IsTest
    public static void createNDBEDPPickupAuthorizationTest(){
        Test.startTest();  
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
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        insert cas;
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Pick_up').getRecordTypeId();   
        Authorization__c auth = TestDataUtility.createAuthorization(false, authAssessmentId);
        auth.Request__c = cas.Id;
        Insert auth;
        
        cas.Status = 'Pick-up is scheduled';
        update cas;
        System.assertEquals(null, auth.City__c);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : createNDBEDPDeliveyAuthorizationTest
@description    : verify creation of NDBEDP Delivery Authorization
********************************************************
*/
    @IsTest
    public static void createNDBEDPDeliveyAuthorizationTest(){
        Test.startTest();  
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
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        // cas.Status = 'Pending Assessor';
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        insert cas;
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Delivey').getRecordTypeId();   
        Authorization__c auth = TestDataUtility.createAuthorization(false, authAssessmentId);
        // auth.au
        auth.Request__c = cas.Id;
        Insert auth;
        
        cas.Status = 'Delivered to Consumer';
        update cas;
        System.assertEquals(false, auth.Is_Individual__c);
        Test.stopTest();
    }  
    
    /*
*********************************************************
@Method Name    : validateNdbedpServiceRequestTesting
@description    : verify creation of NDBEDP Service request validation
********************************************************
*/
    @IsTest
    public static void validateNdbedpServiceRequestTesting(){
        test.startTest();
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Map<Id,Id> caseAssessorMap = new Map<Id,Id>();
            Map<Id, Case> caseMap = new Map<Id, Case> ();
            Case cas= new Case();
            // cas.ContactId=con.Id;
            cas.Email_address__c= 'test@gmail.com';
            cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
            insert cas;
            caseAssessorMap.put(cas.Id,UserInfo.getUserId());
            caseMap.put(cas.Id,cas);
            NC_CaseTriggerHandler.validateNdbedpServiceRequest(caseMap,caseAssessorMap,false);
            System.assertEquals(false,(NC_CaseTriggerHandler.validateNdbedpServiceRequest(caseMap,caseAssessorMap,false))!=null);
        }
        test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPRepairRequestTest1
@description    : verify creation of NDBEDP Repair Request validations
********************************************************
*/
    @IsTest
    public static void validateNDBEDPRepairRequestTest1(){
        test.startTest();
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
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        cas.Status = 'Pick-up is scheduled';
        insert cas;
        cas.Status = 'Shipped to Repair Center';
        update cas;
        system.assertEquals(true, cas.Internal_Assessor__c==null);
        test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPRepairRequestTest2
@description    : verify creation of NDBEDP Repair Request status validations
********************************************************
*/
    @IsTest
    public static void validateNDBEDPRepairRequestTest2(){
        test.startTest();
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
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        cas.Status = 'Shipped to Repair Center';
        insert cas;
        cas.Status = 'Received from Repair Center';
        update cas;
        system.assertEquals(false, cas.Internal_Assessor__c!=null);
        test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPRepairRequestTest3
@description    : verify creation of NDBEDP Repair Request status validations
********************************************************
*/
    @IsTest
    public static void validateNDBEDPRepairRequestTest3(){
        test.startTest();
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
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        cas.Status = 'Received from Repair Center';
        insert cas;
        cas.Status = 'Delivered to Consumer';
        update cas;
        system.assertEquals(false, cas.Internal_Assessor__c!=null);
        test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPRepairRequestTest4
@description    : verify creation of NDBEDP Repair Request status validations
********************************************************
*/
    @IsTest
    public static void validateNDBEDPRepairRequestTest4(){
        test.startTest();
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
        
        Contact con=new Contact();   
        con.LastName='Testing Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        cas.External_Assessor__c = acc.Id;
        cas.Assessor_Result__c = 'Accept';
        cas.Status = 'Delivered to Consumer';
        insert cas;
        cas.Status = 'Closed';
        cas.Consumer_Acknowledgment_Date__c = Date.today();
        cas.Assessor_Notes__c = 'test';
        cas.Service_Documentation__c = true;
        update cas;
        system.assertEquals(false, cas.Internal_Assessor__c!=null);
        test.stopTest();
    }
    
}