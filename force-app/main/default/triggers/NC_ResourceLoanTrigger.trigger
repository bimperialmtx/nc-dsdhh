trigger NC_ResourceLoanTrigger on Resource_Loan__c (before insert, before update, after insert, after update) {

    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Resource_Loan__c');

    //Before Insert
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(Trigger.isInsert && Trigger.isBefore){
            NC_ResourceLoanTriggerHandler.beforeInsert(Trigger.new);
        }
    }
    
    //After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(Trigger.isInsert && Trigger.isAfter){
            NC_ResourceLoanTriggerHandler.afterInsert(Trigger.new);
        }
    }

    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_ResourceLoanTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    
    //After Update
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isUpdate && Trigger.isAfter){
            NC_ResourceLoanTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}