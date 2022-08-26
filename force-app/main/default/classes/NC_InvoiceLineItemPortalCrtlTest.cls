/**
* @description       : Test class for NC_InvoiceLineItemPortalCrtl
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_InvoiceLineItemPortalCrtlTest {

    /*
    *********************************************************
    @Method Name    : checkRecordTypeTest
    @description    : Verify invoice line items component based on invoice record type
    ********************************************************
    */
    static testmethod void checkRecordTypeTest() {
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Id invAssessmentId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth1 = TestDataUtility.createAuthorization(true, authAssessmentId);
        Invoice__c inv1 = TestDataUtility.createInvoice(true, invAssessmentId, auth1.id);
        
        Map<String, Object> resultMap1 = NC_InvoiceLineItemPortalCrtl.checkRecordType(inv1.id);
        System.assertEquals(true, resultMap1.get('NDBEDPLineItem'));
        
        Id authCommId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Id invCommId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth2 = TestDataUtility.createAuthorization(true, authCommId);
        Invoice__c inv2 = TestDataUtility.createInvoice(true, invCommId, auth2.id);
        
        Map<String, Object> resultMap2 = NC_InvoiceLineItemPortalCrtl.checkRecordType(inv2.id);
        System.assertEquals(true, resultMap2.get('NDBEDPLineItem'));
        
        Id authHearingAidId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Id invHearingAidId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth3 = TestDataUtility.createAuthorization(true, authHearingAidId);
        Invoice__c inv3 = TestDataUtility.createInvoice(true, invHearingAidId, auth3.id);
        
        Map<String, Object> resultMap3 = NC_InvoiceLineItemPortalCrtl.checkRecordType(inv3.id);
        System.assertEquals(true, resultMap3.get('EDSLineItem'));
        
        Id authCommSSPId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Id invCommSSPId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth4 = TestDataUtility.createAuthorization(true, authCommSSPId);
        Invoice__c inv4 = TestDataUtility.createInvoice(false, invCommSSPId, auth4.id);
        inv4.Vendor_Type__c = 'NDBEDP SSP';
        insert inv4;
        
        Map<String, Object> resultMap4 = NC_InvoiceLineItemPortalCrtl.checkRecordType(inv4.id);
        System.assertEquals(true, resultMap4.get('NDBEDPLineItem'));
    }
}