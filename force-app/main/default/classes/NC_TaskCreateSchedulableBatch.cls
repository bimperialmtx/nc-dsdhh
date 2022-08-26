/*
**   Class Name: NC_TaskCreateSchedulableBatch
**   Description: Batch class for Outreach
**
**     Date            New/Modified           User                 Identifier                Description
**   26-05-2020             New          Hiten Aggarwal
*/
global class NC_TaskCreateSchedulableBatch implements Database.Batchable<sObject>, schedulable{
   global void execute(SchedulableContext sc){
        NC_TaskCreateSchedulableBatch taskCreateObject = new NC_TaskCreateSchedulableBatch();
        database.executeBatch(taskCreateObject);
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
      String previousDayDate = String.valueOf(system.Today()-1);
       if(Test.isRunningTest()) {
           previousDayDate = String.valueOf(system.Today()+1);
       }
      String query = 'SELECT Id,Name,Start_Date_of_Event__c,OwnerId FROM Outreach_Request__c Where DAY_ONLY(Start_Date_of_Event__c) =' + previousDayDate;
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<sObject> sObjectList){
        List<Outreach_Request__c> listOfSignInSheetOutreach = (List<Outreach_Request__c>) sObjectList;
        List<Task> listOfTaskToCreate = new List<Task>();
        Map<String,Id> groupNameAndIdMap = new Map<String,Id>();
        Set<Id> userId = new set<Id>();
        Map<Id, String> mapOfUserIdWithRegionalCenter = new Map<Id, String>();
        Map<String,String> mapRegionalCenterGroups = NC_Constant.mapRegionalCenterGroups;
        Map<Id, List<Id>> mapOfGroupIdWithUsers = new Map<Id, List<Id>>();
       
       	Map<Id, User> activeUserMap = new Map<Id, User>([SELECT isActive FROM User WHERE isActive = true]);

        for(Group publicGroup : [SELECT Id, Name, DeveloperName FROM Group WHERE Type =: NC_Constant.PUBLIC_GROUP_TYPE AND DeveloperName IN: mapRegionalCenterGroups.values()]) {
            groupNameAndIdMap.put(publicGroup.DeveloperName,publicGroup.Id);
        }

        for(Outreach_Request__c outreachRequest :listOfSignInSheetOutreach){
            userId.add(outreachRequest.OwnerId);
        }

        for(User userRecord : [SELECT Id, Regional_Center__c FROM User WHERE Id IN: userId AND isActive = true]){
            mapOfUserIdWithRegionalCenter.put(userRecord.Id, userRecord.Regional_Center__c);
        }

        for(GroupMember groupmemberRecord : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN: groupNameAndIdMap.values()]){
            if(!mapOfGroupIdWithUsers.containsKey(groupmemberRecord.GroupId)){
                mapOfGroupIdWithUsers.put(groupmemberRecord.GroupId, new List<Id>());
            }
            mapOfGroupIdWithUsers.get(groupmemberRecord.GroupId).add(groupmemberRecord.UserOrGroupId);
        }

        for(Outreach_Request__c outreachRequest : [SELECT Id, OwnerId, Start_Date_of_Event__c FROM Outreach_Request__c WHERE Id IN: listOfSignInSheetOutreach]){
            if(mapOfUserIdWithRegionalCenter.containsKey(outreachRequest.OwnerId) 
                && mapRegionalCenterGroups.containsKey(mapOfUserIdWithRegionalCenter.get(outreachRequest.OwnerId))){
                String groupId = String.valueOf(groupNameAndIdMap.get(mapRegionalCenterGroups.get(mapOfUserIdWithRegionalCenter.get(outreachRequest.OwnerId)))).subString(0,15);
                for(Id idValue : mapOfGroupIdWithUsers.get(groupId)){
                    if(String.valueOf(idValue).subString(3) == '00G' || (String.valueOf(idValue).subString(3) == '005' && activeUserMap.containsKey(idValue))) {
                     	Task taskInsert = new Task();
                        taskInsert.OwnerId = idValue;
                        taskInsert.Subject = 'Sign In Sheet Follow up';
                        taskInsert.WhatId = outreachRequest.Id;
                        taskInsert.Description__c = 'Please make sure to enter the contacts from the sign-in sheet and complete actions related to those contacts.';
                        taskInsert.ActivityDate = outreachRequest.Start_Date_of_Event__c.date().addDays(30);
                        listOfTaskToCreate.add(taskInsert);   
                    }
                }
            }
        }
        if(!listOfTaskToCreate.isEmpty()){
            INSERT listOfTaskToCreate;
        }
    }

   public void finish(Database.BatchableContext BC){
       //finsh code
   }
}