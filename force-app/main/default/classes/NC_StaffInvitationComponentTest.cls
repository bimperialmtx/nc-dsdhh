/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@isTest
public class NC_StaffInvitationComponentTest {
    /*
*********************************************************
@Method Name    : fetchUserListTest
@description    : Verify users available for sending an invitation for staffing request
********************************************************
*/
    static testmethod void fetchUserListTest() {
        Account rc = TestDataUtility.createRegionalCenter(true);
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
        insert vendor;
        
        Id commTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c car = TestDataUtility.createCommunicationAcessRequest(true, commTypeId, 'Interpreters', rc.id);
        
        Id staffReqTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffReqTypeId, car.id, '1');
        Map<String, Object> resultMap = NC_StaffInvitationComponentController.fetchUserList(staffReq.id, 'All', 'All', 'All', 'All');
        System.assertNotEquals(null, resultMap.get('result'));
        
        Id staffReqTypeId2 = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staff').getRecordTypeId();
        Staffing_Request__c staffReq2 = TestDataUtility.createStaffingRequest(false, staffReqTypeId2, car.id, '1');
        staffReq2.Number_of_Interpreters_Needed__c = '1';
        insert staffReq2;
        Map<String, Object> resultMap2 = NC_StaffInvitationComponentController.fetchUserList(staffReq2.id, 'All', 'All', 'All', 'All');
        Staffing_Request__c res=[SELECT Id,Hours__c FROM Staffing_Request__c LIMIT 1];
        System.assertEquals(null, res.Hours__c);
    }
    
    /*
*********************************************************
@Method Name    : sendEmailInviationTest
@description    : Verify sending invitations to the selected user or account
********************************************************
*/
    static testmethod void sendEmailInviationTest() {
        Account rc = TestDataUtility.createRegionalCenter(true);
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
        insert vendor;
        
        Id commTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c car = TestDataUtility.createCommunicationAcessRequest(true, commTypeId, 'Interpreters', rc.id);
        
        Id staffReqTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffReqTypeId, car.id, '1');
        
        NC_StaffInvitationComponentController.UsersWrapper wrap = new NC_StaffInvitationComponentController.UsersWrapper();
        wrap.isSelected = true;
        wrap.numberOfMembersProving = 1;
        wrap.vendorType = 'Interpreters';
        wrap.userId = vendor.Id;
        
        Map<String, Object> resultMap = NC_StaffInvitationComponentController.sendEmailInviation(JSON.serialize(new List<NC_StaffInvitationComponentController.UsersWrapper>{wrap}), staffReq.id);
        System.assertNotEquals(null, resultMap.get('success'));
        
        Id staffReqTypeId2 = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staff').getRecordTypeId();
        Staffing_Request__c staffReq2 = TestDataUtility.createStaffingRequest(false, staffReqTypeId2, car.id, '1');
        staffReq2.Number_of_Interpreters_Needed__c = '1';
        insert staffReq2;
        NC_StaffInvitationComponentController.UsersWrapper wrap2 = new NC_StaffInvitationComponentController.UsersWrapper();
        wrap2.isSelected = true;
        wrap2.numberOfMembersProving = 1;
        wrap2.vendorType = 'Interpreters';
        wrap2.emailId = 'test@gmail.com';
        wrap2.userId = null;
        
        Map<String, Object> resultMap2 = NC_StaffInvitationComponentController.sendEmailInviation(JSON.serialize(new List<NC_StaffInvitationComponentController.UsersWrapper>{wrap2}), staffReq2.id);
        Staffing_Request__c res=[SELECT Id,Hours__c FROM Staffing_Request__c LIMIT 1];
        System.assertEquals(null, res.Hours__c);    }
    
    /*
*********************************************************
@Method Name    : sendEmailInviationTrainerTest
@description    : Verify sending invitations to the selected trainer
********************************************************
*/
    static testmethod void sendEmailInviationTrainerTest() {
        Account trainer = TestDataUtility.createNDBEDPTrainer(false);
        trainer.Is_Vendor_on_Portal__c = true;
        insert trainer;
        
        Id commTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Request_For_Training_Vendor').getRecordTypeId();
        Communication_Access_Request__c car = TestDataUtility.createCommunicationAcessRequest(true, commTypeId, 'NDBEDP Training', null);
        
        Id staffReqTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffReqTypeId, car.id, '1');
        
        NC_StaffInvitationComponentController.UsersWrapper wrap = new NC_StaffInvitationComponentController.UsersWrapper();
        wrap.isSelected = true;
        wrap.numberOfMembersProving = 1;
        wrap.vendorType = 'NDBEDP Training';
        wrap.userId = trainer.Id;
        
        Map<String, Object> resultMap = NC_StaffInvitationComponentController.sendEmailInviation(JSON.serialize(new List<NC_StaffInvitationComponentController.UsersWrapper>{wrap}), staffReq.id);
        Staffing_Request__c res=[SELECT Id,Hours__c FROM Staffing_Request__c LIMIT 1];
        System.assertEquals(null, res.Hours__c);
        System.assertEquals(true, resultMap.size()>0);
    }
    
    /*
*********************************************************
@Method Name    : fetchCountRegionalCenterTest
@description    : Verify available regional centers
********************************************************
*/
    static testmethod void fetchCountRegionalCenterTest() {
        Account rc = TestDataUtility.createRegionalCenter(true);
        Id commTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c car = TestDataUtility.createCommunicationAcessRequest(true, commTypeId, 'Interpreters', rc.id);
        
        Id staffReqTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffReqTypeId, car.id, '1');
        
        Map<String, Object> resultMap = NC_StaffInvitationComponentController.fetchCountRegionalCenter(staffReq.id);
        System.assertNotEquals(null, resultMap.get('countyOptionList'));
    }
}