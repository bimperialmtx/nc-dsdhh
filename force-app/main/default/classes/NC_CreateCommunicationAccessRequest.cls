/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_CreateCommunicationAccessRequest {
    /*
    *********************************************************
    @Method Name    : retrieveDefaults
    @description    : Retrieve record type id based on input id
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveDefaults(Id recordId, Boolean isNDBEDPRequest){
        Map<String,Object> result = new Map<String,Object>();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        if(objectName == 'Outreach_Request__c') {
            return getOutreachTypes(recordId);
        } else if(objectName == 'Mentoring_Request__c'){
                result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','Mentoring_Request'));
                result.put('forMentoringRequest',true);
        } else if(objectName == 'Authorization__c'){
            Boolean speechEquipmentNotFount = True;
            Authorization__c authorizationRecord = [SELECT id, Request__r.Equipment_Types__c, Request__r.Regional_Center__c FROM Authorization__c WHERE Id=: recordId WITH SECURITY_ENFORCED];
            for(Asset__c assetRecord : [SELECT Id,Equipment_Type__c FROM Asset__c WHERE Authorization__C =: authorizationRecord.Id WITH SECURITY_ENFORCED]){
                if(assetRecord.Equipment_Type__c == 'Speech Equipment'){
                    if(authorizationRecord.Request__r.Regional_Center__c != NULL){
                        result.put('regionalCenter',authorizationRecord.Request__r.Regional_Center__c);
                    }
                    result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','Request_For_Training_Vendor'));
                    result.put('forAuthotizationTypeTainingVendor',true);
                    speechEquipmentNotFount = False;
                }
            }
            if(speechEquipmentNotFount){
                result.put('error','Only Training Vendor Are Allowed.');
            }
               
        } else if(objectName == 'Case'){
            if(isNDBEDPRequest != null && isNDBEDPRequest) {
             	result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','NDBEDP_Communication_Access_Request'));
            	result.put('forNDBEDPRequest',true);   
            } else {
                Boolean isError = false;
                Set<String> staffingUserrequestStatus = new Set<String>{'Pending Approval', 'Request Accepted', 'Pending Staff Approval'};
                Map<Id, String> communicationRequestMap = new Map<Id, String>();
                for(Communication_Access_Request__c communicationRequest: [SELECT id FROM Communication_Access_Request__c WHERE Request__c =: recordId WITH SECURITY_ENFORCED]) {
                    communicationRequestMap.put(communicationRequest.id, null);
                }
                for(Staffing_User_Request__c staffingUserRequest: [SELECT Status__c, Staffing_Request__r.Communication_Access_Request__c FROM Staffing_User_Request__c WHERE Staffing_Request__r.Communication_Access_Request__r.Request__c =: recordId WITH SECURITY_ENFORCED]) {
                    if(communicationRequestMap.containsKey(staffingUserRequest.Staffing_Request__r.Communication_Access_Request__c)) {
                        communicationRequestMap.put(staffingUserRequest.Staffing_Request__r.Communication_Access_Request__c, staffingUserRequest.Status__c);
                    }
                }
                for(Id carId: communicationRequestMap.keySet()) {
                    if(communicationRequestMap.get(carId) == null || staffingUserrequestStatus.contains(communicationRequestMap.get(carId))) {
                        isError = true;
                    }
                }
                if(isError) {
                    result.put('error', 'NDBEDP Trainer Request is in progress');
                } else {
                    result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','Request_For_Training_Vendor'));
                    result.put('forNDBEDPTainingVendor',true);
                }
                //result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','Request_For_Training_Vendor'));
            	//result.put('forNDBEDPTainingVendor',true);
            }
        } else if(objectName == 'Event_Attribute__c') {
            Event_Attribute__c eventAttribute = [SELECT Outreach_Request__c FROM Event_Attribute__c WHERE id =: recordId WITH SECURITY_ENFORCED];
            return getOutreachTypes(eventAttribute.Outreach_Request__c);
        } else {
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','Generic_Request'));
            result.put('forOutreach',false);
            Event_Attribute__c eventAttribute = [SELECT Outreach_Request__c FROM Event_Attribute__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
            result.put('eventAttribute',eventAttribute);
        }
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : getOutreachTypes
    @description    : Retrieve outreach record type id based on input id
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    public static Map<String,Object> getOutreachTypes(Id recordId) {
        Map<String,Object> result = new Map<String,Object>();
        Outreach_Request__c outreachRequest = [SELECT id, RecordTypeId, Title_of_Event__c FROM Outreach_Request__c WHERE Id=: recordId WITH SECURITY_ENFORCED];
        Id nonDHHOutreachRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c',  'Non_DHH_Sponsor_Event');
        Id ndbedpEventRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c',  'NDBEDP_Event');
        if(outreachRequest.RecordTypeId == nonDHHOutreachRecordTypeId){
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','Request_for_Non_DHH_Outreach'));
            result.put('forOutreach',true);
            result.put('outreachData',outreachRequest);
        }else if(outreachRequest.RecordTypeId == ndbedpEventRecordTypeId){
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','NDBEDP_Communication_Access_Request'));
            result.put('forOutreach',true);
            result.put('outreachData',outreachRequest);
        }else{
            result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c','Generic_Request'));
            result.put('forOutreach',true);
            result.put('outreachData',outreachRequest);
        }
        return result;
    }
}