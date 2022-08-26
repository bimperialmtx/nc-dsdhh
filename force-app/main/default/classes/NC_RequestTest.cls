/**
* @description       : Test class for NC_Request
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_RequestTest {

    /*
    *********************************************************
    @Method Name    : getConsumerNameTest
    @description    : Verify consumer name from consumer id
    ********************************************************
    */
    static testmethod void getConsumerNameTest() {
        Contact conObj = TestDataUtility.createConsumer(true);
        Map<String,Object> result = NC_Request.getConsumerName(conObj.id);
        System.assertEquals(true, result.size()>0);
    }
    
    /*
    *********************************************************
    @Method Name    : getRecordTypeIdTest
    @description    : Verify ndbedp request record type id
    ********************************************************
    */
    static testmethod void getRecordTypeIdTest() {
        Id ndbedpTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDBEDP').getRecordTypeId();
        String res = NC_Request.getRecordTypeId('');
        System.assertEquals(null, res);
        String result = NC_Request.getRecordTypeId('NDBEDP');
        System.assertEquals(ndbedpTypeId, result);
    }
    
    /*
    *********************************************************
    @Method Name    : saveDataTest
    @description    : Verify ndbedp request data save
    ********************************************************
    */
    static testmethod void saveDataTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);        
        String data = '{"consumerName":"Test Test","requestType":"NDBEDP","EquipmentTypes":null,"contactId":"'+caseObj.contactId+'"}';
        Map<Id,Boolean> resultMap = NC_Request.saveData(data);
        System.assertNotEquals(0, resultMap.size());
        
        
        Contact conObj = TestDataUtility.createConsumer(false);
        conObj.LastName = 'Test Jr';
        insert conObj;
        Id edsRequestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        TestDataUtility.createCase(true, edsRequestTypeId, conObj.id, 'EDS', 'Telephone');
        String data2 = '{"consumerName":"Test Test","requestType":"EDS","EquipmentTypes":["Telephone"],"contactId":"'+conObj.id+'"}';
        Map<Id,Boolean> resultMap2 = NC_Request.saveData(data2);
        System.assertNotEquals(0, resultMap2.size());
    }
}