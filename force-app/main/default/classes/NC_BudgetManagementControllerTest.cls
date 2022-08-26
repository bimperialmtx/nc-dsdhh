/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@ISTest
public class NC_BudgetManagementControllerTest {
    
    /*
*********************************************************
@Method Name    : getAllLineItemsTest
@description    : Verify hearing aid authorization cost and budget
********************************************************
*/
    static testmethod void getAllLineItemsTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        Set<Id> authList = new Set<Id>();
        authList.add(auth.Id);
        
        NC_BudgetManagementController.validateBudgetAmount(authList);
        System.assertEquals(false, (NC_BudgetManagementController.validateBudgetAmount(authList))!=null);
    }
    
    /*
*********************************************************
@Method Name    : getAllLineItemsTest1
@description    : Verify Assessment authorization cost and budget
********************************************************
*/
    static testmethod void getAllLineItemsTest1() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        Set<Id> authList = new Set<Id>();
        authList.add(auth.Id);
        NC_BudgetManagementController.validateBudgetAmount(authList);
        System.assertEquals(false, (NC_BudgetManagementController.validateBudgetAmount(authList))!=null);
    }
    
    /*
*********************************************************
@Method Name    : hearingAidRecordTypeTest
@description    : Verify hearing aid authorization budget
********************************************************
*/
    static testmethod void hearingAidRecordTypeTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        Insert auth;
        Set<Id> authList = new Set<Id>();
        authList.add(auth.Id);
        
        NC_BudgetManagementController.updateBudgetAmount(authList);
        System.assertEquals(false,(NC_BudgetManagementController.updateBudgetAmount(authList))!=null);
    }
    
    /*
*********************************************************
@Method Name    : weatherRadioRecordTypeTest
@description    : Verify weather radio authorization budget
********************************************************
*/
    static testmethod void weatherRadioRecordTypeTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Weather Radio Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        Insert auth;
        Set<Id> authList = new Set<Id>();
        authList.add(auth.Id);
        
        NC_BudgetManagementController.updateBudgetAmount(authList);  
        Authorization__c auth1 = [SELECT Id,Update_If_Vendor_Inactive__c FROM Authorization__c WHERE Id =: auth.Id];
        System.assertEquals(false, auth1.Update_If_Vendor_Inactive__c);
    }
    
    /*
*********************************************************
@Method Name    : capitalBudgetRecordTypeTest
@description    : Verify captel authorization budget
********************************************************
*/
    static testmethod void capitalBudgetRecordTypeTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'CAPTEL Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        Insert auth;
        Set<Id> authList = new Set<Id>();
        authList.add(auth.Id);
        
        NC_BudgetManagementController.updateBudgetAmount(authList);
        Authorization__c auth1 = [SELECT Id,Update_If_Vendor_Inactive__c FROM Authorization__c WHERE Id =: auth.Id];
        System.assertEquals(false, auth1.Update_If_Vendor_Inactive__c);
    }
    
    /*
*********************************************************
@Method Name    : otherBudgetRecordTypeTest
@description    : Verify NDBEDP authorization budget
********************************************************
*/
    static testmethod void otherBudgetRecordTypeTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        Insert auth;
        Set<Id> authList = new Set<Id>();
        authList.add(auth.Id);
        
        NC_BudgetManagementController.updateBudgetAmount(authList);    
        Authorization__c auth1 = [SELECT Id,Status__c FROM Authorization__c WHERE Id =: auth.Id];
        System.assertEquals('Approved', auth1.Status__c);
    }
    
    /*
*********************************************************
@Method Name    : cancelAuthorizationToUpdateBudgetTest
@description    : Verify canceled hearing aid authorization budget
********************************************************
*/
    static testmethod void cancelAuthorizationToUpdateBudgetTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        Insert auth;
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId FROM Authorization__c WHERE RecordTypeId=:hearingAidRecordType];
        List<Authorization__c> authList = new List<Authorization__c>();
        authList.add(auth2);
        
        NC_BudgetManagementController.cancelAuthorizationToUpdateBudget(authList);    
        Authorization__c authorization = [SELECT Id,Amount_Authorization_Type__c FROM Authorization__c WHERE Id =: auth2.Id];
        System.assertEquals(null, authorization.Amount_Authorization_Type__c);
    }
    
    /*
*********************************************************
@Method Name    : validateBudgetForAuthorizationForStaffingTest
@description    : Verify communication access request authorization budget
********************************************************
*/
    static testmethod void validateBudgetForAuthorizationForStaffingTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Interpreters Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Interpreters', rc.id);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        auth.Communication_Access_Request__c = commReq.Id;
        Insert auth;
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c  FROM Authorization__c WHERE RecordTypeId=:hearingAidRecordType];
        List<Authorization__c> authList = new List<Authorization__c>();
        authList.add(auth2);
        
        NC_BudgetManagementController.validateBudgetForAuthorizationForStaffing(authList);  
        Authorization__c authorization = [SELECT Id,Status__c FROM Authorization__c WHERE Id =: auth2.Id];
        System.assertEquals('Approved', authorization.Status__c);
    }
    
    /*
*********************************************************
@Method Name    : updateAuthorizationBudgetStaffingTest
@description    : Verify communication access request ssp authorization budget
********************************************************
*/
    static testmethod void updateAuthorizationBudgetStaffingTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'SSP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        // auth.Communication_Access_Request__c = commReq.Id;
        Insert auth;
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:hearingAidRecordType];
        List<Authorization__c> authList = new List<Authorization__c>();
        authList.add(auth2);
        
        NC_BudgetManagementController.updateAuthorizationBudgetStaffing(authList);
        Authorization__c authorization = [SELECT Id,Budget_Management__c FROM Authorization__c WHERE Id =: auth2.Id];
        System.assertEquals(false, authorization.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAuthorizationBudgetStaffingTest1
@description    : Verify communication access request interpreters authorization budget
********************************************************
*/
    static testmethod void updateAuthorizationBudgetStaffingTest1() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Interpreters Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Interpreters', rc.id);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        auth.Communication_Access_Request__c = commReq.Id;
        // auth.Vendor_Type__c = 'Interpreters';
        Insert auth;
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:hearingAidRecordType];
        List<Authorization__c> authList = new List<Authorization__c>();
        authList.add(auth);
        
        NC_BudgetManagementController.updateAuthorizationBudgetStaffing(authList);  
        Authorization__c authorization = [SELECT Id,Status__c FROM Authorization__c WHERE Id =: auth.Id];
        System.assertEquals('Approved', authorization.Status__c);
    }
    
    /*
*********************************************************
@Method Name    : updateAuthorizationBudgetStaffingTest2
@description    : Verify communication access request staffing authorization budget
********************************************************
*/
    static testmethod void updateAuthorizationBudgetStaffingTest2() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'SSP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'SSP', rc.id);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        auth.Communication_Access_Request__c = commReq.Id;
        //  auth.Vendor_Type__c = 'SSP';
        Insert auth;
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:hearingAidRecordType];
        List<Authorization__c> authList = new List<Authorization__c>();
        authList.add(auth2);
        
        NC_BudgetManagementController.updateAuthorizationBudgetStaffing(authList);  
        Authorization__c authorization = [SELECT Id,Budget_Management__c FROM Authorization__c WHERE Id =: auth2.Id];
        System.assertEquals(true, authorization.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAuthorizationBudgetStaffingTest3
@description    : Verify communication access request cart authorization budget
********************************************************
*/
    static testmethod void updateAuthorizationBudgetStaffingTest3() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'CART Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'CART', rc.id);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        auth.Communication_Access_Request__c = commReq.Id;
        // auth.Vendor_Type__c = 'CART';
        Insert auth;
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:hearingAidRecordType];
        List<Authorization__c> authList = new List<Authorization__c>();
        authList.add(auth2);
        
        NC_BudgetManagementController.updateAuthorizationBudgetStaffing(authList); 
        Authorization__c authorization = [SELECT Id,Total_Authorized_Amount_Staffing__c FROM Authorization__c WHERE Id =: auth2.Id];
        System.assertEquals(0.0, authorization.Total_Authorized_Amount_Staffing__c);
    }
    
    /*
*********************************************************
@Method Name    : updateAuthorizationBudgetStaffingTest4
@description    : Verify communication access request training vendor authorization budget
********************************************************
*/
    static testmethod void updateAuthorizationBudgetStaffingTest4() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Training Vendor Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Request_For_Training_Vendor').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Training Vendor', rc.id);
        
        Id hearingAidRecordType = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, hearingAidRecordType);
        auth.Status__c = 'Approved';
        auth.Communication_Access_Request__c = commReq.Id;
        // auth.Vendor_Type__c = 'CART';
        Insert auth;
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:hearingAidRecordType];
        List<Authorization__c> authList = new List<Authorization__c>();
        authList.add(auth2);
        
        NC_BudgetManagementController.updateAuthorizationBudgetStaffing(authList); 
        Authorization__c authorization = [SELECT Id,Total_Authorized_Amount_Staffing__c FROM Authorization__c WHERE Id =: auth2.Id];
        System.assertEquals(0.00, authorization.Total_Authorized_Amount_Staffing__c);
    }
    
    
    /*
*********************************************************
@Method Name    : validateBudgetForInvoiceTest
@description    : Verify NDBEDP invoice budget
********************************************************
*/
    static testmethod void validateBudgetForInvoiceTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.validateBudgetForInvoice(invoiceList,invoiceMap);
        Invoice__c inv = [SELECT Id,Payment_Date__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Payment_Date__c!=null);
        // TestDataUtility.createInvoiceLineItem(true, invoice.id);
    }
    
    /*
*********************************************************
@Method Name    : validateBudgetForInvoiceForStaffingTest
@description    : Verify NDBEDP ssp invoice budget
********************************************************
*/
    static testmethod void validateBudgetForInvoiceForStaffingTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'SSP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.validateBudgetForInvoiceForStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Status__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals('Hold', inv.Status__c);
        // TestDataUtility.createInvoiceLineItem(true, invoice.id);
    }
    
    /*
*********************************************************
@Method Name    : validateBudgetForInvoiceForStaffingTest
@description    : Verify NDBEDP interpreter invoice budget
********************************************************
*/
    static testmethod void updteBudgetFormNDBEDPInvoiceTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Interpreters Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        invoice.Vendor_Type__c = 'Interpreters';
        insert invoice;
        
        Set<Id> invoiceList = new Set<Id>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice.Id);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFormIntInvoiceTest
