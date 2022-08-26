/*
*   Class Name: NC_EventAttributeTriggerHandler
*   Description: Event Attribute Trigger Handler -- Logics on insert, update and delete
*
*   Date            New/Modified         User                 Identifier                Description
*   26/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_EventAttributeTriggerHandler {
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Event_Attribute__c> newEventAttributeList, Map<Id, Event_Attribute__c> oldEventAttributeMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Event_Attribute__c> newEventAttributeList, Map<Id, Event_Attribute__c> oldEventAttributeMap){
        validateEventAttributeApproval(newEventAttributeList,oldEventAttributeMap);
        validateRecord(newEventAttributeList,oldEventAttributeMap);
        checkEventAttributeStatus(newEventAttributeList,oldEventAttributeMap);
    }

    /*
    *********************************************************
    @Method Name    : validateRecord
    @description    : Validate Record for Submit For Approval record Type Should be Public Communication
    @param          : List<Event_Attribute__c> newEventAttributeList, Map<Id, Event_Attribute__c> oldEventAttributeMap
    @return         : void
    ********************************************************
    */
    public static void validateRecord(List<Event_Attribute__c> newEventAttributeList, Map<Id, Event_Attribute__c> oldEventAttributeMap) {
        Id eventAttributeRecordIdPublicCommunication = NC_Utility.RecordTypeUtilityMethod('Event_Attribute__c','Public_Communication');
        for(Event_Attribute__c eventAttribute : newEventAttributeList){
            if(eventAttribute.RecordTypeId == eventAttributeRecordIdPublicCommunication){
                if(eventAttribute.Status__c == NC_Constant.EVENT_ATTRIBUTE_STATUS_REGIONAL_CENTER_REVIEW && !eventAttribute.Public_Communication_Uploaded__c){
                    eventAttribute.addError(NC_Constant.EVENT_ATTRIBUTE_TRIGGER_ERROR_PUBLIC_COMMUNICATION_UPLOAD);
                }else if(eventAttribute.Status__c == NC_Constant.EVENT_ATTRIBUTE_STATUS_REGIONAL_CENTER_REVIEW &&  !eventAttribute.PA2_Form_Uploaded__c){
                    eventAttribute.addError(NC_Constant.EVENT_ATTRIBUTE_TRIGGER_ERROR_PA2_FORM);
                }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : checkEventAttributeStatus
    @description    : Event Attribute validations
    @param          : List<Event_Attribute__c> newList, Map<Id, Event_Attribute__c> oldMap
    @return         : void
    ********************************************************
    */   
    private static void checkEventAttributeStatus(List<Event_Attribute__c> newList, Map<Id, Event_Attribute__c> oldMap){
        Id eventAttributeRecordIdStaffAttending = NC_Utility.RecordTypeUtilityMethod('Event_Attribute__c','Staff_Attending');
        List<Event_Attribute__c> eventAttributeList = new List<Event_Attribute__c>();
        Map<Id,Id> eventAttributeToAttendeeMap = new  Map<Id,Id>();
        for(Event_Attribute__c selectedEventAttribute : newList){
            if(selectedEventAttribute.recordTypeId == eventAttributeRecordIdStaffAttending 
               && oldMap != NULL && selectedEventAttribute.Status__c != oldMap.get(selectedEventAttribute.Id).Status__c 
               && selectedEventAttribute.Status__c == 'Pending Approval'){
                   eventAttributeList.add(selectedEventAttribute);       
            }
        }
        If(eventAttributeList.size()>0){
            for(Attendees__c attendee: [SELECT Id,Event_Attribute__c FROM Attendees__c WHERE Event_Attribute__c IN: eventAttributeList WITH SECURITY_ENFORCED]){
                eventAttributeToAttendeeMap.put(attendee.Event_Attribute__c,attendee.Id);
            }
        }
        for(Event_Attribute__c selectedEventAttribute : eventAttributeList){
            if(!eventAttributeToAttendeeMap.containsKey(selectedEventAttribute.Id)){
                
                selectedEventAttribute.addError('At least one attendee needs to be added before submitting for approval.');
               
            }
        }
        
        
    }
    
    /*
    *********************************************************
    @Method Name    : validateEventAttributeApproval
    @description    : Event Attribute approval validations
    @param          : List<Event_Attribute__c> newList, Map<Id, Event_Attribute__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void validateEventAttributeApproval(List<Event_Attribute__c> newList, Map<Id, Event_Attribute__c> oldMap){
        Id publicCommunicationTypeId = Schema.SObjectType.Event_Attribute__c.getRecordTypeInfosByDeveloperName().get('Public_Communication').getRecordTypeId();
        Id staffAttendingTypeId = Schema.SObjectType.Event_Attribute__c.getRecordTypeInfosByDeveloperName().get('Staff_Attending').getRecordTypeId();
        List<Id> eventAttributeIds = new List<Id>();
        
        for(Event_Attribute__c eventAttribute: newList) {
            if((eventAttribute.recordTypeId == publicCommunicationTypeId || eventAttribute.recordTypeId == staffAttendingTypeId)
                && oldMap.get(eventAttribute.id).Status__c == 'Created'
                && oldMap.get(eventAttribute.id).Status__c != eventAttribute.Status__c
              	&& eventAttribute.Submit_for_Approval__c == false) {
                  
                    eventAttribute.addError('Click Submit for Approval to proceed');
                   
            }
            
            if((eventAttribute.recordTypeId == publicCommunicationTypeId || eventAttribute.recordTypeId == staffAttendingTypeId)
                && oldMap.get(eventAttribute.id).Status__c == 'Created'
                && oldMap.get(eventAttribute.id).Status__c != eventAttribute.Status__c
              	&& eventAttribute.Submit_for_Approval__c == true) {
                    eventAttribute.Submit_for_Approval__c = false;
            }
            
            if((eventAttribute.recordTypeId == publicCommunicationTypeId || eventAttribute.recordTypeId == staffAttendingTypeId)
               	&& oldMap.get(eventAttribute.id).Status__c != eventAttribute.Status__c) {
                   eventAttributeIds.add(eventAttribute.id);
            }
        }
        
        if(eventAttributeIds.size() > 0) {
            List<ProcessInstance> processInstanceList = [Select Id From ProcessInstance WHERE TargetObjectId IN:eventAttributeIds AND Status = 'Pending'];
            if(!processInstanceList.isEmpty()) {
                Trigger.newMap.get(eventAttributeIds[0]).addError('Click Approve or Reject to proceed');
            }
        }
    }
}