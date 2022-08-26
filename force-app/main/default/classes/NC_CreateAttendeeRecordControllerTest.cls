/**
* @description       : Test class for NC_CreateAttendeeRecordController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CreateAttendeeRecordControllerTest {

    /*
    *********************************************************
    @Method Name    : retrieveDefaultsTest
    @description    : Verify attendees record type based on related outreach request
    ********************************************************
    */
    static testmethod void retrieveDefaultsTest() {
        Id ndbedpEventTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Event').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, ndbedpEventTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        
        Map<String,Object> resultMap = NC_CreateAttendeeRecordController.retrieveDefaults(outreach.id);
        System.assertEquals(true, resultMap.get('forOutreach'));
        
        Id infoSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
        Outreach_Request__c outreach2 = TestDataUtility.createOutreachRequest(true, infoSessionTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        
        Map<String,Object> resultMap2 = NC_CreateAttendeeRecordController.retrieveDefaults(outreach2.id);
        System.assertEquals(true, resultMap2.get('forOutreach'));
        
        Attendees__c att = new Attendees__c();
        insert att;
        Map<String,Object> resultMap3 = NC_CreateAttendeeRecordController.retrieveDefaults(att.id);
        System.assertEquals(false, resultMap3.get('forOutreach'));
    }
}