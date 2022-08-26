/*
**   Class Name: NC_AssetContactAttemptTaskCreateBatch
**   Description: Batch class for Recieved Task
**
**     Date            New/Modified           User                 Identifier                Description
**   26-05-2020             New          Hiten Aggarwal
*/

global class NC_AssetContactAttemptTaskCreateBatch implements Database.Batchable<sObject>, schedulable{
    
    global void execute(SchedulableContext sc){
        NC_AssetContactAttemptTaskCreateBatch taskObject = new NC_AssetContactAttemptTaskCreateBatch();
        database.executeBatch(taskObject);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id contactAttemptAssetTypeId = NC_Utility.RecordTypeUtilityMethod('Contact_Attempt__c', 'Contact_Attempt_For_Asset');
        String dateTenDaysBack = String.valueOf(Date.today()-10);       
        
        Date dateSevenDaysBack = Date.today()-7;   //Date.today()-7;
        if(Test.isRunningTest()){
            dateSevenDaysBack = Date.today();
        }
        Set<Id> assetIdSet = new Set<Id>();
        Map<Id,List<Contact_Attempt__c>> assetToContactAttemptNumber = new Map<Id,List<Contact_Attempt__c>>();
        for(Contact_Attempt__c contactAttempt: [SELECT Id,Asset__c, Asset__r.Status__c, CreatedDate
                                                FROM Contact_Attempt__c 
                                                WHERE RecordTypeId =: contactAttemptAssetTypeId 
                                                AND Asset__r.Status__c = 'Received']){ //AND DAY_ONLY(CreatedDate) =: dateSevenDaysBack
                                                    if(!assetToContactAttemptNumber.containsKey(contactAttempt.Asset__c)){
                                                        assetToContactAttemptNumber.put(contactAttempt.Asset__c,new List<Contact_Attempt__c>());
                                                    }
                                                    assetToContactAttemptNumber.get(contactAttempt.Asset__c).add(contactAttempt);   
                                                }
        
        for(Id assetRecordId : assetToContactAttemptNumber.keySet()){
            for(Contact_Attempt__c contactAttempt : assetToContactAttemptNumber.get(assetRecordId)){
                if(assetToContactAttemptNumber.get(assetRecordId).size() < 3  && contactAttempt.CreatedDate.Date() == dateSevenDaysBack){
                    assetIdSet.add(assetRecordId);
                } 
            }
        }
        String query = 'SELECT Id, Request__r.OwnerId, LastModifiedDate FROM Asset__c Where Id IN: assetIdSet OR ( Status__c =\'Received\' AND DAY_ONLY(LastModifiedDate) = '+ dateTenDaysBack +' )';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> sObjectList){
        List<Asset__c> assetList = (List<Asset__c>) sObjectList;
        List<Task> listOfTaskToCreate = new List<Task>();
        Date dateTenDaysBack = Date.today()-10; 
        for(Asset__c assetRecord : assetList){
            Task taskInsert = new Task();
            if(assetRecord.LastModifiedDate.Date() == dateTenDaysBack){
                taskInsert = createTaskUtitlity(assetRecord.Request__r.OwnerId,'Follow up with Consumer',assetRecord.Id, 'Please follow up with Consumer to confirm Equipment pick up.',Date.Today().addDays(7) );
                listOfTaskToCreate.add(taskInsert); 
            }else{
                taskInsert = createTaskUtitlity(assetRecord.Request__r.OwnerId,'Follow up with Consumer',assetRecord.Id, 'Please follow up with Consumer again to confirm Equipment pick up.',Date.Today().addDays(7) );
                listOfTaskToCreate.add(taskInsert); 
            }     
        }
        if(!listOfTaskToCreate.isEmpty()){
            INSERT listOfTaskToCreate;
        }
    }
    
    private static Task createTaskUtitlity(Id ownerId, String subject, Id whatID, String description, Date dueDate){
        Task taskInsert = new Task();
        taskInsert.OwnerId = ownerId;
        taskInsert.Subject = subject;
        taskInsert.WhatId = whatID;
        taskInsert.Description__c = description;
        taskInsert.ActivityDate = dueDate;
        return taskInsert;
    }
    
    public void finish(Database.BatchableContext BC){
        //finsh code
    }
    
}