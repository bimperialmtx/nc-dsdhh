/**
* @description       : Test class for NC_LineItemController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_LineItemControllerTest {

    /*
    *********************************************************
    @Method Name    : getAllLineItemsTest
    @description    : Verify created line items for invoice
    ********************************************************
    */
    static testmethod void getAllLineItemsTest() {
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        
        Id authHearingAidTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Id invHearingAidTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
		Authorization__c auth = TestDataUtility.createAuthorization(true, authHearingAidTypeId);
        
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invHearingAidTypeId, auth.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        Map<String,Object> resultMap1 = NC_LineItemController.getAllLineItems(inv1.id);
        System.assertEquals(800, resultMap1.get('totalAmountToPay'));
        
        Invoice__c inv2 = TestDataUtility.createInvoice(false, invHearingAidTypeId, auth.id);
        inv2.Status__c = 'Returned';
        insert inv2;
        Invoice_Line_Item__c invLineItem2 = TestDataUtility.createInvoiceLineItem(false, inv2.id);
        invLineItem2.Returned__c = true;
        insert invLineItem2;
        Map<String,Object> resultMap2 = NC_LineItemController.getAllLineItems(inv2.id);
        System.assertEquals(800, resultMap2.get('totalAmountToPay'));
        
        Authorization__c authAssessment = TestDataUtility.createAuthorization(true, authAssessmentId);
        Invoice__c inv3 = TestDataUtility.createInvoice(true, invAssessmentId, authAssessment.id);
        Invoice_Line_Item__c invLineItem3 = TestDataUtility.createInvoiceLineItem(true, inv3.id);
        Map<String,Object> resultMap3 = NC_LineItemController.getAllLineItems(inv3.id);
        System.assertEquals(800, resultMap3.get('totalAmountToPay'));
    }
    
    /*
    *********************************************************
    @Method Name    : updateAllLineItemsTest
    @description    : Verify invoice line items update and validations
    ********************************************************
    */
    static testmethod void updateAllLineItemsTest() {
        
        Id authHearingAidTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Id invHearingAidTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
		Authorization__c auth = TestDataUtility.createAuthorization(true, authHearingAidTypeId);
        
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invHearingAidTypeId, auth.id);
        Invoice_Line_Item__c invLineItem1 = TestDataUtility.createInvoiceLineItem(true, inv1.id);
        
        NC_LineItemController.LineItemWrapper wrap = new NC_LineItemController.LineItemWrapper(invLineItem1.id, 'Test', 0, 0, 0, 'Test', false);
        String lineItemData = JSON.serialize(new List<NC_LineItemController.LineItemWrapper>{wrap});
        
        Map<String,Object> resultMap = NC_LineItemController.updateAllLineItems(lineItemData);
        System.assertNotEquals(null, resultMap.get('lineItemListWrapperList'));
    }
}