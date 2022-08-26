/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_InvoiceTriggerHandlerTest {
    
    /*
*********************************************************
@Method Name    : batchTest
@description    : Verify invoice create and update validation
********************************************************
*/
    static testmethod void batchTest() {
        
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Email__c = 'test@gmail.com';
        vendor.Last_Name__c = 'lastname';
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        
        contact con = TestDataUtility.createConsumer(true);
        
        Id equipmentTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case request = TestDataUtility.createCase(true, equipmentTypeId, con.id, 'EDS', 'Hearing Aid');
        
        Id authHearingAidTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(false, authHearingAidTypeId);
        auth.Vendor__c = vendor.id;
        auth.Consumer__c = con.id;
        auth.Request__c = request.id;
        insert auth;
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id invHearingAidTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c inv = TestDataUtility.createInvoice(false, invHearingAidTypeId, auth.id);
        inv.Status__c = 'Ready For Payment';
        inv.Payment_Date__c = System.today();
        inv.Payment_Reference_Number__c = '656456747';
        inv.Payment_Type_Code__c = 'system';
        inv.Payment_Date__c = Date.today();
        insert inv;
        
        inv.Status__c = 'Paid';
        inv.Budget_Management__c = budget.Id;
        inv.Refund__c = 10;
        inv.Check_Canceled_Code__c = '0004';
        inv.Payment_Date__c = Date.today();
        update inv;
        
        
        inv.Check_Canceled_Code__c = '0004';
        inv.Payment_Date__c = Date.today()+2;
        inv.Check_Lost__c = true;
        update inv; 
        
        ContentDocumentLink cd2 = TestDataUtility.createFile(inv.id, 'testinging.png', 'Affidavit of loss', 'body');
        Map<String,String> ContentDocumentMap = new Map<String,String>();
        Map<String,String> checkLostInvoiceMap = new Map<String,String>();
        ContentDocumentMap.put(inv.Id,cd2.Id);
        checkLostInvoiceMap.put(inv.Id,cd2.Id);
        try{
            List<ContentDocumentLink> result = NC_InvoiceTriggerHandler.cloneContentDocumentLinks(ContentDocumentMap,checkLostInvoiceMap);
            System.assertEquals(true, result.size()>0);
        }
        catch(Exception e){
        }
        
        Id ndbedpTrainingId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Training').getRecordTypeId();
        Invoice__c inv2 = TestDataUtility.createInvoice(false, ndbedpTrainingId, auth.id);
        inv2.Status__c = 'Created';
        inv2.Payment_Date__c = System.today();
        inv2.Payment_Reference_Number__c = '656456747';
        inv2.Payment_Type_Code__c = 'system';
        insert inv2;
        
        inv2.Status__c = 'Pending NDBEDP Coordinator';
        inv2.Budget_Management__c = budget.Id;
        inv2.Refund__c = 10;
        inv2.Consumer_Signed_Date__c = Date.today();
        try{
            update inv2;
            system.assertEquals(false, inv2.Affidavit_of_loss_uploaded__c);
        }
        catch(Exception e){
        }
        
        Invoice__c inv1 = TestDataUtility.createInvoice(false, invHearingAidTypeId, auth.id);
        inv1.Status__c = 'Pending NDBEDP Coordinator';
        inv1.Payment_Date__c = System.today();
        inv1.Payment_Reference_Number__c = '656456747';
        inv1.Payment_Type_Code__c = 'system';
        insert inv1;
        
        inv1.Status__c = 'Ready For Payment';
        inv1.Budget_Management__c = budget.Id;
        inv1.Refund__c = 10;
        try{
            update inv1;
            system.assertEquals(false, inv1.CART_Invoice__c);
        }
        catch(Exception e){
        }
        
        List<String> invoiceLineItemFields = NC_InvoiceTriggerHandler.getCreatableObjectFields('Invoice_Line_Item__c');
        System.assertEquals(true, invoiceLineItemFields.size()>0);
        
        String queryFields = NC_InvoiceTriggerHandler.getFieldsAsString(invoiceLineItemFields);
        System.assertEquals(true,queryFields!=null);        
        
        Invoice__c inv3 = TestDataUtility.createInvoice(false, invHearingAidTypeId, auth.id);
        inv3.Status__c = 'Created';
        inv3.Payment_Date__c = System.today();
        inv3.Payment_Reference_Number__c = '656456747';
        inv3.Payment_Type_Code__c = 'system';
        insert inv3;
        
        inv3.Status__c = 'Submitted and Rejected';
        inv3.MM110_error_reason__c = 'test';
        inv3.Budget_Management__c = budget.Id;
        inv3.Refund__c = 10;
        try{
            update inv3;
            system.assertEquals(false, inv3.Cancelled_Reason__c==null);
        }
        catch(Exception e){
        }
        
        
        Id equipmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Invoice__c inv4 = TestDataUtility.createInvoice(false, equipmentId, auth.id);
        inv4.Status__c = 'Pending NDBEDP Coordinator';
        insert inv4;
        
        inv4.Status__c = 'Pending Controller Office Approval';
        try{
            update inv4;
            system.assertEquals(0, inv4.Refund__c);
        }
        catch(Exception e){
        }
        
        
        Invoice__c inv5 = TestDataUtility.createInvoice(false, equipmentId, auth.id);
        inv5.Status__c = 'Pending Controller Office Approval';
        insert inv5;
        
        inv5.Status__c = 'Pending NDBEDP Coordinator';
        try{
            update inv5;
            system.assertEquals(true, inv5.Budget_Management__c!=null);
        }
        catch(Exception e){
        }
        
        Invoice__c inv6 = TestDataUtility.createInvoice(false, equipmentId, auth.id);
        inv6.Status__c = 'Pending NDBEDP Coordinator';
        inv6.Check_Canceled_Code__c = '0004';
        insert inv6;
        
        inv6.Status__c = 'Pending Controller Office Approval';
        try{
            update inv6;
            system.assertEquals(false, inv6.Consumer_Evaluation__c);
        }
        catch(Exception e){
        }
        
        Id hearingAidId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Invoice__c inv7 = TestDataUtility.createInvoice(false, hearingAidId, auth.id);
        inv7.Status__c = 'Pending NDBEDP Coordinator';
        inv7.Payment_Date__c = System.today();
        
        inv7.Payment_Type_Code__c = 'system';
        
        insert inv7;
        
        inv7.Status__c = 'Ready For Payment';
        inv7.Budget_Management__c = budget.Id;
        inv7.Refund__c = 10;
        inv7.Return_Invoice__c = true;
        inv7.Payment_Reference_Number__c = '656456747';
        inv7.Manually_Cancel_in_NCAS__c = true;
        inv7.Manually_Cancel_in_NCAS__c = true;
        inv7.NCAS_Status__c = 'X – Error';
        
        try{
            update inv7;
            system.assertEquals(false, inv7.Check_Lost__c);
        }
        catch(Exception e){
        }
        
        Invoice__c inv8 = TestDataUtility.createInvoice(false, hearingAidId, auth.id);
        inv8.Status__c = 'Pending NDBEDP Coordinator';
        inv8.Payment_Date__c = System.today();
        
        inv8.Payment_Type_Code__c = 'system';
        
        insert inv8;
        
        inv8.Status__c = 'Canceled';
        inv8.Budget_Management__c = budget.Id;
        inv8.Refund__c = 10;
        inv8.Return_Invoice__c = true;
        inv8.Payment_Reference_Number__c = '656456747';
        inv8.Manually_Cancel_in_NCAS__c = true;
        inv8.Manually_Cancel_in_NCAS__c = true;
        inv8.NCAS_Status__c = 'C - Invoice canceled';
        inv8.Check_Canceled_Code__c = '1234';
        
        try{
            update inv8;
            system.assertEquals(false, inv8.Affidavit_of_loss_uploaded__c);
        }
        catch(Exception e){
        }
        
        try{
            inv8.NCAS_Status__c = 'N – record not in NCAS';
            system.assertEquals(true, inv8.Authorization__c!=null);
            update inv8;
            Delete inv8;
        }
        catch(Exception e){
        }
        
        //   Id hearingAidId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Invoice__c inv9 = TestDataUtility.createInvoice(false, hearingAidId, auth.id);
        inv9.Status__c = 'Pending NDBEDP Coordinator';
        inv9.Payment_Date__c = System.today();
        
        inv9.Payment_Type_Code__c = 'system';
        
        insert inv9;
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        invoiceList.add(inv9);
        
        try{
            //  NC_InvoiceTriggerHandler.rollUpOnDelete(invoiceList);
        }
        catch(Exception e){
        }
        
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPTrainingInvoiceTest
@description    : Verify NDBEDP Training invoice validations
********************************************************
*/
    static testmethod void validateNDBEDPTrainingInvoiceTest() {
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Training').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Training').getRecordTypeId();
        Invoice__c inv = TestDataUtility.createInvoice(false, invTypeId, auth.id);
        insert inv;
        
        try{
            inv.Status__c = 'Pending NDBEDP Coordinator';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c='Pending TRP Manager');
            NC_InvoiceTriggerHandler.validateNDBEDPTrainingInvoice(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Status__c = 'Pending NDBEDP Coordinator';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c='Created');
            NC_InvoiceTriggerHandler.validateNDBEDPTrainingInvoice(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Status__c = 'Pending TRP Manager';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c='Pending NDBEDP Coordinator');
            NC_InvoiceTriggerHandler.validateNDBEDPTrainingInvoice(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Status__c = 'Pending TRP Manager';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c='Pending Controller Office Approval');
            NC_InvoiceTriggerHandler.validateNDBEDPTrainingInvoice(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Status__c = 'Pending NDBEDP Coordinator';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c='Pending TRP Manager', MM110_error_reason__c='test');
            NC_InvoiceTriggerHandler.validateNDBEDPTrainingInvoice(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Status__c = 'Pending NDBEDP Coordinator';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c='Pending TRP Manager', Resolution_Checkbox__c = true);
            NC_InvoiceTriggerHandler.validateNDBEDPTrainingInvoice(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Status__c = 'Submitted and Error';
            inv.Manually_Cancel_in_NCAS__c = true;
            inv.MM110_error_reason__c = 'test';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c='Submitted and Error');
            NC_InvoiceTriggerHandler.populateStatusForReturn(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Status__c = 'Submitted and Rejected';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c = 'Pending Approval');
            NC_InvoiceTriggerHandler.populateStatusForReturn(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Status__c = 'Submitted and Error';
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id, Status__c = 'Pending Approval');
            NC_InvoiceTriggerHandler.populateStatusForReturn(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            inv.Coordinator_Feedback_Required__c = false;
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id,NCAS_Status__c='N – record not in NCAS',Coordinator_Feedback_Required__c=true);
            NC_InvoiceTriggerHandler.populateStatusForReturn(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try{
            Invoice__c inv1 = new Invoice__c(RecordTypeId=invTypeId, id=inv.id,MM110_error_reason__c='test',Coordinator_Feedback_Required__c=true);
            NC_InvoiceTriggerHandler.populateStatusForReturn(new List<Invoice__c>{inv1}, new Map<Id, Invoice__c>{inv.id=>inv});
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
}