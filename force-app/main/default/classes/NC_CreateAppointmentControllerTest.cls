/**
* @description       : Test class for NC_CreateAppointmentController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_CreateAppointmentControllerTest {
    
    /*
    *********************************************************
    @Method Name    : retrieveDefaultsTest
    @description    : Verify vendor related to authorization
    ********************************************************
    */
    static testmethod void retrieveDefaultsTest() {
        
        //Outreach Request
        Id nonDHHOutreachRecordTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Non_DHH_Sponsor_Event').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, nonDHHOutreachRecordTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        Map<String,Object> resultMap = NC_CreateCommunicationAccessRequest.retrieveDefaults(outreach.id, false);
        System.assertEquals(true, resultMap.get('forOutreach'));
        
        Id ndbedpEventRecordTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Event').getRecordTypeId();
        Outreach_Request__c outreach2 = TestDataUtility.createOutreachRequest(true, ndbedpEventRecordTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        Map<String,Object> resultMap2 = NC_CreateCommunicationAccessRequest.retrieveDefaults(outreach2.id, false);
        System.assertEquals(true, resultMap2.get('forOutreach'));
        
        Id infoSessionRecordTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
        Outreach_Request__c outreach3 = TestDataUtility.createOutreachRequest(true, infoSessionRecordTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        Map<String,Object> resultMap3 = NC_CreateCommunicationAccessRequest.retrieveDefaults(outreach3.id, false);
        System.assertEquals(true, resultMap3.get('forOutreach'));
        
        //Mentoring Request
        Mentoring_Request__c mentoringReq = new Mentoring_Request__c();
        insert mentoringReq;
        Map<String,Object> resultMap4 = NC_CreateCommunicationAccessRequest.retrieveDefaults(mentoringReq.id, false);
        System.assertEquals(true, resultMap4.get('forMentoringRequest'));
        
        //Authorization
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, equipmentTypeId, vendor.id, 'test', 'Speech Equipment', 100);
        
        Id equipmentRequestId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case edsRequest = TestDataUtility.createCase(true, equipmentRequestId, con.id, 'EDS', 'Speech Equipment');
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, edsRequest.id, eqp.id);
        
        Id edsAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, edsAuthTypeId, edsRequest.Id, vendor.Id, con.id);
        
        Id genericAssetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Generic_Asset').getRecordTypeId();
        TestDataUtility.createAsset(true, genericAssetTypeId, auth.Id, eqp.Id, edsRequest.Id);
        
        Test.startTest();
        Map<String,Object> result = NC_CreateAppointmentController.retrieveVendor(auth.id);
        Test.stopTest();
        System.assertEquals(true,result.size()>0 );
    }
}