@description    : Verify interpreter invoice budget
********************************************************
*/
    static testmethod void updteBudgetFormIntInvoiceTest() { 
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'Interpreters Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'Interpreters Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Vendor_Type__c = 'Interpreters';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice2.Status__c = 'Created';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Vendor_Type__c = 'Interpreters';
        insert invoice2;
        
        Set<Id> invoiceList = new Set<Id>{invoice.Id, invoice2.Id};
            NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFormIntInvoiceTest
@description    : Verify communication access request ssp invoice budget
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceStaffingTest1() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'SSP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        invoice.Vendor_Type__c = 'SSP';
        insert invoice;
        
        Set<Id> invoiceList = new Set<Id>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice.Id);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFormSSPInvoiceTest
@description    : Verify communication access request ssp invoice budget which is going to be paid next year
********************************************************
*/
    static testmethod void updteBudgetFormSSPInvoiceTest() { 
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'SSP Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'SSP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Vendor_Type__c = 'SSP';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice2.Status__c = 'Created';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Vendor_Type__c = 'SSP';
        insert invoice2;
        
        Set<Id> invoiceList = new Set<Id>{invoice.Id, invoice2.Id};
            NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__c==null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceStaffingTest2
@description    : Verify communication access request cart invoice budget
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceStaffingTest2() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'CART Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        invoice.Vendor_Type__c = 'CART';
        insert invoice;
        
        Set<Id> invoiceList = new Set<Id>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice.Id);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__c==null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFormCARTInvoiceTest
