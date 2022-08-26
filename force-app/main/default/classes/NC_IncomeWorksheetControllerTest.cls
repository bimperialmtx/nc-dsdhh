/**
* @description       : Test class for NC_IncomeWorksheetController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_IncomeWorksheetControllerTest {

    /*
    *********************************************************
    @Method Name    : fetchContactDataTest
    @description    : Verify request and contact are valid for creation of income worksheet
    ********************************************************
    */
    static testmethod void fetchContactDataTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        TestDataUtility.createFamilyDetails(true, caseObj.id, caseObj.ContactId);
        Test.startTest();
        Map<String,Object> resultMap = NC_IncomeWorksheetController.fetchContactData(caseObj.id);
        
        Contact con = new Contact();
        con.id = caseObj.ContactId;
        con.Proof_of_Income_Provided_By__c = 'W-2 or W-4 Form';
        update con;
        Map<String,Object> resultMap2 = NC_IncomeWorksheetController.fetchContactData(caseObj.id);
        Test.stopTest();
        System.assertEquals(true, resultMap.get('showErroMessage'));
    }
    
    /*
    *********************************************************
    @Method Name    : updateContactDataTest
    @description    : Verify creation of income worksheet data and update of related request
    ********************************************************
    */
    static testmethod void updateContactDataTest() {
        String data = '[{"name":"Test","age":25,"relationship":"Relative","totalIncome":600,"incomeType":{"Gross_Salary_and_Wages":500,"Unemployment":0,"Social_Security":100,"Veterans_Administration":0,"Retirement_Pension":0,"Worker_Compensation_payments":0,"Alimony":0,"Rental_Income":0,"Child_support":0,"On_the_Job_training":0,"AmeriCorps_Stipends":0,"Armed_Forces_pay":0,"Work_Release_Payments":0,"Tobacco_buy_out_payments":0,"Annuities":0,"Cherokee":0}}]';
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        Map<String,Object> resultMap = NC_IncomeWorksheetController.updateContactData(data, caseObj.id);
        System.assertEquals('Family Members Added', resultMap.get('success'));
        NC_IncomeWorksheetController.incomeType incomeType = new NC_IncomeWorksheetController.incomeType();
        NC_IncomeWorksheetController.FamilyDetailsWrapper wrap = new NC_IncomeWorksheetController.FamilyDetailsWrapper();
    }
    
    /*
    *********************************************************
    @Method Name    : updateContactData2Test
    @description    : Verify NDBEDP request income validations
    ********************************************************
    */
    static testmethod void updateContactData2Test() {
        String data = '[{"name":"Test","age":25,"relationship":"Relative","totalIncome":600000,"incomeType":{"Gross_Salary_and_Wages":600000,"Unemployment":0,"Social_Security":100,"Veterans_Administration":0,"Retirement_Pension":0,"Worker_Compensation_payments":0,"Alimony":0,"Rental_Income":0,"Child_support":0,"On_the_Job_training":0,"AmeriCorps_Stipends":0,"Armed_Forces_pay":0,"Work_Release_Payments":0,"Tobacco_buy_out_payments":0,"Annuities":0,"Cherokee":0}}]';
        String data2 = '[{"name":"Test","age":25,"relationship":"Relative","totalIncome":600,"incomeType":{"Gross_Salary_and_Wages":600,"Unemployment":0,"Social_Security":100,"Veterans_Administration":0,"Retirement_Pension":0,"Worker_Compensation_payments":0,"Alimony":0,"Rental_Income":0,"Child_support":0,"On_the_Job_training":0,"AmeriCorps_Stipends":0,"Armed_Forces_pay":0,"Work_Release_Payments":0,"Tobacco_buy_out_payments":0,"Annuities":0,"Cherokee":0}}]';
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        Test.startTest();
        Map<String,Object> resultMap = NC_IncomeWorksheetController.updateContactData(data, caseObj.id);
        Map<String,Object> resultMap2 = NC_IncomeWorksheetController.updateContactData(data2, caseObj.id);
        Test.stopTest();
        System.assertEquals('Family Members Added', resultMap.get('success'));
    }
    
    /*
    *********************************************************
    @Method Name    : updateContactData3Test
    @description    : Verify EDS request income validations
    ********************************************************
    */
    static testmethod void updateContactData3Test() {
        String data = '[{"name":"Test","age":25,"relationship":"Relative","totalIncome":600000,"incomeType":{"Gross_Salary_and_Wages":600000,"Unemployment":0,"Social_Security":100,"Veterans_Administration":0,"Retirement_Pension":0,"Worker_Compensation_payments":0,"Alimony":0,"Rental_Income":0,"Child_support":0,"On_the_Job_training":0,"AmeriCorps_Stipends":0,"Armed_Forces_pay":0,"Work_Release_Payments":0,"Tobacco_buy_out_payments":0,"Annuities":0,"Cherokee":0}}]';
        String data2 = '[{"name":"Test","age":25,"relationship":"Relative","totalIncome":600,"incomeType":{"Gross_Salary_and_Wages":600,"Unemployment":0,"Social_Security":100,"Veterans_Administration":0,"Retirement_Pension":0,"Worker_Compensation_payments":0,"Alimony":0,"Rental_Income":0,"Child_support":0,"On_the_Job_training":0,"AmeriCorps_Stipends":0,"Armed_Forces_pay":0,"Work_Release_Payments":0,"Tobacco_buy_out_payments":0,"Annuities":0,"Cherokee":0}}]';
        
        Contact con = TestDataUtility.createConsumer(true);
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case caseObj = TestDataUtility.createCase(true, requestTypeId, con.id, 'EDS', 'Telephone');
        Test.startTest();
        Map<String,Object> resultMap = NC_IncomeWorksheetController.updateContactData(data, caseObj.id);
        Map<String,Object> resultMap2 = NC_IncomeWorksheetController.updateContactData(data2, caseObj.id);
        Test.stopTest();
        System.assertEquals('Family Members Added', resultMap.get('success'));
    }
    
    /*
    *********************************************************
    @Method Name    : fetchPicklistTest
    @description    : Verify status values of case
    ********************************************************
    */
    static testmethod void fetchPicklistTest() {
        List<NC_IncomeWorksheetController.SelectOptionWrapper> resultList = NC_IncomeWorksheetController.fetchPicklist('Case', 'Status');
        System.assertNotEquals(0, resultList.size());
    }
}