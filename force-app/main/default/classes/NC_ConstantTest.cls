/**
* @description       : Test class for NC_Constant
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_ConstantTest {
	
    /*
    *********************************************************
    @Method Name    : getRecordTypeForInvoiceTest
    @description    : Verify invoice record types
    ********************************************************
    */
    static testmethod void getRecordTypeForInvoiceTest() {
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id invTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Invoice__c inv = TestDataUtility.createInvoice(true, invTypeId, auth.Id);
        
        List<String> groupCodeList = NC_Constant.groupCodeList;
        map<String,String> labelToFieldMaping = NC_Constant.labelToFieldMaping;
        map<String,String> invoiceRecordTypeToBudgetAmountType = NC_Constant.invoiceRecordTypeToBudgetAmountType;
        Map<String, Boolean> resultMap = NC_Constant.getRecordTypeForInvoice(inv.id);
        System.assertNotEquals(null, resultMap);
    }
    
    /*
    *********************************************************
    @Method Name    : GetRequestRecordTypeIdTest
    @description    : Verify Case record types and other utilities
    ********************************************************
    */
    static testmethod void GetRequestRecordTypeIdTest() {
        Id ndbedpTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        
        Id result1 = NC_Utility.RecordTypeUtilityMethod('Case', 'NDBEDP');
        System.assertEquals(ndbedpTypeId, result1);
        
        Id result2 = NC_Utility.GetRequestRecordTypeId('NDBEDP');
        System.assertEquals(ndbedpTypeId, result2);
        
        Id result3 = NC_Utility.getProfileId('System Administrator');
        System.assertNotEquals(null, result3);
        
        List<Schema.FieldSetMember> result4 = NC_Utility.getFieldSet('Account', 'Electronic_Pay_Vendor');
        System.assertNotEquals(null, result4);
        
        Date result5 = NC_Utility.calculateCurrentFiscalYearStartDate(System.today());
        System.assertNotEquals(null, result5);
        
        Map<Id,String> result6 = NC_Utility.getRegionalCenterIdToNameMap();
        System.assertNotEquals(null, result6);
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveValueTest
    @description    : Verify retriving value by field name
    ********************************************************
    */
    static testmethod void retrieveValueTest() {
        Case request = TestDataUtility.createNDBEDPCase(true);
        Object obj1 = NC_ValidationUtility.retrieveValue(request, 'ContactId');
        System.assertNotEquals(null, obj1);
    }
    
    /*
    *********************************************************
    @Method Name    : validationTest
    @description    : Verify request validations from metadata
    ********************************************************
    */
    static testmethod void validationTest() {
        Case request = TestDataUtility.createNDBEDPCase(true);

        List<Validation_Configuration__mdt> dataList = [select id, Error_Message__c, Field_API_Name__c, Field_Set_Name__c, Field_Value__c, Is_Active__c, Object_API_Name__c, Operator__c, Record_Type_Developer_Name__c, Required_Field_API_Name__c from Validation_Configuration__mdt];
        Map<String, List<Validation_Configuration__mdt>> mapOfObjectWithListOfValidation = new Map<String, List<Validation_Configuration__mdt>>();
        mapOfObjectWithListOfValidation.put('Case', dataList);
        String result = NC_ValidationUtility.validation(request, 'Case', mapOfObjectWithListOfValidation);
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveLabelTest
    @description    : Verify request validations field label from metadata
    ********************************************************
    */
    static testmethod void retrieveLabelTest() {
        Map<String, Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();
        Map<String,Schema.SobjectField> fieldsMap = globalDescribe.get('Case').getDescribe().fields.getMap();
        
        String result1 = NC_ValidationUtility.retrieveLabel(globalDescribe, 'Contact.FirstName', fieldsMap);
        System.assertNotEquals(null, result1);
        
        String result2 = NC_ValidationUtility.retrieveLabel(globalDescribe, 'ContactId', fieldsMap);
        System.assertNotEquals(null, result2);
    }
    
    /*
    *********************************************************
    @Method Name    : getTriggerSupportTest
    @description    : Verify trigger support validations
    ********************************************************
    */
    static testmethod void getTriggerSupportTest() {
        TriggerSupport__mdt data = NC_BaseController.getTriggerSupport('test');
        System.assertEquals(null, data);
    }
}