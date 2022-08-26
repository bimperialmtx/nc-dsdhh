/*
*   Class Name: NC_OutreachRequestTrigger
*   Description: Outreach Request Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   25/05/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_OutreachRequestTrigger on Outreach_Request__c (before update) {
    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Outreach_Reqest__c');

    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_OutreachRequestTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}