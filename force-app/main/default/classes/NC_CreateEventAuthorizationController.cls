/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_CreateEventAuthorizationController {
    /*
    *********************************************************
    @Method Name    : getRecordTypes
    @description    : Retrieve all record types for object
    @param          : String objctNam
    @return         : Map<String,Id>
    ********************************************************
    */
    public static Map<String, Id> getRecordTypes(String objctName) {
        Map<String, Id> resultMap = new Map<String, Id>();
        try{
            if(String.isNotBlank(objctName)) {
                for(RecordType recType: [SELECT name FROM RecordType WHERE SobjectType =: objctName]) {
                    resultMap.put(recType.name, recType.id);
                }
            }
        } catch(Exception e) {
        }
        return resultMap;
    }
    
    /*
    *********************************************************
    @Method Name    : getEventAuthorizationRecordTypes
    @description    : Validate and return record types
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> getEventAuthorizationRecordTypes(Id recordId){
        Map<String, Object> resultMap = new Map<String, Object>();
        try{
            Id speakerFeesTypeId = Schema.SObjectType.Event_Authorization__c.getRecordTypeInfosByDeveloperName().get('Speaker_Fees').getRecordTypeId();
            Id nonStateTypeId = Schema.SObjectType.Event_Authorization__c.getRecordTypeInfosByDeveloperName().get('Non_State_Employee_Cost').getRecordTypeId();
            Id miscExpenseTypeId = Schema.SObjectType.Event_Authorization__c.getRecordTypeInfosByDeveloperName().get('Miscellaneous_Expenses').getRecordTypeId();
            Id ndbedpOutreachAttendeeTypeId = Schema.SObjectType.Event_Authorization__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Outreach_Attendee_Cost').getRecordTypeId();
            Id ndbedpTrainingAttendeeTypeId = Schema.SObjectType.Event_Authorization__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Training_Attendee_cost').getRecordTypeId();
            
            Set<Id> dhhSponsorSupportedIds = new Set<Id>{speakerFeesTypeId, nonStateTypeId, miscExpenseTypeId};
                
            Map<String, boolean> accessMap = checkRecordAccess(recordId);
            if(!accessMap.isEmpty() && accessMap.containsKey('HasEditAccess') && !accessMap.get('HasEditAccess')) {
                resultMap.put('isError', 'You don\'t have the necessary privileges to create this record');
                return resultMap;
            }
                
            List<Outreach_Request__c> outreachList = [SELECT recordType.Developername FROM Outreach_Request__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
            Map<String, Id> recordTypeMap = getRecordTypes('Event_Authorization__c');
            for(String recTypeName: recordTypeMap.keySet()) {
                if(outreachList[0].recordType.Developername == 'DHH_Sponsor_Event' && dhhSponsorSupportedIds.contains(recordTypeMap.get(recTypeName))) {
                    resultMap.put(recTypeName, recordTypeMap.get(recTypeName));
                }
            }
            if(resultMap.size() == 0) {
                resultMap.putAll(recordTypeMap);
            }
        } catch(Exception e) {
        }
        return resultMap;
    }
    
    /*
    *********************************************************
    @Method Name    : checkRecordAccess
    @description    : Check current user has access to record
    @param          : String parentId
    @return         : Map<String,boolean>
    ********************************************************
    */
    public static Map<String, boolean> checkRecordAccess(String parentId) {
        Map<String, boolean> resultMap = new Map<String, boolean>();
        for(UserRecordAccess userAccess: [SELECT recordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE recordId =: parentId AND UserId =: UserInfo.getUserId()]) {
            resultMap.put('HasReadAccess', userAccess.HasReadAccess);
            resultMap.put('HasEditAccess', userAccess.HasEditAccess);
        }
        return resultMap;
    }
}