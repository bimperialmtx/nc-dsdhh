/**
* @description       : Test class for NC_BudgetManagementTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_BudgetManagementTriggerHandlerTest {
    /*
*********************************************************
@Method Name    : getAllLineItemsTest
@description    : Verify Budget Management validation
********************************************************
*/
    static testmethod void getAllLineItemsTest() {    
        Budget_Management__c budget = TestDataUtility.createBudgetManagement(true, 'SSP Budget');
        TestDataUtility.createBudgetAmount(true, budget.id, 10);
        budget.Amount_Utilized__c = 10;
        update budget;
        
        Id assessmentAuthTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, assessmentAuthTypeId);
        Set<Id> authList = new Set<Id>();
        authList.add(auth.Id);
        
        TestDataUtility.createBudgetAmount(true, budget.id, 10);
        budget.Amount_Utilized__c = 10;
        update budget;
        System.assertEquals('SSP Budget', budget.Budget_Type__c);
    }
    
}