/**
* @description       : Test class for NC_InvoiceLineItemStaffingController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_InvoiceLineItemStaffingControllerTest {

    /*
    *********************************************************
    @Method Name    : getAllLineItemsTest
    @description    : Verify created invoice line items for invoice
    ********************************************************
    */
    static testmethod void getAllLineItemsTest() {
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        
        Map<String,Object> resultMap1 = NC_InvoiceLineItemStaffingController.getAllLineItems(inv1.id);
        System.assertEquals(800, resultMap1.get('totalAmountBilled'));
    }
    
    /*
    *********************************************************
    @Method Name    : updateAllLineItemsTest
    @description    : Verify invoice line items update
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
        
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap1 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem1.id, 'Test', 0, 1, 0, true, false, null, false, null, 1);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap2 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem2.id, 'Parking', 0, 1, 0, true, false, null, false, null, 2);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap3 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem3.id, 'Hotels', 0, 1, 0, true, false, null, false, null, 3);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap4 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem4.id, 'Dinner', 0, 1, 0, true, false, null, false, null, 4);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap5 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem5.id, 'Lunch', 0, 1, 0, true, false, null, false, null, 5);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap6 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem6.id, 'Mileage', 0, 1, 0, true, false, null, false, null, 6);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap7 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem7.id, 'Breakfast', 0, 1, 0, true, false, null, false, null, 7);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap8 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem8.id, 'Service Hours', 0, 1, 0, true, false, null, false, null, 8);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap9 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem9.id, 'Travel Time', 0, 1, 0, true, false, null, false, null, 9);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap10 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem10.id, 'Standard', 0, 1, 0, true, false, null, false, null, 10);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap11 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem11.id, 'Food', 0, 1, 0, true, false, null, false, null, 11);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap12 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem12.id, 'Lodging', 1, 0, 0, true, false, null, false, null, 12);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap13 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem13.id, 'Other', 0, 1, 0, true, false, null, false, null, 13);
        NC_InvoiceLineItemStaffingController.LineItemWrapper wrap14 = new NC_InvoiceLineItemStaffingController.LineItemWrapper(invLineItem14.id, 'Excess hotel Cost', 0, 0, 0, true, false, null, false, null, 14);
        String lineItemData = JSON.serialize(new List<NC_InvoiceLineItemStaffingController.LineItemWrapper>{wrap1, wrap2, wrap3, wrap4, wrap5, wrap6, wrap7, wrap8, wrap9, wrap10, wrap11, wrap12, wrap13, wrap14});
        
        Map<String,Object> resultMap = NC_InvoiceLineItemStaffingController.updateAllLineItems(lineItemData, inv1.id);
        System.assertNotEquals(null, resultMap.get('lineItemListWrapperList'));
    }
}