@description    : Verify communication access request cart invoice budget which is going to be paid next year
********************************************************
*/
    static testmethod void updteBudgetFormCARTInvoiceTest() { 
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'CART Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'CART Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Vendor_Type__c = 'CART';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice2.Status__c = 'Created';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Vendor_Type__c = 'CART';
        insert invoice2;
        
        Set<Id> invoiceList = new Set<Id>{invoice.Id, invoice2.Id};
            NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Status__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals('Created', inv.Status__c);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFormCARTInvoiceTest
@description    : Verify training vendor invoice budget
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceStaffingTest3() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Training Vendor Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        invoice.Vendor_Type__c = 'Training Vendor';
        insert invoice;
        
        Set<Id> invoiceList = new Set<Id>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice.Id);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__c==null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFormTrainVendorInvoiceTest
@description    : Verify training vendor invoice budget which is going to be paid nxt year
********************************************************
*/
    static testmethod void updteBudgetFormTrainVendorInvoiceTest() { 
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'Training Vendor Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'Training Vendor Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Vendor_Type__c = 'Training Vendor';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice2.Status__c = 'Created';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Vendor_Type__c = 'Training Vendor';
        insert invoice2;
        
        Set<Id> invoiceList = new Set<Id>{invoice.Id, invoice2.Id};
            NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(false, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFormNDBEDPInvoiceTest2
@description    : Verify ndbedp invoice budget
********************************************************
*/
    static testmethod void updteBudgetFormNDBEDPInvoiceTest2() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        Set<Id> invoiceList = new Set<Id>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice.Id);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFormNDBEDPInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__c!=null);
    } 
    
    /*
*********************************************************
@Method Name    : updteBudgetFormNDBEDPInvoiceTest1
@description    : Verify ndbedp invoice budget which is paid in same financial year
********************************************************
*/
    static testmethod void updteBudgetFormNDBEDPInvoiceTest1() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        Set<Id> invoiceList = new Set<Id>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice.Id);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFormNDBEDPInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Authorization__r.Total_Authorized_Amount__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Authorization__r.Total_Authorized_Amount__c!=null);
    } 
    
    /*
*********************************************************
@Method Name    : updteBudgetFormNDBEDPInvoiceTest1
@description    : Verify assessment invoice budget
********************************************************
*/
    static testmethod void validateBudgetForNDBEDPInvoiceTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.validateBudgetForNDBEDPInvoice(invoiceList,invoiceMap);
        Invoice__c inv = [SELECT Id,Authorization__r.Total_Authorized_Amount__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Authorization__r.Total_Authorized_Amount__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : createTaskForBudgetTest
@description    : Verify task for a budget
********************************************************
*/
    static testmethod void createTaskForBudgetTest() { 
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        Task result = NC_BudgetManagementController.createTaskForBudget(auth.Id,invoice.Id,100,'test',SYstem.today(),system.today());
        System.assertEquals('Open', result.Status);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceTest
@description    : Verify budget for assessment invoices
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFromInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceTest
@description    : Verify budget for hearing aid invoices
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceHATest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'Hearing Aid Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id haAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, haAuthTypeId);
        Authorization__c auth2 = TestDataUtility.createAuthorization(true, haAuthTypeId);
        
        Id haInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, haInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, haInvTypeId, auth2.id);
        invoice2.Status__c = 'Created';
        invoice2.Payment_Date__c = System.today()-365;
        insert invoice2;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>{invoice, invoice2};
            NC_BudgetManagementController.updteBudgetFromInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceTest
@description    : Verify budget for weather radio invoices
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceTest1() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Weather Radio Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFromInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceWRTest
@description    : Verify budget for weather radio invoices to be paid in next year
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceWRTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'Weather Radio Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'Weather Radio Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        Authorization__c auth2 = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice2.Status__c = 'Created';
        invoice2.Payment_Date__c = System.today()-365;
        insert invoice2;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>{invoice, invoice2};
            NC_BudgetManagementController.updteBudgetFromInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(false, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceTest2
@description    : Verify budget for captel invoices
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceTest2() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'CAPTEL Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFromInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceCAPTELTest
@description    : Verify budget for captel invoices to be paid in next year
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceCAPTELTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'CAPTEL Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'CAPTEL Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        Authorization__c auth2 = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice2.Status__c = 'Created';
        invoice2.Payment_Date__c = System.today()-365;
        insert invoice2;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>{invoice, invoice2};
            NC_BudgetManagementController.updteBudgetFromInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Payment_Date__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(true, inv.Payment_Date__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceCAPTELTest
@description    : Verify budget for assessment invoices to be paid in current year
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceTest3() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updteBudgetFromInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Status__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals('Created', inv.Status__c);
    }
    
    /*
*********************************************************
@Method Name    : updteBudgetFromInvoiceEDSTest
@description    : Verify budget for EDS invoices
********************************************************
*/
    static testmethod void updteBudgetFromInvoiceEDSTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'NDBEDP Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        Authorization__c auth2 = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Created';
        invoice.Payment_Date__c = System.today() + 365;
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice2.Status__c = 'Created';
        invoice2.Payment_Date__c = System.today()-365;
        insert invoice2;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>{invoice, invoice2};
            NC_BudgetManagementController.updteBudgetFromInvoice(invoiceList);
        Invoice__c inv = [SELECT Id,Budget_Management__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(false, inv.Budget_Management__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllHoldAuthorizationsAndInvoiceTest
@description    : Verify budget for hold hearing aid authorizations
********************************************************
*/
    static testmethod void updateAllHoldAuthorizationsAndInvoiceTest() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        auth.Status__c = 'Hold';
        update auth;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>();
        budgetList.add(budget);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Amount_Remaining__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__r.Amount_Remaining__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllHoldAuthorizationsAndInvoiceHATest
@description    : Verify budget for hold hearing aid invoices
********************************************************
*/
    static testmethod void updateAllHoldAuthorizationsAndInvoiceHATest() {
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'Hearing Aid Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'Hearing Aid Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId);
        auth.Status__c = 'Hold';
        insert auth;
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Payment_Reference_Number__c = '123';
        insert invoice2;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>{budget, budget2};
            NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Amount_Remaining__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(true, inv.Budget_Management__r.Amount_Remaining__c==null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllHoldAuthorizationsAndInvoiceTest1
@description    : Verify budget for hold weather radio invoices
********************************************************
*/
    static testmethod void updateAllHoldAuthorizationsAndInvoiceTest1() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Weather Radio Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        auth.Status__c = 'Hold';
        update auth;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>();
        budgetList.add(budget);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        
        NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Start_Date_Fiscal_Year__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__r.Start_Date_Fiscal_Year__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllHoldAuthorizationsAndInvoiceWRTest
@description    : Verify budget for hold weather radio invoices if budget available
********************************************************
*/
    static testmethod void updateAllHoldAuthorizationsAndInvoiceWRTest() {
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'Weather Radio Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'Weather Radio Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId);
        auth.Status__c = 'Hold';
        insert auth;
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Payment_Reference_Number__c = '123';
        insert invoice2;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>{budget, budget2};
            NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Start_Date_Fiscal_Year__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(false, inv.Budget_Management__r.Start_Date_Fiscal_Year__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllHoldAuthorizationsAndInvoiceTest2
@description    : Verify budget for hold captel invoices
********************************************************
*/
    static testmethod void updateAllHoldAuthorizationsAndInvoiceTest2() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'CAPTEL Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        auth.Status__c = 'Hold';
        update auth;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>();
        budgetList.add(budget);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        
        NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Amount_Remaining__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__r.Amount_Remaining__c==null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllHoldAuthorizationsAndInvoiceCAPTELTest
@description    : Verify budget for hold captel invoices if budget available
********************************************************
*/
    static testmethod void updateAllHoldAuthorizationsAndInvoiceCAPTELTest() {
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'CAPTEL Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'CAPTEL Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId);
        auth.Status__c = 'Hold';
        insert auth;
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('CAPTEL').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Payment_Reference_Number__c = '123';
        insert invoice2;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>{budget, budget2};
            NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Amount_Remaining__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(false, inv.Budget_Management__r.Amount_Remaining__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllHoldAuthorizationsAndInvoiceTest3
@description    : Verify budget for hold NDBEDP invoices
********************************************************
*/
    static testmethod void updateAllHoldAuthorizationsAndInvoiceTest3() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        auth.Status__c = 'Hold';
        update auth;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>();
        budgetList.add(budget);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Start_Date_Fiscal_Year__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__r.Start_Date_Fiscal_Year__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllHoldAuthorizationsAndInvoiceEDSTest
@description    : Verify budget for hold NDBEDP invoices if budget availabel
********************************************************
*/
    static testmethod void updateAllHoldAuthorizationsAndInvoiceEDSTest() {
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'NDBEDP Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId);
        auth.Status__c = 'Hold';
        insert auth;
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Payment_Reference_Number__c = '123';
        insert invoice2;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>{budget, budget2};
            NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Start_Date_Fiscal_Year__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(false, inv.Budget_Management__r.Start_Date_Fiscal_Year__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllInvoiceAndAuthStaffing
@description    : Verify budget for hold communication access request invoices 
********************************************************
*/
    static testmethod void updateAllInvoiceAndAuthStaffing() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Interpreters Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Interpreters', rc.id);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        auth.Communication_Access_Request__c = commReq.Id;
        auth.Status__c = 'Hold';
        update auth;
        
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:assessmentAuthTypeId];
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>();
        budgetList.add(budget);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth2.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        
        NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.End_Date_Fiscal_Year__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__r.End_Date_Fiscal_Year__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllInvoiceAndAuthStaffingINT
@description    : Verify budget for hold communication access request interpreters invoices 
********************************************************
*/
    static testmethod void updateAllInvoiceAndAuthStaffingINT() { 
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'Interpreters Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'Interpreters Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Interpreters', rc.id);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId);
        auth.Communication_Access_Request__c = commReq.Id;
        auth.Status__c = 'Hold';
        insert auth;
        
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:authTypeId];
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Payment_Reference_Number__c = '123';
        insert invoice2;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>{budget};
            NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.End_Date_Fiscal_Year__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__r.End_Date_Fiscal_Year__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllInvoiceAndAuthStaffing1
@description    : Verify budget for hold communication access request ssp invoices 
********************************************************
*/
    static testmethod void updateAllInvoiceAndAuthStaffing1() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'SSP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'SSP', rc.id);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        auth.Communication_Access_Request__c = commReq.Id;
        auth.Status__c = 'Hold';
        update auth;
        
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:assessmentAuthTypeId];
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>();
        budgetList.add(budget);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth2.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        
        NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Amount_Utilized__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__r.Amount_Utilized__c==null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllInvoiceAndAuthStaffing1
@description    : Verify budget for hold communication access request ssp invoices if budget available
********************************************************
*/
    static testmethod void updateAllInvoiceAndAuthStaffingSSP() { 
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'SSP Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'SSP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'SSP', rc.id);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId);
        auth.Communication_Access_Request__c = commReq.Id;
        auth.Status__c = 'Hold';
        insert auth;
        
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:authTypeId];
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Payment_Reference_Number__c = '123';
        insert invoice2;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>{budget};
            NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Amount_Utilized__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(false, inv.Budget_Management__r.Amount_Utilized__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllInvoiceAndAuthStaffing2
@description    : Verify budget for hold communication access request cart invoices
********************************************************
*/
    static testmethod void updateAllInvoiceAndAuthStaffing2() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'CART Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'CART', rc.id);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        auth.Communication_Access_Request__c = commReq.Id;
        auth.Status__c = 'Hold';
        update auth;
        
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:assessmentAuthTypeId];
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>();
        budgetList.add(budget);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth2.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        
        NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Amount_Remaining__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(false, inv.Budget_Management__r.Amount_Remaining__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllInvoiceAndAuthStaffingCART
@description    : Verify budget for hold communication access request cart invoices if budget available
********************************************************
*/
    static testmethod void updateAllInvoiceAndAuthStaffingCART() { 
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'CART Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'CART Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'CART', rc.id);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId);
        auth.Communication_Access_Request__c = commReq.Id;
        auth.Status__c = 'Hold';
        insert auth;
        
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:authTypeId];
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Payment_Reference_Number__c = '123';
        insert invoice2;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>{budget};
            NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.Amount_Remaining__c FROM Invoice__c WHERE Id =: invoice2.Id];
        System.assertEquals(true, inv.Budget_Management__r.Amount_Remaining__c==null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllInvoiceAndAuthStaffing3
@description    : Verify budget for hold training vendor invoices 
********************************************************
*/
    static testmethod void updateAllInvoiceAndAuthStaffing3() { 
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'Training Vendor Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Request_For_Training_Vendor').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Training Vendor', rc.id);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        auth.Communication_Access_Request__c = commReq.Id;
        auth.Status__c = 'Hold';
        update auth;
        
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:assessmentAuthTypeId];
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>();
        budgetList.add(budget);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth2.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>();
        invoiceList.add(invoice);
        invoiceMap.put(invoice.Id,invoice);
        
        
        NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.End_Date_Fiscal_Year__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__r.End_Date_Fiscal_Year__c==null);
    }
    
    /*
*********************************************************
@Method Name    : updateAllInvoiceAndAuthStaffingTrainVendor
@description    : Verify budget for hold training vendor invoices if budget available
********************************************************
*/
    static testmethod void updateAllInvoiceAndAuthStaffingTrainVendor() { 
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(false, 'Training Vendor Budget');
        if(System.now().month() >= 7) {
            budget.Budget_Year__c = (System.now().year() + 1) + '';
        } else {
            budget.Budget_Year__c = (System.now().year()) + '';
        }
        insert budget;
        Budget_Management__c budget2 = TestDataUtility.createBudgetManagement(true, 'Training Vendor Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Account rc = TestDataUtility.createRegionalCenter(true);   
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Request_For_Training_Vendor').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commRequestTypeId, 'Training Vendor', rc.id);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authTypeId);
        auth.Communication_Access_Request__c = commReq.Id;
        auth.Status__c = 'Hold';
        insert auth;
        
        Authorization__c auth2 = [SELECT Id,CreatedDate,RecordTypeId,Status__c,Vendor_Type__c FROM Authorization__c WHERE RecordTypeId=:authTypeId];
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today() + 365;
        invoice.Payment_Reference_Number__c = '123';
        insert invoice;
        
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, invTypeId, auth2.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today() - 365;
        invoice2.Payment_Reference_Number__c = '123';
        insert invoice2;
        
        List<Budget_Management__c> budgetList = new List<Budget_Management__c>{budget};
        NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(budgetList));
        Invoice__c inv = [SELECT Id,Budget_Management__r.End_Date_Fiscal_Year__c FROM Invoice__c WHERE Id =: invoice.Id];
        System.assertEquals(true, inv.Budget_Management__r.End_Date_Fiscal_Year__c==null);
    }
}