/**
* @description       : Test class for NC_CreateConsumerResourceLoan
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CreateConsumerResourceLoanTest {

    /*
    *********************************************************
    @Method Name    : retrieveDefaultsTest
    @description    : Verify creation of resource loan based on related consumer data
    ********************************************************
    */
    static testmethod void retrieveDefaultsTest() {
        Contact con = TestDataUtility.createConsumer(true);
     	Map<String,Object> resultMap = NC_CreateConsumerResourceLoanController.retrieveDefaults(con.id);
        System.assertEquals(true, resultMap.get('forConsumer'));
      
        Account acc = TestDataUtility.createVendor(true);
        Map<String,Object> resultMap1 = NC_CreateConsumerResourceLoanController.retrieveDefaults(acc.id);
        System.assertEquals(false, resultMap1.get('forConsumer'));
        
        Contact contact=new Contact();
        contact.FirstName='Test Contact';
        contact.LastName='Test';
        contact.AccountId=acc.Id;
        insert contact;
        Map<String,Object> resultMap2 = NC_CreateConsumerResourceLoanController.retrieveDefaults(contact.id);
        System.assertEquals(true, resultMap2.get('forConsumer'));
    }
}