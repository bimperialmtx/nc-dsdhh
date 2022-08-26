/*
**   Class Name: NC_BudgetManagementTriggerHandler
**   Description: Budeget Management Trigger Handler
**
**     Date            New/Modified           User                 Identifier               Description
**   06-08-2020             New             Shubham Dadhich
*/
public without sharing class NC_BudgetManagementTriggerHandler {
    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'befoer Insert' trigger event
    @param          : List<Budget_Management__c> newList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Budget_Management__c> newList){
        validateRecord(newList);
    }

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<Budget_Management__c> newList, Map<Id, Budget_Management__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Budget_Management__c> newList, Map<Id, Budget_Management__c> oldMap){
        List<Budget_Management__c> listOfUpdatedBudgetAmount = new List<Budget_Management__c>();
        List<Budget_Management__c> listOfUpdatedBudgetAmountStaffing = new List<Budget_Management__c>();
        List<Budget_Management__c> listOfBudgetToiBeNotified = new List<Budget_Management__c>();
        for(Budget_Management__c budgetManagement : newList){
            if(budgetManagement.Budget_Type__c != NC_Constant.NDBEDP_BUDGET && NC_Constant.listOfBudgetTypeForEquipment.contains(budgetManagement.Budget_Type__c) && budgetManagement.Total_Amount__c != oldMap.get(budgetManagement.Id).Total_Amount__c){
                listOfUpdatedBudgetAmount.add(budgetManagement);
            }else if(NC_Constant.listOfBudgetTypeForStaffing.contains(budgetManagement.Budget_Type__c) && budgetManagement.Total_Amount__c != oldMap.get(budgetManagement.Id).Total_Amount__c){
                listOfUpdatedBudgetAmountStaffing.add(budgetManagement);
            }

            if(budgetManagement.Budget_Type__c != NC_Constant.NDBEDP_BUDGET && budgetManagement.Amount_Remaining__c != oldMap.get(budgetManagement.Id).Amount_Remaining__c && budgetManagement.Amount_Remaining__c < budgetManagement.X10_Amount__c){
                listOfBudgetToiBeNotified.add(budgetManagement);
            }
        }
        if(!listOfUpdatedBudgetAmount.isEmpty()){
            NC_BudgetManagementController.updateAllHoldAuthorizationsAndInvoice(JSON.serialize(listOfUpdatedBudgetAmount));
        }
        if(!listOfUpdatedBudgetAmountStaffing.isEmpty()){
            NC_BudgetManagementController.updateAllInvoiceAndAuthStaffing(JSON.serialize(listOfUpdatedBudgetAmountStaffing));
        }
        if(!listOfBudgetToiBeNotified.isEmpty()){
            notifyeBudgetManager(listOfBudgetToiBeNotified);
        }
    }

    /*
    *********************************************************
    @Method Name    : notifyeBudgetManager
    @description    : notifiying the Budget manager
    @param          : List<Budget_Management__c> newList
    @return         : void
    ********************************************************
    */
    public static void notifyeBudgetManager(List<Budget_Management__c> newList){
        List<NC_BudgetManagementController.budgetNotifier> budgetNotifierList = new List<NC_BudgetManagementController.budgetNotifier>();
        NC_BudgetManagementController.budgetNotifier budgetNotifierRecord;
        for(Budget_Management__c budgetManagement : newList){
            if(budgetManagement.Amount_Remaining__c <= budgetManagement.X10_Amount__c){
                budgetNotifierRecord = new NC_BudgetManagementController.budgetNotifier();
                budgetNotifierRecord.UserId = budgetManagement.OwnerId;
                budgetNotifierRecord.BudgetId = budgetManagement.Id;
                //budgetNotifierRecord.budgetMessage = NC_Constant.BUDGET_NOTIFIER_BODY;
                budgetNotifierRecord.budgetMessage = 'The budget for '+ budgetManagement.Budget_Type__c + 'is now obligated at 90%. Please log into SMS to view the details and make the necessary adjustments.';
                budgetNotifierRecord.budgetURL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Budget_Management__c/' + budgetManagement.Id + '/view';
                budgetNotifierRecord.budgetName = budgetManagement.Budget_Type__c;
                budgetNotifierList.add(budgetNotifierRecord);
            }
        }

        NC_SendBulkEmail.notifieBudgetManagerOnBudgetLow(budgetNotifierList);

    }

    /*
    *********************************************************
    @Method Name    : validateRecord
    @description    : validate Redord Already Exist or Not for the Same Fiscal Year
    @param          : List<Budget_Management__c> newList
    @return         : void
    ********************************************************
    */
    public static void validateRecord(List<Budget_Management__c> newList){
        Map<String, List<Date>> mapOfTypeWithDate = new Map<String, List<Date>>();
        for(Budget_Management__c budget : [SELECT Id, Start_Date_Fiscal_Year__c, Budget_Type__c FROM Budget_Management__c WITH SECURITY_ENFORCED]){
            if(!mapOfTypeWithDate.containsKey(budget.Budget_Type__c)){
                mapOfTypeWithDate.put(budget.Budget_Type__c, new List<Date>());
            }
            mapOfTypeWithDate.get(budget.Budget_Type__c).add(budget.Start_Date_Fiscal_Year__c);
        }
        for(Budget_Management__c budget : newList){
            Map<String,Date> result = getStartAndEndDate(budget.Budget_Year__c);
            budget.Start_Date_Fiscal_Year__c = result.get('startDate');
            budget.End_Date_Fiscal_Year__c = result.get('endDate');
            if(mapOfTypeWithDate.containsKey(budget.Budget_Type__c)){
                if(mapOfTypeWithDate.get(budget.Budget_Type__c).contains(budget.Start_Date_Fiscal_Year__c)){
                    budget.addError(budget.Budget_Type__c +' already exist for the fiscal year '+ budget.Budget_Year__c + '.');
                }
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : getStartAndEndDate
    @description    : get Start and End Date Of Budget
    @param          : String yearNumber
    @return         : void
    ********************************************************
    */
    private static Map<String,Date> getStartAndEndDate(String yearNumber){
        Map<String,Date> result = new Map<String,Date>();
        Date startDate =   Date.newInstance(Integer.valueOf(yearNumber), 7, 1); // Fiscal Year Start From 1th July
        Date endDate = Date.newInstance(Integer.valueOf(yearNumber)+1, 6, 30); // Fiscal Year End On 30th June
        result.put('startDate',startDate);
        result.put('endDate',endDate);
        return result;
    }


}