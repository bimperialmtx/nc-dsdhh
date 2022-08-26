/**
* @description       : Test class for NC_Open_DocumentController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_Open_DocumentControllerTest {

    /*
    *********************************************************
    @Method Name    : getPageURLTest
    @description    : Verify hearing aid or non hearing aid authorization letter
    ********************************************************
    */
    static testmethod void getPageURLTest() {
        Id hearingAidTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Authorization__c auth1 = TestDataUtility.createAuthorization(true, hearingAidTypeId);
        
        Id edsTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Authorization__c auth2 = TestDataUtility.createAuthorization(true, edsTypeId);
        
        String result1 = NC_Open_DocumentController.getPageURL(auth1.id);
        System.assertNotEquals(null, result1);
        String result2 = NC_Open_DocumentController.getPageURL(auth2.id);
        System.assertNotEquals(null, result2);
    }
}