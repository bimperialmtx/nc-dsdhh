/**
* @description       : Test class for NC_InvoiceLineItemNDBEDPController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_InvoiceLineItemNDBEDPControllerTest {

    /*
    *********************************************************
    @Method Name    : getAllLineItemsTest
    @description    : Verify all created Communication Access invoice line items
    ********************************************************
    */
    static testmethod void getAllLineItems2Test() {
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth.id);
        
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem1.Equipment_Name__c = 'Standard Rate';
        Invoice_Line_Item__c invLineItem2 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem2.Equipment_Name__c = 'Enhanced Rate';
        Invoice_Line_Item__c invLineItem3 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem3.Equipment_Name__c = 'TASL Standard hours';
        Invoice_Line_Item__c invLineItem4 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem4.Equipment_Name__c = 'TASL Enhanced hours';
        Invoice_Line_Item__c invLineItem5 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem5.Equipment_Name__c = 'Mileage';
        Invoice_Line_Item__c invLineItem6 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem6.Equipment_Name__c = 'Lunch';
        Invoice_Line_Item__c invLineItem7 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem7.Equipment_Name__c = 'Hotels';
        Invoice_Line_Item__c invLineItem8 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem8.Equipment_Name__c = 'Parking';
        Invoice_Line_Item__c invLineItem9 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem9.Equipment_Name__c = 'Breakfast';
        Invoice_Line_Item__c invLineItem10 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem10.Equipment_Name__c = 'Dinner';
        Invoice_Line_Item__c invLineItem11 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem11.Equipment_Name__c = 'Excess Hotel Cost';
        Invoice_Line_Item__c invLineItem12 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem12.Equipment_Name__c = 'Travel Time';
        Invoice_Line_Item__c invLineItem13 = TestDataUtility.createInvoiceLineItem(false, inv1.id);
        invLineItem13.Equipment_Name__c = 'Hours';
        
        List<Invoice_Line_Item__c> lineItems = new List<Invoice_Line_Item__c>{invLineItem1, invLineItem2, invLineItem3, invLineItem4, invLineItem5, invLineItem6, invLineItem7, invLineItem8, invLineItem9, invLineItem10, invLineItem11, invLineItem12, invLineItem13};
       	insert lineItems;
            
        Map<String,Object> resultMap1 = NC_InvoiceLineItemNDBEDPController.getAllLineItems(inv1.id);
        System.assertEquals(10400.00, resultMap1.get('totalAmountToPay'));
    }
    
    /*
    *********************************************************
    @Method Name    : updateAllLineItemsTest
    @description    : Verify NDBEDP line items update
    ********************************************************
    */
    static testmethod void updateAllLineItemsTest() {
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem2 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem3 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem4 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem5 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem6 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem7 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem8 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem9 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem10 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem11 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem12 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem13 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Invoice_Line_Item__c invLineItem14 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap1 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem1.id, 'Test', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 1);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap2 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem2.id, 'Parking', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 2);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap3 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem3.id, 'Hotels', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 3);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap4 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem4.id, 'Dinner', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 4);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap5 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem5.id, 'Lunch', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 5);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap6 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem6.id, 'Mileage', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 6);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap7 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem7.id, 'Breakfast', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 7);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap8 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem8.id, 'Service Hours', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 8);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap9 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem9.id, 'Travel Time', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 9);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap10 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem10.id, 'Standard', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 10);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap11 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem11.id, 'Food', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 11);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap12 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem12.id, 'Lodging', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 12);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap13 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem13.id, 'Other', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 13);
        NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper wrap14 = new NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper(invLineItem14.id, 'Excess hotel Cost', 0, 0, 0, true, false, 0, 1, true, false, null, false, null, 14);
        String lineItemData = JSON.serialize(new List<NC_InvoiceLineItemNDBEDPController.LineItemNDBEDPWrapper>{wrap1, wrap2, wrap3, wrap4, wrap5, wrap6, wrap7, wrap8, wrap9, wrap10, wrap11, wrap12, wrap13, wrap14});
        
        Map<String,Object> resultMap = NC_InvoiceLineItemNDBEDPController.updateAllLineItems(lineItemData, inv1.id);
        System.assertNotEquals(null, resultMap.get('lineItemListWrapperList'));
    }
}