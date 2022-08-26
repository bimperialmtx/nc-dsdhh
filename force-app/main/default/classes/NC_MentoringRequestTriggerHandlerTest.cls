/**
* @description       : Test class for NC_MentoringRequestTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_MentoringRequestTriggerHandlerTest {

    /*
    *********************************************************
    @Method Name    : createRequestCommentTest
    @description    : Verify Mentoring Request validation for create and update
    ********************************************************
    */
    static testmethod void createRequestCommentTest() {
        Contact con = TestDataUtility.createConsumer(true);
        Case request = TestDataUtility.createNDBEDPCase(false, con.id);
        request.Comments__c = 'test';
        insert request;
        
        Mentoring_Request__c mentoringRequest = TestDataUtility.createMentoringRequest(true, con.id, request.id);
        mentoringRequest.comments__c = 'test';
        update mentoringRequest;
        
        List<Mentoring_Request__c> resultList = [SELECT Consumer__c FROM Mentoring_Request__c WHERE Id =: mentoringRequest.id];
        System.assertNotEquals(null, resultList[0].Consumer__c);
    }
}