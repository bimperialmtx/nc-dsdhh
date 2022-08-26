/*
*   Class Name: NC_AppointmentTrigger
*   Description: Appointment__c Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   20/05/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_AppointmentTrigger on Appointment__c (before insert) {
    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Appointment__c');

    //Before Insert
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(Trigger.isInsert && Trigger.isBefore){
            NC_AppointmentTriggerHandler.beforeInsert(Trigger.new);
        }
    }
}