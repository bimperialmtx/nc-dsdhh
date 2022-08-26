/*
**   Class Name: NC_CheckRequestInActivity
**   Description: Batch class for Inactive Case
**
**     Date            New/Modified           User                 Identifier                Description
**   26-05-2020             New          Hiten Aggarwal
*/
global class NC_CheckRequestInActivityBatch implements Database.Batchable<sObject>, schedulable{
    
    global void execute(SchedulableContext sc){
        NC_CheckRequestInActivityBatch taskObject = new NC_CheckRequestInActivityBatch();
        database.executeBatch(taskObject);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id requestRecordTypeEquipment = NC_Utility.RecordTypeUtilityMethod('Case', 'Equipment');
        String dateSixMonthBack = String.valueOf(Date.today()-180);
        String dateOneYearBack  = String.valueOf(Date.today()-365);
        if(Test.isRunningTest()){
            dateSixMonthBack = String.valueOf(Date.today());
            dateOneYearBack = String.valueOf(Date.today());
        }
        
        String query = 'SELECT Id,CreatedDate,LastModifiedDate,Status FROM Case Where RecordTypeId =: requestRecordTypeEquipment ';
        query+=' AND Status != \'Approved\' AND  Status != \'Closed\'  AND  Status != \'Denied\' AND  Status != \'Inactive\'  AND Status != \'Withdrawn\''; 
        query+=' AND ( DAY_ONLY( LastModifiedDate ) = '+ dateSixMonthBack;
        query+=' OR DAY_ONLY( LastModifiedDate ) = '+  dateOneYearBack + ' )';
        
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> sObjectList){
        List<Case> caseRecordList = (List<Case>) sObjectList;
        List<Task> listOfTaskToCreate = new List<Task>();
        List<Case> caseUpdateList = new List<Case>();
        
        Date dateSixMonthBack = Date.today()-180;   
        Date dateOneYearBack  = Date.today()-365; 
        
        if(Test.isRunningTest()){
            dateSixMonthBack = Date.today();
            dateOneYearBack = Date.today();
        }
        
        for(Case caseRecord : [SELECT Id,OwnerID,CreatedDate,LastModifiedDate,Status FROM Case WHERE Id IN: caseRecordList]){
            if(caseRecord.LastModifiedDate.Date() == dateSixMonthBack){
                Task taskInsert = new Task();
                taskInsert.OwnerId = caseRecord.OwnerId;
                taskInsert.Subject = '6 month EDS request follow up';
                taskInsert.WhatId = caseRecord.Id;
                taskInsert.Description__c = 'Follow up with Consumer to see if the request can be completed or set the status of the request to Inactive.';
                taskInsert.ActivityDate = Date.Today().addDays(10);
                listOfTaskToCreate.add(taskInsert);
            }
            if(caseRecord.LastModifiedDate.Date() == dateOneYearBack && caseRecord.Status != 'Closed'){
                caseRecord.Status = 'Closed';
                caseUpdateList.add(caseRecord);
            }
        }
        if(!listOfTaskToCreate.isEmpty()){
            INSERT listOfTaskToCreate;
        }
        if(!caseUpdateList.isEmpty()){
            Update caseUpdateList;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        //finsh code
    }
}