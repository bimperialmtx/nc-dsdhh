/**
* @description       : Test class for nc_DSDHHUnsubscribeController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class nc_DSDHHUnsubscribeControllerTest {

    /*
    *********************************************************
    @Method Name    : getApplicationRecordsTest
    @description    : Verify contact details by passing encrypted id
    ********************************************************
    */
    static testmethod void getApplicationRecordsTest() {
        Contact con = TestDataUtility.createConsumer(true);
        Contact conResult = nc_DSDHHUnsubscribeController.getApplicationRecords(NC_CryptoEncryption.encodeString(con.id));
        nc_DSDHHUnsubscribeController.saveData(con);
        System.assertNotEquals(null, conResult);
    }
    
    /*
    *********************************************************
    @Method Name    : fatchMultiPicklistTest
    @description    : Verify case status values
    ********************************************************
    */
    static testmethod void fatchMultiPicklistTest() {
        List<nc_DSDHHUnsubscribeController.SelectOptionWrapper> resultList = nc_DSDHHUnsubscribeController.fatchMultiPicklist('Case', 'Status');
        System.assertNotEquals(0, resultList.size());
    }
}