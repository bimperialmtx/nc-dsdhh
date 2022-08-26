/**
* @description       : Test class for NC_NDBEDPBudgetManagementBatch
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_NDBEDPBudgetManagementBatchTest {

    /*
    *********************************************************
    @Method Name    : batchTest
    @description    : Verify hold invoices budget for NDBEDP
    ********************************************************
    */
    static testmethod void batchTest() {
        
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'NDBEDP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 1000000);
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        
        Id assessmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Invoice__c invoice = TestDataUtility.createInvoice(false, assessmentInvTypeId, auth.id);
        invoice.Status__c = 'Hold';
        invoice.Payment_Date__c = System.today();
        insert invoice;
        
        TestDataUtility.createInvoiceLineItem(true, invoice.id);
        
        //Equipment Invoice
        //Id equipmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        //Authorization__c auth2 = TestDataUtility.createAuthorization(true, equipmentAuthTypeId);
         Id AuthorizationTrainingVendorIncoiveId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Training_Vendor');
        Authorization__c auth3 = TestDataUtility.createAuthorization(true, AuthorizationTrainingVendorIncoiveId);
        
        
        Id equipmentInvTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Invoice__c invoice2 = TestDataUtility.createInvoice(false, equipmentInvTypeId, auth3.id);
        invoice2.Status__c = 'Hold';
        invoice2.Payment_Date__c = System.today();
        invoice2.Payment_Reference_Number__c = 'test';
        insert invoice2;
        
        TestDataUtility.createInvoiceLineItem(true, invoice2.id);
        
        Test.startTest();
        NC_NDBEDPBudgetManagementBatch batch = new NC_NDBEDPBudgetManagementBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        Budget_Management__c budgetData = [SELECT Amount_Utilized_Formula__c FROM Budget_Management__c WHERE id =: budget.id];
        System.assertEquals(1600, budgetData.Amount_Utilized_Formula__c);
    }
}