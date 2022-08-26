/**
* @description       : Test class for NC_Create_Invoice_and_InvoiceLine
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_Create_Invoice_and_InvoiceLineTest {
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_EDS_HA_Test
    @description    : Verify hearing aid invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_EDS_HA_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
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
        Asset__c asset = TestDataUtility.createAsset(false, genericAssetTypeId, auth.Id, eqp.Id, edsRequest.Id);
        asset.Status__c = 'Equipment Working';
        insert asset;
        
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_NDBEDP_Test
    @description    : Verify NDBEDP Assessment invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_NDBEDP_Test() {
        Account assessor = TestDataUtility.createAssessor(true);
        Contact con = TestDataUtility.createConsumer(true);
        
        Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
        Case request = TestDataUtility.createNDBEDPCase(true, con.id);
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, request.id, eqp.id);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, assessmentAuthTypeId, request.Id, null, con.id);
        auth.External_Assessor__c = assessor.id;
        insert auth;
        
        Id ndbedpAssetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Asset').getRecordTypeId();
        TestDataUtility.createAsset(true, ndbedpAssetTypeId, auth.Id, eqp.Id, request.Id);
        
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_TrainingVendor_Test
    @description    : Verify Training Vendor invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_TrainingVendor_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        vendor.License_Type__c = 'Full License';
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Request_For_Training_Vendor').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Training Vendor', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId, null, vendor.Id, con.id);
        auth.Communication_Access_Request__c = commReq.id;
        auth.Staffing_User_Request__c = staffUserReq.id;
        insert auth;
        
        //Cancel Auth
        Staffing_User_Request__c staffUserReq2 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        Authorization__c auth2 = TestDataUtility.createAuthorization(false, authTypeId, null, vendor.Id, con.id);
        auth2.Communication_Access_Request__c = commReq.id;
        auth2.Staffing_User_Request__c = staffUserReq2.id;
        auth2.Status__c = 'Cancelled';
        auth2.Cancelled_Reason__c = 'Cancelled due to Weather';
        insert auth2;
        
        //Cancel Auth
        Staffing_User_Request__c staffUserReq3 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        Authorization__c auth3 = TestDataUtility.createAuthorization(false, authTypeId, null, vendor.Id, con.id);
        auth3.Communication_Access_Request__c = commReq.id;
        auth3.Staffing_User_Request__c = staffUserReq2.id;
        auth3.Status__c = 'Cancelled';
        auth3.Cancelled_Reason__c = 'Cancelled within 24 hrs';
        insert auth3;
        
        //Cancel Auth
        Staffing_User_Request__c staffUserReq4 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        Authorization__c auth4 = TestDataUtility.createAuthorization(false, authTypeId, null, vendor.Id, con.id);
        auth4.Communication_Access_Request__c = commReq.id;
        auth4.Staffing_User_Request__c = staffUserReq2.id;
        auth4.Status__c = 'Cancelled';
        auth4.Cancelled_Reason__c = 'Cannot Perform Training';
        insert auth4;
        
        test.startTest();
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
        Map<String, Object> resultMap2 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth2.id);
        System.assertEquals('Success', resultMap2.get('result'));
        Map<String, Object> resultMap3 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth3.id);
        System.assertEquals('Success', resultMap3.get('result'));
        Map<String, Object> resultMap4 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth4.id);
        System.assertEquals('Success', resultMap4.get('result'));
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_TrainingVendor_Test
    @description    : Verify Communication Access Request Interpreter invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_Interpreter_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        vendor.License_Type__c = 'Full License';
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Interpreters', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        //In State
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        Id carAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth.Communication_Access_Request__c = commReq.id;
        auth.Staffing_User_Request__c = staffUserReq.id;
        insert auth;
        
        //Out State
        Staffing_User_Request__c staffUserReq2 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq2.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq2;
        Authorization__c auth2 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth2.Communication_Access_Request__c = commReq.id;
        auth2.Staffing_User_Request__c = staffUserReq2.id;
        insert auth2;
        
        //In State cancel
        Staffing_User_Request__c staffUserReq3 = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        Authorization__c auth3 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth3.Communication_Access_Request__c = commReq.id;
        auth3.Staffing_User_Request__c = staffUserReq3.id;
        auth3.Status__c = 'Cancelled';
        auth3.Cancelled_Reason__c = 'Assignment Cancelled (In route/Arrived)';
        insert auth3;
        
        //Out State cancel
        Staffing_User_Request__c staffUserReq4 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq4.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq4;
        Authorization__c auth4 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth4.Communication_Access_Request__c = commReq.id;
        auth4.Staffing_User_Request__c = staffUserReq4.id;
        auth4.Status__c = 'Cancelled';
        auth4.Cancelled_Reason__c = 'Assignment Cancelled (In route/Arrived)';
        insert auth4;
        
        test.startTest();
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
        Map<String, Object> resultMap2 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth2.id);
        System.assertEquals('Success', resultMap2.get('result'));
        Map<String, Object> resultMap3 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth3.id);
        System.assertEquals('Success', resultMap3.get('result'));
        Map<String, Object> resultMap4 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth4.id);
        System.assertEquals('Success', resultMap4.get('result'));
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_CAR_Interpreter_Cancel_Test
    @description    : Verify Communication Access Request Interpreter cancelled invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_Interpreter_Cancel_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        vendor.License_Type__c = 'Full License';
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Interpreters', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Id carAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        
        //In State cancel
        Staffing_User_Request__c staffUserReq3 = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        Authorization__c auth3 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth3.Communication_Access_Request__c = commReq.id;
        auth3.Staffing_User_Request__c = staffUserReq3.id;
        auth3.Status__c = 'Cancelled';
        auth3.Cancelled_Reason__c = 'Cancelled due to Weather';
        insert auth3;
        
        //Out State cancel
        Staffing_User_Request__c staffUserReq4 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq4.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq4;
        Authorization__c auth4 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth4.Communication_Access_Request__c = commReq.id;
        auth4.Staffing_User_Request__c = staffUserReq4.id;
        auth4.Status__c = 'Cancelled';
        auth4.Cancelled_Reason__c = 'Cancelled due to Weather';
        insert auth4;
        
        //In State cancel
        Staffing_User_Request__c staffUserReq5 = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        Authorization__c auth5 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth5.Communication_Access_Request__c = commReq.id;
        auth5.Staffing_User_Request__c = staffUserReq5.id;
        auth5.Status__c = 'Cancelled';
        auth5.Cancelled_Reason__c = 'Cancelled within 24 hrs';
        insert auth5;
        
        //Out State cancel
        Staffing_User_Request__c staffUserReq6 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq6.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq6;
        Authorization__c auth6 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth6.Communication_Access_Request__c = commReq.id;
        auth6.Staffing_User_Request__c = staffUserReq6.id;
        auth6.Status__c = 'Cancelled';
        auth6.Cancelled_Reason__c = 'Cancelled within 24 hrs';
        insert auth6;
        
        test.startTest();
        Map<String, Object> resultMap3 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth3.id);
        System.assertEquals('Success', resultMap3.get('result'));
        Map<String, Object> resultMap4 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth4.id);
        System.assertEquals('Success', resultMap4.get('result'));
        Map<String, Object> resultMap5 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth5.id);
        System.assertEquals('Success', resultMap5.get('result'));
        Map<String, Object> resultMap6 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth6.id);
        System.assertEquals('Success', resultMap6.get('result'));
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_CAR_Cart_Test
    @description    : Verify Communication Access Request cart invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_Cart_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Cart', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        //In State
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        
        Id carAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth.Communication_Access_Request__c = commReq.id;
        auth.Staffing_User_Request__c = staffUserReq.id;
        insert auth;
        
        //Out State
        Staffing_User_Request__c staffUserReq2 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq2.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq2;
        
        Authorization__c auth2 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth2.Communication_Access_Request__c = commReq.id;
        auth2.Staffing_User_Request__c = staffUserReq2.id;
        insert auth2;
        
        test.startTest();
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
        Map<String, Object> resultMap2 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth2.id);
        System.assertEquals('Success', resultMap2.get('result'));
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_CAR_Cart_Test
    @description    : Verify Communication Access Request ssp invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_Ssp_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'SSP', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        //In State
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        Id carAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth.Communication_Access_Request__c = commReq.id;
        auth.Staffing_User_Request__c = staffUserReq.id;
        insert auth;
        
        //Out State
        Staffing_User_Request__c staffUserReq2 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq2.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq2;
        Authorization__c auth2 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth2.Communication_Access_Request__c = commReq.id;
        auth2.Staffing_User_Request__c = staffUserReq2.id;
        insert auth2;
        
        test.startTest();
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
        Map<String, Object> resultMap2 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth2.id);
        System.assertEquals('Success', resultMap2.get('result'));
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_CAR_Cart_Test
    @description    : Verify Communication Access Request ssp cancelled invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_Ssp_Cancel_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'SSP', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Id carAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        
        //In State cancel
        Staffing_User_Request__c staffUserReq3 = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        Authorization__c auth3 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth3.Communication_Access_Request__c = commReq.id;
        auth3.Staffing_User_Request__c = staffUserReq3.id;
        auth3.Status__c = 'Cancelled';
        auth3.Cancelled_Reason__c = 'Cancelled due to Weather';
        insert auth3;
        
        //Out State cancel
        Staffing_User_Request__c staffUserReq4 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq4.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq4;
        Authorization__c auth4 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth4.Communication_Access_Request__c = commReq.id;
        auth4.Staffing_User_Request__c = staffUserReq4.id;
        auth4.Status__c = 'Cancelled';
        auth4.Cancelled_Reason__c = 'Cancelled due to Weather';
        insert auth4;
        
        //In State cancel
        Staffing_User_Request__c staffUserReq5 = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        Authorization__c auth5 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth5.Communication_Access_Request__c = commReq.id;
        auth5.Staffing_User_Request__c = staffUserReq5.id;
        auth5.Status__c = 'Cancelled';
        auth5.Cancelled_Reason__c = 'Cancelled within 24 hrs';
        insert auth5;
        
        //Out State cancel
        Staffing_User_Request__c staffUserReq6 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq6.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq6;
        Authorization__c auth6 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth6.Communication_Access_Request__c = commReq.id;
        auth6.Staffing_User_Request__c = staffUserReq6.id;
        auth6.Status__c = 'Cancelled';
        auth6.Cancelled_Reason__c = 'Cancelled within 24 hrs';
        insert auth6;
        
        test.startTest();
        Map<String, Object> resultMap3 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth3.id);
        System.assertEquals('Success', resultMap3.get('result'));
        Map<String, Object> resultMap4 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth4.id);
        System.assertEquals('Success', resultMap4.get('result'));
        Map<String, Object> resultMap5 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth5.id);
        System.assertEquals('Success', resultMap5.get('result'));
        Map<String, Object> resultMap6 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth6.id);
        System.assertEquals('Success', resultMap6.get('result'));
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_CAR_NDBEDP_Interpreter_Test
    @description    : Verify NDBEDP Communication Access Request interpreter invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_NDBEDP_Interpreter_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        vendor.License_Type__c = 'Full License';
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Communication_Access_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'NDBEDP Interpreters', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        //In State
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        
        Id carAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth.Communication_Access_Request__c = commReq.id;
        auth.Staffing_User_Request__c = staffUserReq.id;
        insert auth;
        
        //Out State
        Staffing_User_Request__c staffUserReq2 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq2.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq2;
        
        Authorization__c auth2 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth2.Communication_Access_Request__c = commReq.id;
        auth2.Staffing_User_Request__c = staffUserReq2.id;
        insert auth2;
        
        test.startTest();
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
        Map<String, Object> resultMap2 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth2.id);
        System.assertEquals('Success', resultMap2.get('result'));
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_CAR_NDBEDP_Cart_Test
    @description    : Verify NDBEDP Communication Access Request cart invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_NDBEDP_Cart_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Communication_Access_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'NDBEDP Cart', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        //In State
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        
        Id carAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth.Communication_Access_Request__c = commReq.id;
        auth.Staffing_User_Request__c = staffUserReq.id;
        insert auth;
        
        //Out State
        Staffing_User_Request__c staffUserReq2 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq2.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq2;
        
        Authorization__c auth2 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth2.Communication_Access_Request__c = commReq.id;
        auth2.Staffing_User_Request__c = staffUserReq2.id;
        insert auth2;
        
        test.startTest();
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
        Map<String, Object> resultMap2 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth2.id);
        System.assertEquals('Success', resultMap2.get('result'));
        
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth2.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Map<String, Object> resultMap3 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth2.id);
        test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem_CAR_NDBEDP_Ssp_Test
    @description    : Verify NDBEDP Communication Access Request ssp invoice line items creation from Authorization
    ********************************************************
    */
    static testmethod void createInvoiceAndInvoiceLineItem_CAR_NDBEDP_Ssp_Test() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Communication_Access_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'NDBEDP SSP', rc.id);
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        //In State
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        
        Id carAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth.Communication_Access_Request__c = commReq.id;
        auth.Staffing_User_Request__c = staffUserReq.id;
        insert auth;
        
        //Out State
        Staffing_User_Request__c staffUserReq2 = TestDataUtility.createStaffingUserRequest(false, staffUserRequestTypeId, staffReq.Id);
        staffUserReq2.Amount_Authorization_Type__c = 'Out State';
        insert staffUserReq2;
        
        Authorization__c auth2 = TestDataUtility.createAuthorization(false, carAuthTypeId, null, vendor.Id, con.id);
        auth2.Communication_Access_Request__c = commReq.id;
        auth2.Staffing_User_Request__c = staffUserReq2.id;
        insert auth2;
        
        test.startTest();
        Map<String, Object> resultMap = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth.id);
        System.assertEquals('Success', resultMap.get('result'));
        Map<String, Object> resultMap2 = NC_Create_Invoice_and_InvoiceLineItem.createInvoiceAndInvoiceLineItem(auth2.id);
        System.assertEquals('Success', resultMap2.get('result'));
        test.stopTest();
    }
}