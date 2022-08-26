/*
*   Class Name: NC_BudgetManagementTrigger
*   Description: Budget Management Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   06/08/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_BudgetManagementTrigger on Budget_Management__c (after update, before insert) {
    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Budget_Management__c');
    
    //afterUpdate
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isUpdate && Trigger.isAfter){
            NC_BudgetManagementTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    //afterUpdate
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(Trigger.isInsert && Trigger.isBefore){
            NC_BudgetManagementTriggerHandler.beforeInsert(Trigger.new);
        }
    }
}