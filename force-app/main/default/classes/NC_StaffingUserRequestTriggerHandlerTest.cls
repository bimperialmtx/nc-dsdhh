/**
* @description       : Test class for NC_StaffingUserRequestTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@ISTEST
public class NC_StaffingUserRequestTriggerHandlerTest {
    
    /*
    *********************************************************
    @Method Name    : sendEmailInviationTest
    @description    : Verify email to be sent for staffing user request creation and validation
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
        
        Id staffReqTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffReqTypeId, car.id, '1');
        
        staffReq.Number_of_Vendors_Needed__c = '3';
        update staffReq;
        
        Id ExternalRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c',NC_Constant.STAFFING_USER_REQUEST_EXTERNAL);
        Staffing_User_Request__c staff = new Staffing_User_Request__c();
        staff.RecordTypeId = ExternalRecordTypeId;
        staff.Account__c = vendor.Id;
        staff.Staffing_Request__c = staffReq.Id;
        staff.Booked_Time_Same_As_Service_Time__c = true;
        Insert staff;
        
        staff.Status__c = 'Vendor Approved';
        staff.Parking__c = 10;
        staff.Booked_Time_Same_As_Service_Time__c = true;
        update staff;
        
        for(Invoice_line_item_for__mdt invoiceLineItem: [SELECT Id, MasterLabel,Sequence__c, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt]) {
            NC_StaffingUserRequestTriggerHandler.getQuantityAndAmountOutState(staff,invoiceLineItem);
        }
        staff.Enhanced_Hours__c = 1;     
        staff.Status__c = 'Pending Vendor Approval';
        update staff;
        
        staff.Status__c = 'Vendor Approved';
        staff.Approved_Number_of_Members__c= 1;
        staff.Number_of_Members_Providing__c = 5;
        
        update staff;
        
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        try{
            test.startTest();
            insert userObj;
            test.stopTest();
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        
        Case request = TestDataUtility.createNDBEDPCase(true);
        
        Authorization__c auth2 = TestDataUtility.createAuthorization(false, authAssessmentId);
        auth2.Trainer_Administrator_User__c = [SELECT id FROM User WHERE profile.name = 'System Administrator' AND Id != :UserInfo.getUserId() LIMIT 1].id;
        auth2.Request__c = request.id;
        Insert auth2;
        
        List<Authorization__c> authList = new List<Authorization__c>();
        authList.add(auth2);
        NC_StaffingUserRequestTriggerHandler.shareAuthorizations(authList);
        
        car.RecordTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Communication_Access_Request').getRecordTypeId();
        car.Vendor_Type__c = 'NDBEDP SSP';
        update car;
        NC_StaffingUserRequestTriggerHandler.createAuthorizationRecord(new List<Staffing_User_Request__c>{staff});
        
        List<Authorization__Share> authShareList = [SELECT parentId FROM Authorization__Share WHERE parentId =: auth2.id];
        System.assertNotEquals(0, authShareList.size());
    }
    
    /*
    *********************************************************
    @Method Name    : validateStaffingUserRequestTest
    @description    : Verify internal staffing user request validations
    ********************************************************
    */
    static testmethod void validateStaffingUserRequestTest() {
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c car = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Interpreters', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(false, staffRequestTypeId, car.id, '1');
        staffReq.Number_of_Interpreters_Needed__c = '1';
        insert staffReq;
        
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c userReq = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.id);
        userReq.Number_of_Members_Providing__c = 1;
        userReq.Approved_Number_of_Members__c = 1;
        userReq.User__c = UserInfo.getUserId();
        userReq.Regional_Center__c = rc.id;
        userReq.Email__c = 'test@gmail.com';
        insert userReq;
        
        userReq.Amount_Authorization_Type__c = 'In State';
        userReq.Breakfast__c = 100;
        userReq.Dinner__c = 1;
        userReq.Excess_Hotel_Cost__c = 1;
        userReq.Hotels__c = 1;
        userReq.Lunch__c = 1;
        userReq.Parking__c = 1;
        userReq.Mileage__c = 1;
        update userReq;
        
        userReq.Amount_Authorization_Type__c = 'Out State';
        userReq.Trainer_Administrator_User__c = [SELECT id FROM User WHERE profile.name = 'System Administrator' AND Id != :UserInfo.getUserId() LIMIT 1].id;
        update userReq;
        
        NC_StaffingUserRequestTriggerHandler.shareStaffingRequests(new List<Staffing_User_Request__c>{userReq}, new Map<String, String>{userReq.id => userReq.Staffing_Request__c});
        List<Staffing_Request__Share> staffShareList = [SELECT parentId FROM Staffing_Request__Share WHERE parentId =: staffReq.id];
        System.assertNotEquals(0, staffShareList.size());
    }
}