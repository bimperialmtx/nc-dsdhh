/*
**   Class Name: NC_StaffingUserRequestTrigger
**   Description: Trigger on Staffing_User_Request__c
**
**     Date            New/Modified           User                 Identifier                Description
**  06-04-2020             New          Hiten Aggarwal(mtx)
*/

trigger NC_StaffingUserRequestTrigger on Staffing_User_Request__c (before update, after insert, after update) {

    // Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Staffing_User_Request__c');
    
    // Trigger on After Insert 
    if(triggerSupport == null || !triggerSupport.After_Insert__C){
        if(trigger.isAfter) {
            if( trigger.isInsert){
                NC_StaffingUserRequestTriggerHandler.afterInsert(Trigger.new);
            }
        }
    }

    // Trigger on After Update 
    if(triggerSupport == null || !triggerSupport.After_Update__C){
        if(trigger.isAfter) {
            if( trigger.isUpdate){
                NC_StaffingUserRequestTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
    
    // Trigger on before Insert 
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(trigger.isBefore) {
            if( trigger.isUpdate){
                NC_StaffingUserRequestTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
            }
        }
    }
    
}