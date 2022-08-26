/*
*   Class Name: NC_InvoiceTrigger
*   Description: Invoice Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   25/05/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_InvoiceTrigger on Invoice__c (before update, after update, after insert, after delete, after undelete) {
    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Invoice__c');

    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_InvoiceTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
        }
    }
    
    //afterUpdate
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isUpdate && Trigger.isAfter){
            NC_InvoiceTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
            NC_InvoiceTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new,null);
        }
    }

    //After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(Trigger.isAfter && Trigger.isInsert){
            NC_InvoiceTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new,null);
        }
    }

    //After Un Delete
    if(triggerSupport == null || !triggerSupport.After_UnDelete__c){
        if(Trigger.isAfter && Trigger.isUpdate){
            NC_InvoiceTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new, null);
        }
    }

    //After Delete
    if(triggerSupport == null || !triggerSupport.After_Delete__c){
        if(Trigger.isAfter && Trigger.isDelete){
            NC_InvoiceTriggerHandler.rollUpOnDelete(Trigger.old);
        }
    }

    
}