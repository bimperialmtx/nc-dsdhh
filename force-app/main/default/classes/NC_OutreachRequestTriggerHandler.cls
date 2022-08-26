/*
*   Class Name: NC_OutreachRequestTriggerHandler
*   Description: Outrech Request Trigger Handler -- Logics on insert, update and delete
*
*   Date            New/Modified         User                 Identifier                Description
*   25/05/2020         New         Shubham Dadhich(mtx)
*/
public with sharing class NC_OutreachRequestTriggerHandler {
    
    public static Id ndbedpEventRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c','NDBEDP_Event');
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Outreach_Request__c> newOutreachRequestList, Map<Id, Outreach_Request__c> oldOutreachRequestMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Outreach_Request__c> newOutreachRequestList, Map<Id, Outreach_Request__c> oldOutreachRequestMap){
        validateRecord(newOutreachRequestList,oldOutreachRequestMap);
        closeOutreachRequest(newOutreachRequestList,oldOutreachRequestMap);
        validateOutreachRequestApproval(newOutreachRequestList,oldOutreachRequestMap);
        updateAttendeesCloseDate(newOutreachRequestList,oldOutreachRequestMap);
    }

    /*
    *********************************************************
    @Method Name    : validateRecord
    @description    : Validate Record for Submit For Approval record Type Should be DHH_Sponsor_Event
    @param          : List<Outreach_Request__c> newOutreachRequestList, Map<Id, Outreach_Request__c> oldOutreachRequestMap
    @return         : void
    ********************************************************
    */
    public static void validateRecord(List<Outreach_Request__c> newOutreachRequestList, Map<Id, Outreach_Request__c> oldOutreachRequestMap) {
        Id outreachRequestRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c','DHH_Sponsor_Event');
        for(Outreach_Request__c outreachRequest : newOutreachRequestList){
            if((outreachRequest.RecordTypeId == outreachRequestRecordTypeId || outreachRequest.recordTypeId == ndbedpEventRecordTypeId) && outreachRequest.Start_Date_of_Event__c != null){
                Integer number_of_Days = System.today().daysBetween(outreachRequest.Start_Date_of_Event__c.date());
                if(outreachRequest.Status__c == NC_Constant.STATUS_PENDING_PUBLIC_COMMUNICATION_REVIEW && !outreachRequest.Public_Communication_Document_Uploaded__c){
                    outreachRequest.addError(NC_Constant.OUTREACH_REQUEST_TRIGGER_ERROR_PUBLIC_COMMUNICATION_UPLOAD);
                }else if(outreachRequest.Status__c == NC_Constant.STATUS_PENDING_PUBLIC_COMMUNICATION_REVIEW &&  !outreachRequest.PA_2_Form_Uploaded__c){
                    outreachRequest.addError(NC_Constant.OUTREACH_REQUEST_TRIGGER_ERROR_PA2FORM);
                }else if((outreachRequest.Status__c == NC_Constant.STATUS_INITIAL_REQUEST_REVIEW || outreachRequest.Status__c == NC_Constant.STATUS_PENDING_PUBLIC_COMMUNICATION_REVIEW || outreachRequest.Status__c == NC_Constant.STATUS_PENDING_EVENT_APPROVAL || outreachRequest.Status__c == NC_Constant.STATUS_PUBLIC_COMMUNICATION_DIRECTOR_REVIEW) && number_of_Days < 45){
                    if(outreachRequest.Justification__c == null){
                        outreachRequest.addError(NC_Constant.OUTREACH_REQUEST_TRIGGER_ERROR_JUSTIFICATION_NOT_NULL);
                    }
                }
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : closeOutreachRequest
    @description    : Close outreach request validation
    @param          : List<Outreach_Request__c> newList, Map<Id, Outreach_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void closeOutreachRequest(List<Outreach_Request__c> newList, Map<Id, Outreach_Request__c> oldMap) {
        Id outreachRequestRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c','DHH_Sponsor_Event');
        List<Outreach_Request__c> outreachRequestList = new List<Outreach_Request__c>();
        Set<Id> outreachWithAttendeeSet = new Set<Id>();
        for(Outreach_Request__c outreachRequest : newList){
            if(oldMap != null && oldMap.get(outreachRequest.Id).Status__C != outreachRequest.Status__C &&
               (outreachRequest.RecordTypeId == outreachRequestRecordTypeId || outreachRequest.recordTypeId == ndbedpEventRecordTypeId) && outreachRequest.Status__C == 'Closed'){
                outreachRequestList.add(outreachRequest);
            }
        }
        if(outreachRequestList.size()>0){
            for(Attendees__c attendeeRecord : [SELECT id, Outreach_Request__c FROM Attendees__c WHERE Outreach_Request__c IN: outreachRequestList WITH SECURITY_ENFORCED]){
                outreachWithAttendeeSet.add(attendeeRecord.Outreach_Request__c);
            }
            for(Outreach_Request__c outreachRequest : outreachRequestList){
                if(!outreachWithAttendeeSet.contains(outreachRequest.Id)){
                    outreachRequest.addError('Atleast one Attendee is needed before closing Outreach');
                }
            }
        }
       
    }

    /*
    *********************************************************
    @Method Name    : validateOutreachRequestApproval
    @description    : validate outreach request status navigation
    @param          : List<Outreach_Request__c> newList, Map<Id, Outreach_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateOutreachRequestApproval(List<Outreach_Request__c> newList, Map<Id, Outreach_Request__c> oldMap) {
        Id dsdhhSponsorTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('DHH_Sponsor_Event').getRecordTypeId();
        Id ndbedpEventTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Event').getRecordTypeId();
        Id informationSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
        Set<Id> outreachTypeIds = new Set<Id>{dsdhhSponsorTypeId, ndbedpEventTypeId};
        List<String> outreachIds = new List<String>();
        for(Outreach_Request__c outreachObj: newList) {
            
            if((outreachTypeIds.contains(outreachObj.recordTypeId) || outreachObj.recordTypeId == informationSessionTypeId)
              	&& oldMap.get(outreachObj.id).Status__c != outreachObj.Status__c) {
                outreachIds.add(outreachObj.id);
            }
            if((outreachTypeIds.contains(outreachObj.recordTypeId) || outreachObj.recordTypeId == informationSessionTypeId)
                && oldMap.get(outreachObj.id).Status__c == 'Created'
                && oldMap.get(outreachObj.id).Status__c != outreachObj.Status__c
                && outreachObj.Status__c != 'Cancelled'
                && outreachObj.Submit_for_Approval__c == false) {
                    outreachObj.addError('Click Submit for Approval to proceed');
            }
            if((outreachTypeIds.contains(outreachObj.recordTypeId) || outreachObj.recordTypeId == informationSessionTypeId)
                && oldMap.get(outreachObj.id).Status__c == 'Created'
                && oldMap.get(outreachObj.id).Status__c != outreachObj.Status__c
                && outreachObj.Submit_for_Approval__c == true) {
                    outreachObj.Submit_for_Approval__c = false;
            }
            if(outreachTypeIds.contains(outreachObj.recordTypeId)
                && oldMap.get(outreachObj.id).Status__c == 'Initial Request Approved'
                && oldMap.get(outreachObj.id).Status__c != outreachObj.Status__c
                && outreachObj.Status__c != 'Cancelled'
                && outreachObj.Submit_for_Approval__c == false) {
                    outreachObj.addError('Click Submit for Approval to proceed');
            }
            if(outreachTypeIds.contains(outreachObj.recordTypeId)
                && oldMap.get(outreachObj.id).Status__c == 'Initial Request Approved'
                && oldMap.get(outreachObj.id).Status__c != outreachObj.Status__c
                && outreachObj.Submit_for_Approval__c == true) {
                    outreachObj.Submit_for_Approval__c = false;
            }
            if(outreachTypeIds.contains(outreachObj.recordTypeId)
                && oldMap.get(outreachObj.id).Status__c == 'Public Communication Approved'
                && oldMap.get(outreachObj.id).Status__c != outreachObj.Status__c
                && outreachObj.Status__c != 'Cancelled'
                && outreachObj.Submit_for_Approval__c == false) {
                    outreachObj.addError('Click Submit for Approval to proceed');
            }
            if(outreachTypeIds.contains(outreachObj.recordTypeId)
                && oldMap.get(outreachObj.id).Status__c == 'Public Communication Approved'
                && oldMap.get(outreachObj.id).Status__c != outreachObj.Status__c
                && outreachObj.Submit_for_Approval__c == true) {
                    outreachObj.Submit_for_Approval__c = false;
            }
        }
        
        if(outreachIds.size() > 0) {
            List<ProcessInstance> processInstanceList = [Select Id From ProcessInstance WHERE TargetObjectId IN:outreachIds AND Status = 'Pending'];
            if(!processInstanceList.isEmpty()) {
                Trigger.newMap.get(outreachIds[0]).addError('Click Approve or Reject to proceed');
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateAttendeesCloseDate
    @description    : Update close date on attendees when outreach request closed
    @param          : List<Outreach_Request__c> newList, Map<Id, Outreach_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateAttendeesCloseDate(List<Outreach_Request__c> newList, Map<Id, Outreach_Request__c> oldMap) {
        Id outreachRequestRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c','DHH_Sponsor_Event');
        List<Attendees__c> outreachWithAttendeeList = new List<Attendees__c>();
        List<Outreach_Request__c> outreachRequestList = new List<Outreach_Request__c>();
        for(Outreach_Request__c outreachRequest:newList){
            if(oldMap != null && oldMap.get(outreachRequest.Id).Status__C != outreachRequest.Status__C &&
               outreachRequest.RecordTypeId == outreachRequestRecordTypeId  && outreachRequest.Status__C == 'Closed'){
                outreachRequestList.add(outreachRequest);
         }
        }
        if(outreachRequestList.size()>0){
            for(Attendees__c attendeeRecord : [SELECT id, Outreach_Request__c,Service_Close_Date__c FROM Attendees__c WHERE Outreach_Request__c IN: outreachRequestList WITH SECURITY_ENFORCED]){
                attendeeRecord.Service_Close_Date__c = Date.today();
                outreachWithAttendeeList.add(attendeeRecord);
            }
        }
        if(outreachWithAttendeeList.size()>0){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Attendees__c', outreachWithAttendeeList, 'update', true,'NC_OutreachRequestTriggerHandler','updateAttendeesCloseDate');
            update objectDecision.getRecords();
           // update outreachWithAttendeeList;
        }
    }
}