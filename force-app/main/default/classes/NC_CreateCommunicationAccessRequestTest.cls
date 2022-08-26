/**
* @description       : Test class for NC_CreateCommunicationAccessRequest
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CreateCommunicationAccessRequestTest {

    /*
    *********************************************************
    @Method Name    : retrieveDefaultsTest
    @description    : Verify creation on communication access request based on related outreach request
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
        
        Map<String,Object> resultMap5 = NC_CreateCommunicationAccessRequest.retrieveDefaults(auth.id, false);
        System.assertEquals(true, resultMap5.get('forAuthotizationTypeTainingVendor'));
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveDefaults2Test
    @description    : Verify creation on communication access request based on related outreach request and validation
    ********************************************************
    */
    static testmethod void retrieveDefaults2Test() {
        //Case NDBEDP
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        Case ndbedpCase = TestDataUtility.createNDBEDPCase(true, con.id);
        Map<String,Object> resultMap6 = NC_CreateCommunicationAccessRequest.retrieveDefaults(ndbedpCase.id, true);
        System.assertEquals(true, resultMap6.get('forNDBEDPRequest'));
        
        //Case
        Account rc = TestDataUtility.createRegionalCenter(true);
        
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(false, commRequestTypeId, 'SSP', rc.id);
        commReq.Request__c = ndbedpCase.id;
        insert commReq;
        
        Id staffRequestTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReq = TestDataUtility.createStaffingRequest(true, staffRequestTypeId, commReq.Id, '1');
        
        Id staffUserRequestTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserReq = TestDataUtility.createStaffingUserRequest(true, staffUserRequestTypeId, staffReq.Id);
        
        Map<String,Object> resultMap7 = NC_CreateCommunicationAccessRequest.retrieveDefaults(ndbedpCase.id, false);
        System.assertEquals('NDBEDP Trainer Request is in progress', resultMap7.get('error'));
        
        //other
        Id nonDHHOutreachRecordTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Non_DHH_Sponsor_Event').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, nonDHHOutreachRecordTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        
        Event_Attribute__c event = new Event_Attribute__c();
        event.Outreach_Request__c = outreach.id;
        insert event;
        Map<String,Object> resultMap8 = NC_CreateCommunicationAccessRequest.retrieveDefaults(event.id, false);
        System.assertEquals(true, resultMap8.get('forOutreach'));
    }
}