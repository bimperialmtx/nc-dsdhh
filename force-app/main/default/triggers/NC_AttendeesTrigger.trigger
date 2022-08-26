trigger NC_AttendeesTrigger on Attendees__c (after insert, before update, after update, before insert) {
   

    if(trigger.isafter) {
        if( trigger.isUpdate){
            NC_AttendeesTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }

    if(trigger.isAfter) {
        if( trigger.isInsert){
            NC_AttendeesTriggerHandler.afterInsert(Trigger.new);
        }
    }
    if(trigger.isBefore) {
        if( trigger.isUpdate){
            NC_AttendeesTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    if(trigger.isBefore) {
        if( trigger.isInsert){
            NC_AttendeesTriggerHandler.beforeInsert(Trigger.new);
        }
    }
   
}