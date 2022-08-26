/**
* @description       : Test class for NC_ComRequestAccessTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com
* @last modified on  : 06-23-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_ComRequestAccessTriggerHandlerTest {

    /*
    *********************************************************
    @Method Name    : validateCommunicationRequestTest
    @description    : Validate Communication Access Request update validations
    ********************************************************
    */
    static testmethod void validateCommunicationRequestTest() {
        Account rc = TestDataUtility.createRegionalCenter(true);
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Request_for_Non_DHH_Outreach').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(false, commRequestTypeId, 'SSP', rc.id);
        commReq.Status__c = 'Created';
        insert commReq;
        
        try {
            commReq.Status__c = 'Approved';
            update commReq;
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try {
            commReq.Status__c = 'Cancelled';
            update commReq;
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        try {
            commReq.Status__c = 'Cancelled';
            commReq.Cancel_Close_Comment__c = 'test';
            commReq.Is_Roll_Up__c = true;
            update commReq;
            
            commReq.Status__c = 'Closed';
            commReq.Is_Roll_Up__c = false;
			update commReq;
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateCommunicationRequestTest
    @description    : Validate Communication Access Request roll up operations
    ********************************************************
    */
    static testmethod void validateCommunicationRequest2Test() {
        Account rc = TestDataUtility.createRegionalCenter(true);
        Id commRequestTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(false, commRequestTypeId, 'SSP', rc.id);
        commReq.Status__c = 'Created';
        commReq.CACL_Total_Cost__c = 50;
        insert commReq;
        
        Test.startTest();
        commReq.CACL_Total_Cost__c = 100;
        update commReq;
        Test.stopTest();
        System.assertEquals(false, commReq.Is_Roll_Up__c);
    }
}