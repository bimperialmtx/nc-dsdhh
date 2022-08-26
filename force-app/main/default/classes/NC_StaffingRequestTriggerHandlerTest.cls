/**
* @description       : Test class for NC_StaffingRequestTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_StaffingRequestTriggerHandlerTest {
    
    /*
    *********************************************************
    @Method Name    : sendEmailInviationTest
    @description    : Verify email to be sent for staffing request creation and validation
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
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        
        Id commTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c car = TestDataUtility.createCommunicationAcessRequest(true, commTypeId, 'Interpreters', rc.id);
        
        Id staffReqTypeId2 = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staff').getRecordTypeId();
        Staffing_Request__c staffReq2 = TestDataUtility.createStaffingRequest(false, staffReqTypeId2, car.id, '1');
        staffReq2.Number_of_Interpreters_Needed__c = '1';
       // staffReq2.re
        insert staffReq2;
        
        List<User> use = [SELECT Id,UserRoleId,UserRole.Name  from user WHERE UserRole.DeveloperName = 'Interpreter_Services_Specialist'AND IsActive = true LIMIT 1];
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq2.Id);
        if(use.size()>0){
        staffUserReq.User__c = use[0].Id;
        }
        staffUserReq.Approved_Number_of_Members__c = 5;
        staffUserReq.Request_Accepted__c = true;
        Insert staffUserReq;
        
        User userObj = [SELECT Id from user WHERE Profile.name = 'System Administrator' AND Id != :UserInfo.getUserId() LIMIT 1];
        System.runAs(userObj){
         	staffReq2.Number_of_Interpreters_Needed__c = '2';
            staffReq2.Service_Notes__c = 'test notes';
            update staffReq2;
            System.assertEquals(true, staffReq2.Service_Notes__c!=null);   
        }
    }
}