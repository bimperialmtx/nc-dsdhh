/**
* @description       : Create Attendee record based on dependemt record
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
public with sharing class NC_CreateAttendeeRecordController {
    /*
    *********************************************************
    @Method Name    : retrieveDefaults
    @description    : Retrieve record type id based on related outreach request
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveDefaults(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        if(objectName == 'Outreach_Request__c') {
            Id ndbedpEventTypeId = NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c','NDBEDP_Event');

            List<Outreach_Request__c> outReachList = [SELECT recordTypeId FROM Outreach_Request__c WHERE id =: recordId WITH SECURITY_ENFORCED];
            if(!outReachList.isEmpty() && outReachList[0].recordTypeId == ndbedpEventTypeId) {
                result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Attendees__c','Attendees_For_NDBEDP_Event'));
            } else {
                result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Attendees__c','Attendees_For_Outreach_Request'));
            }
            result.put('forOutreach',true);
        }else{
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Attendees__c','Attendees_For_Event_Attribute'));
            result.put('forOutreach',false);
        }
        return result;
    }
}
/*
 public class NC_CreateAttendeeRecordController {
 @AuraEnabled
    public static Map<String,Object> retrieveDefaults(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        if(objectName == 'Outreach_Request__c') {
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Attendees__c','Attendees_For_Outreach_Request'));
            result.put('forOutreach',true);
        }else{
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Attendees__c','Attendees_For_Event_Attribute'));
            result.put('forOutreach',false);
        }
        return result;
    }
}*/