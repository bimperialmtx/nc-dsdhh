/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_CloseEventController {
    /*
    *********************************************************
    @Method Name    : closeEvent
    @description    : Close event and validation
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> closeEvent(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        if(objectName == 'Event_Attribute__c') {
            List<Event_Attribute__c> eventAttributeList = new List<Event_Attribute__c>();
            for(Event_Attribute__c eventAttribute: [SELECT Resolution_Note__c, Status__c, End_Date_of_Event__c FROM Event_Attribute__c WHERE Id =: recordId WITH SECURITY_ENFORCED]) {
                if(eventAttribute.End_Date_of_Event__c.Date() > System.Today()){
                    result.put('updated',false);
                    result.put('message','Event cannot be closed before End Date of Event.');
                }else if(eventAttribute.Status__c != 'Approved') {
                    result.put('updated',false);
                    result.put('message','You can only close approved events.');
                } else if(String.isBlank(eventAttribute.Resolution_Note__c)) {
                    result.put('updated',false);
                    result.put('message','Resolution Note is required before closing the event.');
                } else {
                    eventAttribute.Status__c = 'Closed';
                    eventAttributeList.add(eventAttribute);
                    result.put('updated',true);
                }
            }
            if(eventAttributeList.size() > 0) {
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Event_Attribute__c', eventAttributeList, 'update', true,'NC_CloseEventController','closeEvent');
                update objectDecision.getRecords();
            }
        } else {
            List<Outreach_Request__c> outreachRequestList = new List<Outreach_Request__c>();
            for(Outreach_Request__c outreachRequest: [SELECT Sign_In_Sheets_Uploaded__c, Resolution_Note__c, Status__c, End_Date_of_Event__c, OwnerId FROM Outreach_Request__c WHERE Id =: recordId WITH SECURITY_ENFORCED]) {
                if(outreachRequest.End_Date_of_Event__c.Date() > System.Today()){
                    result.put('updated',false);
                    result.put('message','Event cannot be closed before End Date of Event.');
                } else if(outreachRequest.Status__c != 'Approved') {
                    result.put('updated',false);
                    result.put('message','You can only close approved events.');
                } else if(String.isBlank(outreachRequest.Resolution_Note__c)) {
                    result.put('updated',false);
                    result.put('message','Resolution Note is required before closing the event.');
                } else if(!outreachRequest.Sign_In_Sheets_Uploaded__c) {
                    result.put('updated',false);
                    result.put('message','Sign in sheets needs to be uploaded before closing the event.');
                } else {
                    outreachRequest.Status__c = 'Closed';
                    outreachRequestList.add(outreachRequest);
                    result.put('updated',true);
                }
            }
            if(outreachRequestList.size() > 0) {
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Outreach_Request__c', outreachRequestList, 'update', true,'NC_CloseEventController','closeEvent');
                update objectDecision.getRecords();
                createTaskForClosedOutreach(outreachRequestList);
            }
        }
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : createTaskForClosedOutreach
    @description    : Create task for outreach request
    @param          : List<Outreach_Request__c> newOutreachRequestList
    @return         : void
    ********************************************************
    */
    private static void createTaskForClosedOutreach(List<Outreach_Request__c> listOfSignInSheetOutreach){
        List<Task> listOfTaskToCreate = new List<Task>();
        Map<String,Id> groupNameAndIdMap = new Map<String,Id>();
        Set<Id> userId = new set<Id>();
        Map<Id, String> mapOfUserIdWithRegionalCenter = new Map<Id, String>();
        Map<String,String> mapRegionalCenterGroups = NC_Constant.mapRegionalCenterGroups;
        Map<Id, List<Id>> mapOfGroupIdWithUsers = new Map<Id, List<Id>>();

        for(Group publicGroup : [SELECT Id, Name, DeveloperName FROM Group WHERE Type =: NC_Constant.PUBLIC_GROUP_TYPE AND DeveloperName IN: mapRegionalCenterGroups.values()]) {
            groupNameAndIdMap.put(publicGroup.DeveloperName,publicGroup.Id);
        }

        for(Outreach_Request__c outreachRequest :listOfSignInSheetOutreach){
            userId.add(outreachRequest.OwnerId);
        }

        for(User userRecord : [SELECT Id, Regional_Center__c FROM User WHERE Id IN: userId AND isActive = true]){
            mapOfUserIdWithRegionalCenter.put(userRecord.Id, userRecord.Regional_Center__c);
        }
        
        Set<Id> activeUserIds = new Set<Id>();
        for(user userObj: [SELECT id FROM User WHERE Id IN (SELECT UserorGroupId FROM GroupMember WHERE GroupId IN: groupNameAndIdMap.values()) AND isActive = true]) {
            activeUserIds.add(userObj.id);
        }

        for(GroupMember groupmemberRecord : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN: groupNameAndIdMap.values()]){
            if(activeUserIds.contains(groupmemberRecord.UserOrGroupId)) {
             	if(!mapOfGroupIdWithUsers.containsKey(groupmemberRecord.GroupId)){
                    mapOfGroupIdWithUsers.put(groupmemberRecord.GroupId, new List<Id>());
                }
                mapOfGroupIdWithUsers.get(groupmemberRecord.GroupId).add(groupmemberRecord.UserOrGroupId);   
            }
        }

        for(Outreach_Request__c outreachRequest : [SELECT Id, OwnerId, Start_Date_of_Event__c FROM Outreach_Request__c WHERE Id IN: listOfSignInSheetOutreach WITH SECURITY_ENFORCED]){
            if(mapOfUserIdWithRegionalCenter.containsKey(outreachRequest.OwnerId) 
                && mapRegionalCenterGroups.containsKey(mapOfUserIdWithRegionalCenter.get(outreachRequest.OwnerId))){
                String groupId = String.valueOf(groupNameAndIdMap.get(mapRegionalCenterGroups.get(mapOfUserIdWithRegionalCenter.get(outreachRequest.OwnerId)))).subString(0,15);
                for(Id idValue : mapOfGroupIdWithUsers.get(groupId)){
                    Task taskInsert = new Task();
                    taskInsert.OwnerId = idValue;
                    taskInsert.Subject = 'Sign In Sheet Follow up';
                    taskInsert.WhatId = outreachRequest.Id;
                    taskInsert.Description__c = 'Please make sure to enter the contacts from the sign-in sheet and complete actions related to those contacts.';
                    taskInsert.ActivityDate = System.Today().addDays(30);
                    listOfTaskToCreate.add(taskInsert);
                }
            }
        }
        if(!listOfTaskToCreate.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Task', listOfTaskToCreate, 'insert', true,'NC_CloseEventController','createTaskForClosedOutreach');
            insert objectDecision.getRecords();
        }
    }
}