/**
* @description       : Test class for NC_InformationSessionConsumerRequest
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_InformationSessionConsumerRequestTest {

    /*
    *********************************************************
    @Method Name    : fetchConsumerListTest
    @description    : Verify invitations to be sent for consumers
    ********************************************************
    */
    static testmethod void fetchConsumerListTest() {
        Id infoSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, infoSessionTypeId, System.now()+1, System.now()+2, 'title', 'test', null);
        
        Contact con = TestDataUtility.createConsumer(true);
        Id outreachAttendessId = Schema.SObjectType.Attendees__c.getRecordTypeInfosByDeveloperName().get('Attendees_For_Outreach_Request').getRecordTypeId();
        Attendees__c attendees = TestDataUtility.createAttendees(true, outreachAttendessId, outreach.id, con.id, null, null);
        
        Map<String, Object> resultMap = NC_InformationSessionConsumerRequest.fetchConsumerList(null);
        System.assertNotEquals(null, resultMap.get('result'));
    }
    
    /*
    *********************************************************
    @Method Name    : sendInviationToConsumerTest
    @description    : Verify sending invitations to consumers
    ********************************************************
    */
    static testmethod void sendInviationToConsumerTest() {
        Contact con = TestDataUtility.createConsumer(true);
        Id infoSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, infoSessionTypeId, System.now()+1, System.now()+2, 'title', 'test', null);
        
        String data = '[{"consumerEmailId": "ncdhdss@gmail.com","consumerId": "'+con.Id+'","consumerName": "Contact PT 2","isSelected": true}]';
     	Map<String, Object> resultMap = NC_InformationSessionConsumerRequest.sendInviationToConsumer(data, outreach.id);
        System.assertNotEquals(null, resultMap.get('success'));
        
        String data2 = '[{"consumerEmailId": "ncdhdss@gmail.com","consumerId": "'+con.Id+'","consumerName": "Contact PT 2","isSelected": false}]';
        Map<String, Object> resultMap2 = NC_InformationSessionConsumerRequest.sendInviationToConsumer(data2, outreach.id);
        System.assertNotEquals(null, resultMap2.get('error'));
    }
}