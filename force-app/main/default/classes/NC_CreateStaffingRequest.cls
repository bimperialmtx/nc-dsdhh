/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_CreateStaffingRequest {
    /*
    *********************************************************
    @Method Name    : retrieveDefaultsForInternal
    @description    : Retrieve Staffing Request internal staff id
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
	@AuraEnabled
    public static Map<String,Object> retrieveDefaultsForInternal(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        if(objectName == 'Communication_Access_Request__c') {
            Communication_Access_Request__c communicationAccessRequestRecord = [SELECT Id,Status__c FROM Communication_Access_Request__c WHERE Id=: recordId WITH SECURITY_ENFORCED];
            //if(communicationAccessRequestRecord.Status__c  != 'Approved'){
            //   result.put('error','Communication Access Must Be Approved Before Creating Staffing Request!');
            //}else{
                result.put('recordTypeId',NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c','Internal_Staff'));
                result.put('forCommunication',true);
            //}
        }
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveDefaultsForExternal
    @description    : Validate and Retrieve Staffing Request external staff id
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveDefaultsForExternal(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        Id externalStaffId = NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c','External_Staff');
        if(objectName == 'Communication_Access_Request__c') {
            Communication_Access_Request__c communicationAccessRequestRecord = [SELECT Id,Status__c,Vendor_Type__c FROM Communication_Access_Request__c WHERE Id=: recordId WITH SECURITY_ENFORCED];
            //if(communicationAccessRequestRecord.Status__c  != 'Approved'){
            //    result.put('error','Communication Access Must Be Approved Before Creating Staffing Request!');
            //}else{
                result.put('recordTypeId',externalStaffId);
                result.put('forCommunication',true);
            
            if(communicationAccessRequestRecord.Vendor_Type__c == 'NDBEDP Training') {
				
                List<Staffing_Request__c> staffRequestList = [SELECT id FROM Staffing_Request__c WHERE Communication_Access_Request__c =: communicationAccessRequestRecord.id WITH SECURITY_ENFORCED];
                if(staffRequestList.isEmpty()) {
                    Staffing_Request__c staffRequest = new Staffing_Request__c();
                    staffRequest.recordTypeId = externalStaffId;
                    staffRequest.Communication_Access_Request__c = communicationAccessRequestRecord.id;
                    staffRequest.Number_of_Vendors_Needed__c = '1';
                    
                    SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Staffing_Request__c', new List<Staffing_Request__c>{staffRequest}, 'insert', true, 'NC_CreateStaffingRequest', 'retrieveDefaultsForExternal');
                    insert decision.getRecords();
                    result.put('staffRequestId',decision.getRecords()[0].id);
                } else {
                    result.put('NDBEDPTrainingError', 'External Staffing Request already exists');
                }
                result.put('isNDBEDPTraining',true);
            }
            //}
        }
        return result;
    }
}