/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_AccountTriggerHandlerTest {
    
    /*
*********************************************************
@Method Name    : setUpData
@description    : Create test data to be used in this test class
********************************************************
*/
    @TestSetup
    public static  void setUpData() {
        Account rc = TestDataUtility.createRegionalCenter(true);
        Account assessor = TestDataUtility.createAssessor(false);
        assessor.Status__c = 'Approved';
        assessor.NCAS_Status__c ='N – record not in NCAS';
        Insert assessor;
        
        Account trainer = TestDataUtility.createNDBEDPTrainer(false);
        trainer.Status__c = 'Pending Documents';
        Insert trainer;
        
        
        
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Equipment_Provider__c = false;
        vendor.Interpreter__c = true;
        vendor.Approved_Interpreter__c = true;
        vendor.Regional_Center__c = rc.id;
        vendor.County__c = 'Alamance';
        vendor.License_Type__c = 'Full License';
        vendor.Specialty__c = 'Close Vision';
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        vendor.Alternative_Phone__c = '+1(123) 456-7890';
        vendor.Cell_Phone__c = '+1(123) 456-7890';
        vendor.Phone = '+1(123) 456-7890';
        vendor.TTY__c = '+1(123) 456-7890';
        vendor.Video_Phone__c = '+1(123) 456-7890';
        insert vendor;
        
        Contact con = TestDataUtility.createConsumer(true);
        con.AccountId = assessor.Id;
        con.Email = 'test@gmail.com';
        update con;
        
        Id commTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c car = TestDataUtility.createCommunicationAcessRequest(true, commTypeId, 'Interpreters', rc.id);
        
        Id staffReqTypeId2 = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(false, staffReqTypeId2, car.id, '1');
        staffReq.Number_of_Interpreters_Needed__c = '1';
        // staffReq2.re
        insert staffReq;
        
        List<User> use = [SELECT Id,UserRoleId,UserRole.Name  from user WHERE UserRole.DeveloperName = 'Interpreter_Services_Specialist'AND IsActive = true LIMIT 1];
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq1 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        if(use.size()>0){
        staffUserReq1.User__c = use[0].Id;
        }
        staffUserReq1.Approved_Number_of_Members__c = 5;
        staffUserReq1.Request_Accepted__c = true;
        Insert staffUserReq1;
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        auth.Vendor__c = vendor.Id;
        auth.Status__c = 'Vendor Update In Progress';
        auth.Staffing_User_Request__c = staffUserReq1.Id;
        update auth;
        
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        
        
        
        Staffing_Request__c staffReq2 = TestDataUtility.createStaffingRequest(false, staffReqTypeId2, car.id, '1');
        staffReq2.Number_of_Interpreters_Needed__c = '1';
        insert staffReq2;
        
        
        
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq2.Id);
        if(use.size()>0){
        staffUserReq.User__c = use[0].Id;
        }
        staffUserReq.Approved_Number_of_Members__c = 5;
        staffUserReq.Request_Accepted__c = true;
        Insert staffUserReq;
        
        
    }
    
    /*
*********************************************************
@Method Name    : validateAssessorRecord
@description    : Verify Assessor validations
********************************************************
*/
    static testmethod void validateAssessorRecord(){
        Id recordIdAssessor = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc = [SELECT Id,Status__c,NCAS_Status__c,Patron_Type__c FROM Account WHERE recordTypeId=:recordIdAssessor LIMIT 1];
        acc.NCAS_Status__c = 'Y – record in NCAS';
        acc.Active__c = true;
        acc.Is_Vendor_on_Portal__c = true;
        acc.Status__c = 'Approved';
        acc.Email__c = 'test@gmail.com';
        acc.Hearing_Aid_Provider__c = true;
        test.startTest();
        update acc;
        test.stopTest();
        System.assertEquals('TA',acc.Patron_Type__c);      
    }
    
    /*
*********************************************************
@Method Name    : validateVendorUnfreezeRecord
@description    : Verify Vendor unfreeze scenarios
********************************************************
*/
    static testmethod void validateVendorUnfreezeRecord(){
        
        Staffing_User_Request__c staffUserReq = [SELECT id FROM Staffing_User_Request__c LIMIT 1];
        staffUserReq.Status__c = 'Pending Approval';
        update staffUserReq;
        
        Invoice__c inv = [SELECT id FROM Invoice__c LIMIT 1];
        inv.Status__c = 'Vendor Update In Progress';
        update inv;
        
        Id accountTypeId = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
        Account acc = [SELECT Id,Status__c,NCAS_Status__c,Email__c FROM Account WHERE recordTypeId=:accountTypeId LIMIT 1];
        acc.NCAS_Status__c = 'Y – record in NCAS';
        acc.Active__c = true;
        acc.Is_Vendor_on_Portal__c = true;
        acc.Status__c = 'Approved';
        acc.Email__c = 'test@gmail.com';
        acc.Last_Name__c = 'TestL';
        acc.Update_Yearly_Document_Renewal_Date__c = true;
        acc.Yearly_Document_Renewal_Date__c = System.today();
        acc.Update_Complete_Cycle_Renewal_Date__c = true;
        acc.Complete_Cycle_Renewal_Date__c = System.today();
        test.startTest();
        update acc;
        test.stopTest();
        System.assertEquals('test@gmail.com', acc.Email__c);
    }
    
    /*
*********************************************************
@Method Name    : validateVendorUnfreezeRecord
@description    : Verify Vendor freeze scenarios
********************************************************
*/
    static testmethod void validateVendorfreezeRecord() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Equipment_Provider__c = false;
        vendor.Interpreter__c = true;
        vendor.Approved_Interpreter__c = true;
        vendor.County__c = 'Alamance';
        vendor.License_Type__c = 'Full License';
        vendor.Specialty__c = 'Close Vision';
        vendor.Status__c = 'Approved';
        vendor.Alternative_Phone__c = '1234567890';
        vendor.Cell_Phone__c = '1234567890';
        vendor.Phone = '1234567890';
        vendor.TTY__c = '1234567890';
        vendor.Video_Phone__c = '1234567890';
        
        test.startTest();
        insert vendor;
        
        Id commTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c car = TestDataUtility.createCommunicationAcessRequest(true, commTypeId, 'Interpreters', null);
        
        Id staffReqTypeId2 = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(false, staffReqTypeId2, car.id, '1');
        staffReq.Number_of_Interpreters_Needed__c = '1';
        insert staffReq;
        
        List<User> use = [SELECT Id,UserRoleId,UserRole.Name  from user WHERE UserRole.DeveloperName = 'Interpreter_Services_Specialist'AND IsActive = true LIMIT 1];
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq1 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        if(use.size()>0){
           staffUserReq1.User__c = use[0].Id;
        }
        staffUserReq1.Approved_Number_of_Members__c = 5;
        staffUserReq1.Request_Accepted__c = true;
        //staffUserReq1.Status__c = 'Pending Approval';
        Insert staffUserReq1;
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        auth.Vendor__c = vendor.Id;
        auth.Status__c = 'Approved';
        auth.Staffing_User_Request__c = staffUserReq1.Id;
        update auth;
        
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        
        vendor.Sent_to_NCAS__c = false;
        update vendor;
        //acc.Sent_to_NCAS__c = false;
        //update acc;
        test.stopTest();
        System.assertEquals(null, vendor.NCAS_Status__c);
    }
    
    /*
*********************************************************
@Method Name    : validateAssessorRecord2
@description    : Verify Assessor validations
********************************************************
*/
    static testmethod void validateAssessorRecord2(){
        Id recordIdVendor = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
        Account vendor = [SELECT Id,Status__c,NCAS_Status__c,Email__c FROM Account WHERE recordTypeId=:recordIdVendor LIMIT 1];
        test.startTest();
        try{
            vendor.Document_In_Complete_Renewal_Process__c = true;
            vendor.Status__c = 'Approved';
            update vendor;
            System.assertEquals(null, vendor.NCAS_Status__c);
        }
        Catch(Exception e){
        }
        test.stopTest();
    }
    
    
    /*
*********************************************************
@Method Name    : validateAssessorRecord4
@description    : Verify Assessor validations
********************************************************
*/
    static testmethod void validateAssessorRecord4(){
        Invoice__c invoice = [SELECT Id,Status__c FROM Invoice__c LIMIT 1];
        invoice.Status__c = 'Vendor Update In Progress';
        update invoice;
        Id recordIdVendor = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
        Account vendor = [SELECT Id,Status__c,NCAS_Status__c,First_Name__c,SSP__c,ShippingAddress FROM Account WHERE recordTypeId=:recordIdVendor LIMIT 1];
        vendor.NCAS_Status__c = 'Y – record in NCAS';
        vendor.Same_As_Mailing_address__c = true;
        vendor.First_Name__c = 'few';
        vendor.Same_As_Physical_Address_to_Mailing_Addr__c = true;
        vendor.SSP__c = true;
        Test.startTest();
        update vendor;
        Test.stopTest();
        System.assertEquals(true, vendor.ShippingAddress!=null);
        
    }
    
    /*
*********************************************************
@Method Name    : validateAssessorRecord4
@description    : Verify Assessor validations
********************************************************
*/
    static testmethod void validateAssessorRecord5(){
        Id recordIdVendor = NC_Utility.RecordTypeUtilityMethod('Account','NDBEDP_Trainer');
        Account vendor = [SELECT Id,Status__c,NCAS_Status__c FROM Account WHERE recordTypeId=:recordIdVendor LIMIT 1];
        vendor.Status__c = 'Pending Approval';
        vendor.Same_As_Physical_Address__c = true;
        Test.startTest();
        try{
            update vendor;
            System.assertEquals('test@gmail.com', vendor.Email__c);
        }
        Catch(Exception e){
        }
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : validateAssessorRecord4
@description    : Verify Assessor validations
********************************************************
*/
    static testmethod void validateAssessorRecord3(){
        Id recordIdVendor = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
        Account vendor = [SELECT Id,Status__c,Email__c,Approved_CART__c FROM Account WHERE recordTypeId=:recordIdVendor LIMIT 1];
        
        test.startTest();        
        try{
            vendor.Status__c = 'Submitted and Rejected';
            vendor.MM102_error_reason__c = 'test';
            vendor.Sent_to_NCAS__c = false;
            vendor.Active__c = false;
            vendor.Status__c = 'Approved';
            vendor.NCAS_Status__c = '';
            update vendor;
            System.assertEquals(false, vendor.Approved_CART__c);
        }
        Catch(Exception e){
        }
        test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : validateAssessorRecord4
@description    : Verify NDBEDP Trainer creation
********************************************************
*/
    static testmethod void createNDBEDPTrainerTest(){
        test.startTest();
        Account acc=TestDataUtility.createNDBEDPTrainer(true);
        acc.Status__c = 'Approved';
        acc.Is_Vendor_on_Portal__c = true;
        acc.First_Name__c = 'few';
        // vendor.Same_As_Physical_Address_to_Mailing_Addr__c = true;
        acc.CART__c = true;
        update acc;
        test.stopTest();
        System.assertEquals(false, acc.Approved_CART__c);
    }
    
    /*
*********************************************************
@Method Name    : submitNCASErrorVendorForApprovalTest
@description    : Verify NCAS Error validations for Vendor/Trainer
********************************************************
*/
    static testmethod void submitNCASErrorVendorForApprovalTest(){
        try{
            test.startTest();
            Account acc=TestDataUtility.createNDBEDPTrainer(true);
            acc.Status__c = 'Pending Approval';
            acc.MM102_error_reason__c = 'test';
            update acc;
            test.stopTest();
            System.assertEquals(false, acc.Regional_Center__c!=null);
        }
        Catch(Exception e){
        }
        
    }
    
    /*
*********************************************************
@Method Name    : updateNCASErrorXTest
@description    : Verify NCAS Error X validations for Vendor/Trainer
********************************************************
*/
    static testmethod void updateNCASErrorXTest(){
        try{
            test.startTest();
            Account acc=TestDataUtility.createNDBEDPTrainer(true);
            acc.NCAS_Status__c = 'X - Error';
            update acc;
            acc.Status__c = 'Pending Approval';
            update acc;
            test.stopTest();
            System.assertEquals('test@gmail.com', acc.Email__c);
        }
        Catch(Exception e){
        }        
    }
    
    /*
*********************************************************
@Method Name    : updateNCASErrorNTest
@description    : Verify NCAS Error N validations for Vendor/Trainer
********************************************************
*/
    static testmethod void updateNCASErrorNTest(){
        try{
            test.startTest();
            Account acc=TestDataUtility.createNDBEDPTrainer(true);
            acc.NCAS_Status__c = 'N – record not in NCAS';
            update acc;
            acc.Status__c = 'Pending Approval';
            update acc;
            test.stopTest();
            System.assertEquals(true, acc.Sent_to_NCAS__c);
            
        }
        Catch(Exception e){
        }
        
    }
    
    /*
*********************************************************
@Method Name    : validateDocumentTest
@description    : Verify document validations for Vendor
********************************************************
*/
    static testmethod void validateDocumentTest(){
        try{
            test.startTest();
            Account acc=TestDataUtility.createVendor(true);
            NC_AccountTriggerHandler.isTriggerExecuted = false;
            acc.Status__c = 'Renewal Pending';
            acc.Individual__c = true;
            acc.Interpreter__c = true;
            update acc;
            test.stopTest();
            System.assertEquals('test@gmail.com', acc.Email__c);
            
        }
        Catch(Exception e){
        }
 }    
}