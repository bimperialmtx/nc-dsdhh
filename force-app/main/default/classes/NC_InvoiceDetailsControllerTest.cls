/**
* @description       : Test class for NC_InvoiceDetailsController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_InvoiceDetailsControllerTest {

    /*
    *********************************************************
    @Method Name    : test1
    @description    : Verify generation of invoice check statement letter for Vendor
    ********************************************************
    */
    static testmethod void test1() {
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
        PageReference pageRef = Page.NC_InvoiceDetails;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(vendor.id));
        pageRef.getParameters().put('checkNo', String.valueOf(inv.Payment_Reference_Number__c));
        NC_InvoiceDetailsController controller = new NC_InvoiceDetailsController();
        test.stopTest();
        System.assertNotEquals(null, controller.vendorDetail);
    }
}