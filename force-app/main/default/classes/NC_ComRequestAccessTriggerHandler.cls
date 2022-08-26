/*
**   Class Name: NC_ComRequestAccessTriggerHandler
**   Description: 
**
**     Date            New/Modified           User                 Identifier                Description
**  06-014-2020             Created           Shubham Dadhich(mtx)                             Added Roll Up To Communicaiton Acces Total_Internal_Cost__c
*/
public without sharing class NC_ComRequestAccessTriggerHandler {
       
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : Execution of Trigger before update event
    @param          : List<Communication_Access_Request__c> newList ,Map<Id, Communication_Access_Request__c> oldMap, Map<Id, Communication_Access_Request__c> newMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Communication_Access_Request__c> newList ,Map<Id, Communication_Access_Request__c> oldMap, Map<Id, Communication_Access_Request__c> newMap){
        validateCommunicationRequestApproval(newList, oldMap);
        serviceEndDateValidation(newList, oldMap, newMap);
    }
    
    /*
    *********************************************************
    @Method Name    : validateCommunicationRequestApproval
    @description    : validate Communication Access Request status validation and approval
    @param          : List<Communication_Access_Request__c> newList ,Map<Id, Communication_Access_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateCommunicationRequestApproval(List<Communication_Access_Request__c> newList ,Map<Id, Communication_Access_Request__c> oldMap) {
        List<Id> requestIds = new List<Id>();
        Id nonDhhTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Request_for_Non_DHH_Outreach').getRecordTypeId();
        for(Communication_Access_Request__c request: newList) {
            if((request.Status__c == 'Cancelled' || request.Status__c == 'Closed') && request.Cancel_Close_Comment__c == null) {
                request.addError('Add Cancel/Close Comment to proceed');
            }
            if((oldMap.get(request.id).Status__c == 'Cancelled' || oldMap.get(request.id).Status__c == 'Closed') && request.Is_Roll_Up__c == false) {
                request.addError('Cancelled/Closed Communication Access request cannot be updated');
            }
            if(request.Is_Roll_Up__c == true) {
                request.Is_Roll_Up__c = false;
            }
            if(request.RecordTypeId == nonDhhTypeId && oldMap.get(request.id).Status__c != request.Status__c) {
                requestIds.add(request.id);
            }
            if(request.RecordTypeId == nonDhhTypeId
              && oldMap.get(request.id).Status__c == 'Created'
              && oldMap.get(request.id).Status__c != request.Status__c
              && request.Submit_for_Approval__c == false
              && request.Status__c != 'Cancelled' && request.Status__c != 'Closed') {
                request.addError('Click Submit for Approval to proceed');
            }
        }
        if(requestIds.size() > 0) {
            List<ProcessInstance> processInstanceList = [Select Id From ProcessInstance WHERE TargetObjectId IN:requestIds AND Status = 'Pending'];
            if(!processInstanceList.isEmpty()) {
                Trigger.newMap.get(requestIds[0]).addError('Click Approve or Reject to proceed');
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : serviceEndDateValidation
    @description    : Communication Request Service end date validation
    @param          : List<Communication_Access_Request__c> newList ,Map<Id, Communication_Access_Request__c> oldMap, Map<Id, Communication_Access_Request__c> newMap
    @return         : void
    ********************************************************
    */
    public static void serviceEndDateValidation(List<Communication_Access_Request__c> newList ,Map<Id, Communication_Access_Request__c> oldMap, Map<Id, Communication_Access_Request__c> newMap) {
        Set<String> requestSet = new Set<String>();
        Set<String> invoiceStatusSet = new Set<String>{'Pending EDS Program Assistant', 'Pending EDS Program Coordinator', 'Pending Controller Office Approval', 'Pending for Controller Office Batch to NCAS', 'Pending Approval'};
        for(Invoice__c invRecord: [SELECT Authorization__r.Communication_Access_Request__c FROM Invoice__c WHERE Authorization__r.Communication_Access_Request__c in: newList AND Status__c IN: invoiceStatusSet]){//WITH SECURITY_ENFORCED
            requestSet.add(invRecord.Authorization__r.Communication_Access_Request__c);
        }
        for(Communication_Access_Request__c car: newList) {
            if(requestSet.contains(car.id) &&  oldMap.get(car.id).End_Service_Date_Time__c != car.End_Service_Date_Time__c) {
                car.addError('End Service Date Time cannot be modified as related Invoice is in approval');
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : rollUpOnInsertUpdateUnDelete
    @description    : Roll Up On Insert Update and Undelete
    @param          : List<Communication_Access_Request__c> listOfCommNew, Map<Id, Communication_Access_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void rollUpOnInsertUpdateUnDelete(List<Communication_Access_Request__c> listOfCommNew, Map<Id, Communication_Access_Request__c> oldMap){
        Id genricRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c', NC_Constant.COMMUNICATION_ACCESS_RECORD_TYPE_DHH);
        List<Communication_Access_Request__c> listOfCommunication = new List<Communication_Access_Request__c>();
        for(Communication_Access_Request__c comm : listOfCommNew){
            if(oldMap != null && comm.RecordTypeId == genricRecordTypeId && comm.CACL_Total_Cost__c != oldMap.get(comm.Id).CACL_Total_Cost__c){
                listOfCommunication.add(comm);
            }
        }
        if(!listOfCommunication.isEmpty()){
            List<NC_RollupUtility.fieldDefinition> fieldDefinitions = new list<NC_RollupUtility.fieldDefinition> {new NC_RollupUtility.fieldDefinition('SUM', 'CACL_Total_Cost__c','CACL_Cost__c')};
            NC_RollupUtility.rollUpTrigger(fieldDefinitions, listOfCommunication, 'Communication_Access_Request__c', 'Outreach_Request__c', 'Outreach_Request__c', '');
        }
    }
    
    /*
    *********************************************************
    @Method Name    : rollUpOnDelete
    @description    : Roll Up On Delete
    @param          : List<Communication_Access_Request__c> listOfCommNew
    @return         : void
    ********************************************************
    */
    public static void rollUpOnDelete(List<Communication_Access_Request__c> listOfCommNew){
        Id genricRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Communication_Access_Request__c', NC_Constant.COMMUNICATION_ACCESS_RECORD_TYPE_DHH);
        List<Communication_Access_Request__c> listOfCommunication = new List<Communication_Access_Request__c>();
        for(Communication_Access_Request__c comm : listOfCommNew){
            if(comm.RecordTypeId == genricRecordTypeId){
                listOfCommunication.add(comm);
            }
        }
        if(!listOfCommunication.isEmpty()){
            List<NC_RollupUtility.fieldDefinition> fieldDefinitions = new list<NC_RollupUtility.fieldDefinition> {new NC_RollupUtility.fieldDefinition('SUM', 'CACL_Total_Cost__c','CACL_Cost__c')};
            NC_RollupUtility.rollUpTrigger(fieldDefinitions, listOfCommunication, 'Communication_Access_Request__c', 'Outreach_Request__c', 'Outreach_Request__c', '');
        }
    }
}