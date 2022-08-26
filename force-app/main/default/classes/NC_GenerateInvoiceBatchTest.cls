/**
* @description       : Test class for NC_GenerateInvoiceBatch
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_GenerateInvoiceBatchTest {
    /*
    *********************************************************
    @Method Name    : batchTest
    @description    : Verify generation of Check Statements for Vendor
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
        
        Id invHearingAidTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Invoice__c inv = TestDataUtility.createInvoice(false, invHearingAidTypeId, auth.id);
        inv.Status__c = 'Paid';
        inv.Payment_Date__c = System.today();
        inv.Payment_Reference_Number__c = '656456747';
        inv.Payment_Type_Code__c = 'system';
        insert inv;
        
        test.startTest();
        NC_GenerateInvoiceBatch batch = new NC_GenerateInvoiceBatch();
        Database.executeBatch(batch);
        test.stopTest();
        
        Invoice__c invoice = [SELECT Invoice_Generated__c FROM Invoice__c WHERE id =: inv.id];
        System.assertEquals(true, invoice.Invoice_Generated__c);
    }
}