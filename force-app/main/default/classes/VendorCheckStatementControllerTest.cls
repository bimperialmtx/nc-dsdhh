/**
* @description       : Test class for VendorCheckStatementController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class VendorCheckStatementControllerTest {
    
    /*
    *********************************************************
    @Method Name    : markStatementPrintedAndMailedTest
    @description    : Verify check statement marked printed or mailed
    ********************************************************
    */
    static testmethod void markStatementPrintedAndMailedTest() {
        C1_Check_Statement__c checkStatement = TestDataUtility.createCheckStatement(true, null, true);
        C1_Check_Statement__c result = VendorCheckStatementController.markStatementPrintedAndMailed(checkStatement.id, true, true);
        System.assertEquals(true, result.Printed__c);
        System.assertEquals(true, result.Mailed__c);
    }
    
    /*
    *********************************************************
    @Method Name    : markStatementPrintedAndMailedTest
    @description    : Verify check statement records related to vendor
    ********************************************************
    */
    static testmethod void retrieveCheckStatementsTest() {
        C1_Check_Statement__c checkStatement = TestDataUtility.createCheckStatement(true, null, false);
        checkStatement.Printed__c = true;
        checkStatement.Mailed__c = true;
        insert checkStatement;
        TestDataUtility.createContentDocumentLink(checkStatement.id, true);
        Integer month = Date.today().month();
        Integer year = Date.today().year();
        Map<String,Object> resultMap = VendorCheckStatementController.retrieveCheckStatements(checkStatement.Vendor__c, 0, 5, null, month, year, true, true, false);
        System.assertNotEquals(null, resultMap.get('records'));
    }
}