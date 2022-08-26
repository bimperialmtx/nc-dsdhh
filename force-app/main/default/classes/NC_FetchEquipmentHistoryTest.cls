/**
* @description       : Test class for NC_FetchEquipmentHistory
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_FetchEquipmentHistoryTest {

    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Verify equipment history data creation from mock
    ********************************************************
    */
    static testmethod void fetchEquipmentHistoryTest() {
        Contact con = TestDataUtility.createConsumer(false);
        con.Patron_ID__c = 'test';
        insert con;
        
        Id eqpTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(false, eqpTypeId, null, 'Test', 'NDBEDP', 100);
        eqp.BibRecObj__c = '575390.123';
        insert eqp;
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentHistoryMock());
        
        test.startTest();
        Map<String, Object> resultMap = NC_FetchEquipmentHistory.fetchEquipmentHistory(con.id);
        
        test.stopTest();
        System.assertNotEquals(0, resultMap.size());
    }
}