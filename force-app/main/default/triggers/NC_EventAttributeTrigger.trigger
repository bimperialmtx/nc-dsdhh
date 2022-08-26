/*
*   Class Name: NC_EventAttributeTrigger
*   Description: Event Trigger Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   26/05/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_EventAttributeTrigger on Event_Attribute__c (before update) {
    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Event_Attribute__c');

    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_EventAttributeTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

}