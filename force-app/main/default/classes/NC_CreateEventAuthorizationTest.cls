/**
* @description       : Test class for NC_CreateEventAuthorization
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CreateEventAuthorizationTest {

    /*
    *********************************************************
    @Method Name    : getEventAuthorizationRecordTypesTest
    @description    : Verify creation of Event Authorization based on related Outreach Request  data
    ********************************************************
    */
    static testmethod void getEventAuthorizationRecordTypesTest() {
        Id outreachTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('DHH_Sponsor_Event').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, outreachTypeId, system.now()+1, system.now()+2, 'title', 'address', null);
        
        Map<String, Object> resultMap = NC_CreateEventAuthorizationController.getEventAuthorizationRecordTypes(outreach.id);
        System.assertNotEquals(null, resultMap);
    }
}