/*
**   Class Name: NC_StaffingRequestTriggerHandler
**   Description: 
**
**     Date            New/Modified           User                 Identifier                Description
**  06-04-2020             New              Hiten Aggarwal(mtx)                                 
**  06-14-2020             Update           Shubham Dadhich(mtx)                             Added Roll Up To Communicaiton Acces Total_Internal_Cost__c
*/


public without sharing class NC_StaffingRequestTriggerHandler {

    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before UPDATE' trigger event
    @param          : List<Staffing_Request__c> newList, Map<Id,Staffing_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Staffing_Request__c> newList, Map<Id,Staffing_Request__c> oldMap){
       createRequestComments(newList,oldMap);
    }
   
    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after UPDATE' trigger event
    @param          : List<Staffing_Request__c> newList, Map<Id,Staffing_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Staffing_Request__c> newList, Map<Id,Staffing_Request__c> oldMap){
       checkTotalStaffingUserRequest(newList,oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : createRequestComments
    @description    : create Request comment records from Service notes
    @param          : List<Staffing_Request__c> newList, Map<Id,Staffing_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void createRequestComments(List<Staffing_Request__c> newList, Map<Id,Staffing_Request__c> oldMap){
        List<Request_comment__c> requestCommentList = new List<Request_comment__c>();
        for(Staffing_Request__c staffRequest : newList){
            if(staffRequest.Service_Notes__c != null) {
                Request_comment__c requestComment = new Request_comment__c();
                requestComment.Internal_Comments__c = staffRequest.Service_Notes__c;
                requestComment.Hours__c = staffRequest.Service_Hours__c != NULL ? staffRequest.Service_Hours__c : NULL;
                requestComment.Minutes__c = staffRequest.Minutes__c != NULL ? staffRequest.Minutes__c : NULL;
                requestComment.Staffing_Request__c = staffRequest.id;
                requestCommentList.add(requestComment);
                staffRequest.Service_Notes__c = null;
                staffRequest.Service_Hours__c = null;
                staffRequest.Minutes__c = null;
            }
        }
        if(!requestCommentList.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Request_comment__c', requestCommentList, 'insert', true, 'NC_StaffingRequestTriggerHandler', 'createRequestComments');
            insert objectDecision.getRecords();
            requestCommentList = objectDecision.getRecords();
            Map<Id, Id> commentReqMap = new Map<Id, Id>();
            Map<Id, Request_comment__c> commReqMap = new Map<Id, Request_comment__c>();
            for(Request_comment__c reqComm: [SELECT Staffing_Request__c, ownerId FROM Request_comment__c WHERE Id IN: requestCommentList]) {
                commentReqMap.put(reqComm.id, reqComm.Staffing_Request__c);
                commReqMap.put(reqComm.id, reqComm);
            }
            shareRequestComments(commentReqMap, commReqMap);
         }
    }
    
    /*
    *********************************************************
    @Method Name    : shareRequestComments
    @description    : Share Request Comments record
    @param          : Map<Id, Id> commentReqMap, Map<Id, Request_comment__c> commReqMap
    @return         : void
    ********************************************************
    */
    public static void shareRequestComments(Map<Id, Id> commentReqMap, Map<Id, Request_comment__c> commReqMap) {
        List<Request_comment__share> reqComShareList = new List<Request_comment__share>();
        Map<Id, List<Staffing_Request__Share>> staffShareMap = new Map<Id, List<Staffing_Request__Share>>();
        for(Staffing_Request__Share shareObj: [SELECT parentId, AccessLevel, UserOrGroupId FROM Staffing_Request__Share WHERE parentId IN: commentReqMap.values()]) {
            if(!staffShareMap.containsKey(shareObj.parentId)) {
                staffShareMap.put(shareObj.parentId, new List<Staffing_Request__Share>());
            }
            staffShareMap.get(shareObj.parentId).add(shareObj);
        }
        
        for(Id requestCommId: commentReqMap.keySet()) {
            if(staffShareMap.containsKey(commentReqMap.get(requestCommId))) {
                for(Staffing_Request__Share shareObj: staffShareMap.get(commentReqMap.get(requestCommId))) {
                    if(shareObj.UserOrGroupId != UserInfo.getUserId()) {
                     	Request_comment__Share reqComShare = new Request_comment__Share();
                        reqComShare.ParentId = requestCommId;
                        reqComShare.AccessLevel = shareObj.AccessLevel == 'All' ? 'Edit' : shareObj.AccessLevel;
                        reqComShare.RowCause = Schema.Request_comment__share.RowCause.Manual;
                        reqComShare.UserOrGroupId = shareObj.UserOrGroupId;
                        reqComShareList.add(reqComShare);   
                    }
                }
            }
        }
        if(reqComShareList.size() > 0) {
            insert reqComShareList;
        }
    }

    /*
    *********************************************************
    @Method Name    : rollUpOnInsertUpdateUnDelete
    @description    : Roll Up On Insert Update and Undelete
    @param          : List<Staffing_Request__c> listOfStaffingNew, Map<Id, Staffing_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void rollUpOnInsertUpdateUnDelete(List<Staffing_Request__c> listOfStaffingNew, Map<Id, Staffing_Request__c> oldMap){
        Id StaffingInternal = NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c', NC_Constant.STAFFING_REQUEST_INTERNAL);
        List<Staffing_Request__c> listOfStaffingRequest = new List<Staffing_Request__c>();
        for(Staffing_Request__c staffing : listOfStaffingNew){
            if(oldMap != null && staffing.RecordTypeId == StaffingInternal && staffing.Total_Internal_Cost__c != oldMap.get(staffing.Id).Total_Internal_Cost__c){
                listOfStaffingRequest.add(staffing);
            }
        }
        if(!listOfStaffingRequest.isEmpty()){
            List<NC_RollupUtility.fieldDefinition> fieldDefinitions = new list<NC_RollupUtility.fieldDefinition> {new NC_RollupUtility.fieldDefinition('SUM', 'Total_Internal_Cost__c','CACL_Total_Cost__c')};
            NC_RollupUtility.rollUpTrigger(fieldDefinitions, listOfStaffingRequest, 'Staffing_Request__c', 'Communication_Access_Request__c', 'Communication_Access_Request__c', '');
        }
    }

    /*
    *********************************************************
    @Method Name    : rollUpOnDelete
    @description    : Roll Up On Delete
    @param          : List<Staffing_Request__c> listOfStaffingNew
    @return         : void
    ********************************************************
    */
    public static void rollUpOnDelete(List<Staffing_Request__c> listOfStaffingNew){
        Id StaffingInternal = NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c', NC_Constant.STAFFING_REQUEST_INTERNAL);
        List<Staffing_Request__c> listOfStaffingRequest = new List<Staffing_Request__c>();
        for(Staffing_Request__c staffing : listOfStaffingNew){
            if(staffing.RecordTypeId == StaffingInternal){
                listOfStaffingRequest.add(staffing);
            }
        }
        if(!listOfStaffingRequest.isEmpty()){
            List<NC_RollupUtility.fieldDefinition> fieldDefinitions = new list<NC_RollupUtility.fieldDefinition> {new NC_RollupUtility.fieldDefinition('SUM', 'Total_Internal_Cost__c','CACL_Total_Cost__c')};
            NC_RollupUtility.rollUpTrigger(fieldDefinitions, listOfStaffingRequest, 'Staffing_Request__c', 'Communication_Access_Request__c', 'Communication_Access_Request__c', '');
        }
    }

    /*
    *********************************************************
    @Method Name    : checkTotalStaffingUserRequest
    @description    : validation on child staffing user request
    @param          : List<Staffing_Request__c> newList, Map<Id,Staffing_Request__c> oldMap
    @return         : void
    ********************************************************
    */
   private static void checkTotalStaffingUserRequest(List<Staffing_Request__c> newList, Map<Id,Staffing_Request__c> oldMap){
        Id internalRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c', 'Internal_Staff');
        Set<Id> staffingRequestIdSet = new Set<Id>();
        List<Staffing_User_Request__c> staffingUserRequestUpdateList = new List<Staffing_User_Request__c>();
        Map<Id,Id> processInstanceTostaffingUserRequest = new Map<Id,Id>();
        List<Staffing_User_Request__c> staffingUserRequestList = new List<Staffing_User_Request__c>();
        Map<Id,Id> ProcessInstanceIdToProcessInstanceWorkitemMap = new Map<Id,Id>();
        for(Staffing_Request__c staffingRequest : newList){
            if(oldMap != NULL && (staffingRequest.Number_of_Vendors_Needed__c != NULL || staffingRequest.Number_of_Interpreters_Needed__c != NULL)){
                if(staffingRequest.RecordTypeId == internalRecordTypeId){
                    if(staffingRequest.Total_Members_Attending__c >= Integer.valueOf(staffingRequest.Number_of_Interpreters_Needed__c)){
                        staffingRequestIdSet.add(staffingRequest.Id);
                    }  
                }else{
                    if(staffingRequest.Total_Members_Attending__c >= Integer.valueOf(staffingRequest.Number_of_Vendors_Needed__c)){
                        staffingRequestIdSet.add(staffingRequest.Id);
                    }
                }
            }
        }
        for(Staffing_User_Request__c staffingUserRequest : [Select Id,Status__c, Request_Accepted__c 
                                                            From Staffing_User_Request__c 
                                                            WHERE Staffing_Request__c IN: staffingRequestIdSet
                                                            AND (Status__c = 'Pending Staff Approval' OR Status__c = 'Pending Approval' 
                                                                 OR Status__c = 'Pending Vendor Approval' OR Status__c = 'Request Accepted') WITH SECURITY_ENFORCED]){
           
            staffingUserRequestList.add(staffingUserRequest);                                                         
        }
 
        if(staffingUserRequestList.size()>0){
            /*Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId 
                                                          FROM ProcessInstance 
                                                          where Status='Pending' 
															AND TargetObjectId in : staffingUserRequestIdSet])).keySet();*/
            for(ProcessInstance process : [SELECT Id,Status,TargetObjectId 
                                           FROM ProcessInstance 
                                           where Status='Pending' 
                                           AND TargetObjectId in : staffingUserRequestList]){
                                               if(!processInstanceTostaffingUserRequest.containsKey(process.Id)){
                                                   processInstanceTostaffingUserRequest.put(process.Id,process.TargetObjectId);
                                               }
                                           }
            
            for(ProcessInstanceWorkitem processInstanceWorkItems:  [SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId In : processInstanceTostaffingUserRequest.keySet()]){
                ProcessInstanceIdToProcessInstanceWorkitemMap.put(processInstanceWorkItems.ProcessInstanceId, processInstanceWorkItems.Id);
            }
                    	
            for (Id pInstanceWorkitemsId: ProcessInstanceIdToProcessInstanceWorkitemMap.values()){
                Approval.ProcessWorkitemRequest singleApprovalProcess = new Approval.ProcessWorkitemRequest();
                singleApprovalProcess.setComments('All Slots Filled.');
                singleApprovalProcess.setAction('Reject');
                singleApprovalProcess.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                singleApprovalProcess.setWorkitemId(pInstanceWorkitemsId);
                Approval.ProcessResult result = Approval.process(singleApprovalProcess); 
            }
            for(Staffing_User_Request__c staffingUserRequest : staffingUserRequestList){
                if(!processInstanceTostaffingUserRequest.values().contains(staffingUserRequest.Id)){
                    staffingUserRequest.Status__c = 'Rejected';
                    staffingUserRequestUpdateList.add(staffingUserRequest);
                }
            }
            if(!staffingUserRequestUpdateList.isEmpty()){
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Staffing_User_Request__c', staffingUserRequestUpdateList, 'update', true,'NC_StaffingRequestTriggerHandler','checkTotalStaffingUserRequest');
                update decision.getRecords();
            }
        }  
    }
}