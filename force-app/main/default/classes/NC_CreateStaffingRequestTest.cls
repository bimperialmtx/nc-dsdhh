/**
* @description       : Test class for NC_CreateStaffingRequest
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CreateStaffingRequestTest {

    /*
    *********************************************************
    @Method Name    : retrieveDefaultsForInternalTest
    @description    : Verify creation of internal Staffing request
    ********************************************************
    */
    static testmethod void retrieveDefaultsForInternalTest() {
        Id commReqTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commReqTypeId, 'SSP', null);
        
        Map<String,Object> resultMap = NC_CreateStaffingRequest.retrieveDefaultsForInternal(commReq.id);
        System.assertEquals(true, resultMap.get('forCommunication'));
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveDefaultsForExternalTest
    @description    : Verify creation of external Staffing request
    ********************************************************
    */
    static testmethod void retrieveDefaultsForExternalTest() {
        Id commReqTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Request_For_Training_Vendor').getRecordTypeId();
        Communication_Access_Request__c commReq = TestDataUtility.createCommunicationAcessRequest(true, commReqTypeId, 'NDBEDP Training', null);
        Map<String,Object> resultMap = NC_CreateStaffingRequest.retrieveDefaultsForExternal(commReq.id);
        System.assertEquals(true, resultMap.get('forCommunication'));
    }
}