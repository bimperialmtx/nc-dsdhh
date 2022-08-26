/**
* @description       : Test class for NC_ResourceTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_ResourceTriggerHandlerTest {
    /*
    *********************************************************
    @Method Name    : NC_ResourceTriggerHandlerTest1
    @description    : Verify Resource validations for create and update
    ********************************************************
    */
    static testmethod void NC_ResourceTriggerHandlerTest1() {
        Account rc = TestDataUtility.createRegionalCenter(true);
        Resource__c resource = TestDataUtility.createResource(false, 'Test', 'Equipment', rc.id);
        resource.Status__c = 'In Process';
        Insert resource;
        resource.Barcode_Affixed__c = true;
        resource.Barcode_Printed__c = true;
        resource.Category__c = 'Material/Media';
        update resource;
        
        Account rc2 = TestDataUtility.createRegionalCenter(true);
        resource.Category__c = 'Demo Equipment';
        resource.Regional_Center__c = rc2.id;
        update resource;
        
        List<Resource__c> resultList = [SELECT Bar_Code_Number__c FROM Resource__c LIMIT 1];
        System.assertNotEquals(null, resultList[0].Bar_Code_Number__c);
    }
    
    /*
    *********************************************************
    @Method Name    : NC_ResourceTriggerHandlerTest2
    @description    : Verify Resource validations for create and update
    ********************************************************
    */
        static testmethod void NC_ResourceTriggerHandlerTest2() {
            
            Contact con = TestDataUtility.createConsumer(true);
            Account regionalCenter = TestDataUtility.createRegionalCenter(true);
            Resource__c resource = TestDataUtility.createResource(true, 'Test Resource', 'Equipment', regionalCenter.id);
            Id consumerLoanTypeId = Schema.SObjectType.Resource_Loan__c.getRecordTypeInfosByDeveloperName().get('Consumer_Resource_Loan').getRecordTypeId();
            Resource_Loan__c resourceLoan = TestDataUtility.createResourceLoan(true, consumerLoanTypeId, 'Equipment', null, regionalCenter.id, con.id);
            
            resourceLoan.Priority__c = 'High';
            resourceLoan.Status__c = 'Waitlist';
            update resourceLoan;
            
            String listValue = 'Equipment';
            Set<String> stringList = new Set<String>();
            stringList.add(listValue);
			NC_ResourceTriggerHandler.notifieResourceLoanOwners(stringList);
            Resource__c res=[SELECT Id,Regional_Center__c FROM Resource__c LIMIT 1];
            System.assertEquals(true,res.Regional_Center__c!=null);
    }

}