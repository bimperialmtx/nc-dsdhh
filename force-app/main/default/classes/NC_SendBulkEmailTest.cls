/**
* @description       : Test class for NC_SendBulkEmail
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_SendBulkEmailTest {

    /*
    *********************************************************
    @Method Name    : createData
    @description    : Create data to be tested in this class
    ********************************************************
    */
    @TestSetup
    public static void createData(){
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Email__c = 'test@gmail.com';
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        vendor.Preferred_Method_of_Contact__c = NC_Constant.EMAIL_PPREFERRED_CONTACT;
        insert vendor;
        
        Contact con = TestDataUtility.createConsumer(true);
    }
    
    /*
    *********************************************************
    @Method Name    : sendEmailHearingAidTest
    @description    : Verify consumer and vendor email notification for hearing aid EDS request
    ********************************************************
    */
    static testmethod void sendEmailHearingAidTest() {
        Account vendor = [SELECT Email__c, Status__c, Active__c FROM Account WHERE Email__c = 'test@gmail.com'];
        Contact con = [SELECT id, email FROM Contact LIMIT 1];
        
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(false, equipmentTypeId, null, 'test', 'Hearing Aid', 100);
        eqp.IsActive__c = true;
        insert eqp;
        
        Id equipmentRequestId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case edsRequest = TestDataUtility.createCase(true, equipmentRequestId, con.id, 'EDS', 'Hearing Aid');
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, edsRequest.id, eqp.id);
        
        Id edsAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, edsAuthTypeId, edsRequest.Id, vendor.Id, con.id);
        auth.Contains_Hearing_Aid__c = true;
        auth.Ship_To__c = 'Not Applicable';
        insert auth;
        
        Id genericAssetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Hearing_Aid_Asset').getRecordTypeId();
        TestDataUtility.createAsset(true, genericAssetTypeId, auth.Id, eqp.Id, edsRequest.Id);
        
        Test.startTest();
        NC_SendBulkEmail.sendEmail(new Set<Id>{auth.id});
        
        con.Preferred_Contact_Method__c = 'TTY';
        con.TTY__c = '1234567890';
        update con;
        NC_SendBulkEmail.createRequestLetter(new Set<Id>{auth.id});
        Test.stopTest();
        System.assertNotEquals(0, Limits.getLimitEmailInvocations());
    }
    
    /*
    *********************************************************
    @Method Name    : sendEmailNonHearingAidTest
    @description    : Verify consumer and vendor email notification for non hearing aid EDS request
    ********************************************************
    */
    static testmethod void sendEmailNonHearingAidTest() {
        Account vendor = [SELECT Email__c, Status__c, Active__c FROM Account WHERE Email__c = 'test@gmail.com'];
        Contact con = [SELECT id, email FROM Contact LIMIT 1];
        
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, equipmentTypeId, vendor.id, 'Test', 'Weather Radio', 100);
        
        Id caseEquipmentTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case request = TestDataUtility.createCase(true, caseEquipmentTypeId, con.id, 'EDS', 'Weather Radio');
        
        Id authWRId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authWRId, request.Id, vendor.Id, con.id);
        auth.Ship_To__c = 'Not Applicable';
        insert auth;
        
        Id assetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Generic_Asset').getRecordTypeId();
        Asset__c asset = TestDataUtility.createAsset(true, assetTypeId, auth.Id, eqp.id, request.Id);
        
        Test.startTest();
        NC_SendBulkEmail.sendEmail(new Set<Id>{auth.id});
        NC_SendBulkEmail.sendEmailForExternalAuthorization(new Set<Id>{auth.id});
        con.Preferred_Contact_Method__c = 'TTY';
        con.TTY__c = '1234567890';
        update con;
        NC_SendBulkEmail.createRequestLetter(new Set<Id>{auth.id});
        Test.stopTest();
        System.assertNotEquals(0, Limits.getLimitEmailInvocations());
    }
    
    /*
    *********************************************************
    @Method Name    : sendEmailOnRequestDenialTest
    @description    : Verify consumer and vendor email notification for denial of EDS request
    ********************************************************
    */
    static testmethod void sendEmailOnRequestDenialTest() {
        Account vendor = [SELECT Email__c, Status__c, Active__c FROM Account WHERE Email__c = 'test@gmail.com'];
        Contact con = [SELECT id, email FROM Contact LIMIT 1];
        
        Id caseEquipmentTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case request = TestDataUtility.createCase(true, caseEquipmentTypeId, con.id, 'EDS', 'Weather Radio');
        NC_SendBulkEmail.sendEmailOnRequestDenial(new Map<Id, Id>{request.id => con.id});
        System.assertNotEquals(0, Limits.getLimitEmailInvocations());
    }
    
    /*
    *********************************************************
    @Method Name    : sendEmailOnRequestDenialTest
    @description    : Verify sending emails to group
    ********************************************************
    */
    static testmethod void semdEmailToGroupsTest() {
        Group grp = TestDataUtility.createGroup(true, 'testGrp', 'Regular');
        GroupMember grpMember = TestDataUtility.createGroupMember(true, UserInfo.getUserId(), grp.Id);
        
        Map<String,Set<Id>> inputMap = new Map<String,Set<Id>>();
        inputMap.put('testGrp', new Set<Id>{grp.id});
        NC_SendBulkEmail.semdEmailToGroups(inputMap, 'Email_To_Assessor_When_Invoice_Rejected');
        System.assertNotEquals(0, Limits.getLimitEmailInvocations());
    }
    
    /*
    *********************************************************
    @Method Name    : sendEmailToUserTest
    @description    : Verify sending emails to user
    ********************************************************
    */
    static testmethod void sendEmailToUserTest() {
        Contact con = [SELECT id, email FROM Contact LIMIT 1];
        Map<Id,Set<Id>> inputMap = new Map<Id,Set<Id>>();
        inputMap.put(UserInfo.getUserId(), new Set<Id>{con.id});
        NC_SendBulkEmail.sendEmailToUser(inputMap, 'Email_To_Assessor_When_Invoice_Rejected');
        System.assertNotEquals(0, Limits.getLimitEmailInvocations());
    }
    
    /*
    *********************************************************
    @Method Name    : notifieBudgetManagerOnBudgetLowTest
    @description    : Verify email for low budget
    ********************************************************
    */
    static testmethod void notifieBudgetManagerOnBudgetLowTest() {
        NC_BudgetManagementController.budgetNotifier wrap = new NC_BudgetManagementController.budgetNotifier();
        wrap.UserId = UserInfo.getUserId();
        wrap.budgetMessage = 'test';
        wrap.budgetURL = 'test';
        NC_SendBulkEmail.notifieBudgetManagerOnBudgetLow(new List<NC_BudgetManagementController.budgetNotifier>{wrap});
        System.assertNotEquals(0, Limits.getLimitEmailInvocations());
    }
    
    /*
    *********************************************************
    @Method Name    : notifieResourceLoanOwnerTest
    @description    : Verify email for resource loan owner
    ********************************************************
    */
    static testmethod void notifieResourceLoanOwnerTest() {
        Map<Id, String> inputMap = new Map<Id, String>{UserInfo.getUserId() => 'test'};
        NC_SendBulkEmail.notifieResourceLoanOwner(inputMap);
        System.assertNotEquals(0, Limits.getLimitEmailInvocations());
    }
    
    /*
    *********************************************************
    @Method Name    : notifieOwnerForDifferentRegionalCenterTest
    @description    : Verify email for regional centers
    ********************************************************
    */
    static testmethod void notifieOwnerForDifferentRegionalCenterTest() {
        Account vendor = [SELECT Email__c, Status__c, Active__c FROM Account WHERE Email__c = 'test@gmail.com'];
        Contact con = [SELECT id, email FROM Contact LIMIT 1];
        
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(false, equipmentTypeId, null, 'test', 'Hearing Aid', 100);
        eqp.IsActive__c = true;
        insert eqp;
        
        Id equipmentRequestId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case edsRequest = TestDataUtility.createCase(true, equipmentRequestId, con.id, 'EDS', 'Hearing Aid');
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, edsRequest.id, eqp.id);
        
        Id edsAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, edsAuthTypeId, edsRequest.Id, vendor.Id, con.id);
        auth.Contains_Hearing_Aid__c = true;
        auth.Ship_To__c = 'Not Applicable';
        insert auth;
        
        Id genericAssetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Hearing_Aid_Asset').getRecordTypeId();
        Asset__c asset = TestDataUtility.createAsset(true, genericAssetTypeId, auth.Id, eqp.Id, edsRequest.Id);
        asset.Request__r = edsRequest;
        asset.Request__r.OwnerId = UserInfo.getUserId();
        
        Map<Id,Case> assetCaseMap = new Map<Id,Case>{asset.id => edsRequest};
        NC_SendBulkEmail.notifieOwnerForDifferentRegionalCenter(assetCaseMap, new List<Asset__c>{asset});
        System.assertNotEquals(0, Limits.getLimitEmailInvocations());
    }
}