/*
**   Class Name: NC_StaffingRequestTrigger
**   Description: Trigger on Staffing_Request__c
**
**     Date            New/Modified           User                 Identifier                Description
**  06-04-2020             New          Hiten Aggarwal(mtx)
*/
trigger NC_StaffingRequestTrigger on Staffing_Request__c (before update, after update, after insert, after delete, after undelete) {
    
    // Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Staffing_User_Request__c');
    
    // Trigger on Before Update 
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(trigger.isBefore && trigger.isUpdate) {
            NC_StaffingRequestTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    
    // Trigger on After Update 
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(trigger.isAfter) {
            if( trigger.isUpdate){
                NC_StaffingRequestTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
                NC_StaffingRequestTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new,null);
            }
        }
    }

    //After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(Trigger.isAfter && Trigger.isInsert){
            NC_StaffingRequestTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new,null);
        }
    }

    //After Delete
    if(triggerSupport == null || !triggerSupport.After_Delete__c){
        if(Trigger.isAfter && Trigger.isDelete){
            NC_StaffingRequestTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.old, null);
        }
    }

    //After Un Delete
    if(triggerSupport == null || !triggerSupport.After_UnDelete__c){
        if(Trigger.isAfter && Trigger.isUpdate){
            NC_StaffingRequestTriggerHandler.rollUpOnDelete(Trigger.new);
        }
    }

}