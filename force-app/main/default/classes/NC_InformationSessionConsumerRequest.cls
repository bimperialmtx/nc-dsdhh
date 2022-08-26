/*
*   Class Name: NC_InformationSessionConsumerRequest
*   Description: 
*
*   Date            New/Modified         User                 Identifier                Description
*   21/06/2020         New         Hiten Aggarwal(mtx)
*/
public  without sharing class NC_InformationSessionConsumerRequest {

    private Static Final Id informationSessionAttendeeRecordType =  NC_Utility.RecordTypeUtilityMethod('Attendees__c',  'Attendees_For_Outreach_Request');
    private Static Final Id informationSessionOutreachRecordType =  NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c',  'Information_Session');
    
    /*
    *********************************************************
    @Method Name    : fetchConsumerList
    @description    : Fetch all consumer related to outreach request of Attendees
    @param          : Id recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> fetchConsumerList(Id recordId){
        List<ConsumerWrapper> listOfConsumerWrapper = new List<ConsumerWrapper>();
        List<Id> contactIdList = new List<Id>();
        Map<String, Object> result = new Map<String, Object>();
        Integer numberOfAttendeesAlreadyPresent = 0;
        
        for(Attendees__c attendee: [SELECT id, Contact__c 
                                    FROM Attendees__c
                                    WHERE Outreach_Request__c	 =: recordId and RecordTypeId =: informationSessionAttendeeRecordType WITH SECURITY_ENFORCED]){
                    contactIdList.add(attendee.Contact__c);
                    numberOfAttendeesAlreadyPresent++;
        }

        ConsumerWrapper consumer;
        for(Contact contactRecord : [SELECT Id, Name, Email FROM Contact WITH SECURITY_ENFORCED]){
            if(!contactIdList.contains(contactRecord.Id)){
                consumer = new ConsumerWrapper();
                consumer.consumerId = contactRecord.Id;
                consumer.consumerEmailId = contactRecord.Email ;
                consumer.consumerName = contactRecord.Name;
                listOfConsumerWrapper.add(consumer);
            }
        }
        if(listOfConsumerWrapper.size()>0){
            result.put('result', listOfConsumerWrapper);
        }else{
            result.put('error', 'No Consumer Found.');
        }
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : sendInviationToConsumer
    @description    : Send invitation to consumer
    @param          : String consumerdata, Id recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> sendInviationToConsumer(String consumerdata, Id recordId){
        Map<String, Object> result = new Map<String, Object>();
        List<Attendees__c> attendeeList = new List<Attendees__c>();
        List<Task> taskList = new List<Task>();
        Boolean isSelected = false;
        Integer count = 0;
        Integer numberOfAttendeesAlreadyPresent = 0;
        List<ConsumerWrapper> consumerWrapperList = (List<ConsumerWrapper>) JSON.deserialize(consumerdata, List<ConsumerWrapper>.class);
        
        Outreach_Request__c informationOutreach = [SELECT id, OwnerId 
                                                   FROM Outreach_Request__c
                                                   WHERE Id =: recordId WITH SECURITY_ENFORCED
                                                   ];
        
        Map<Id,Attendees__c> consumerIdToAttendeeMap = new Map<Id,Attendees__c>();
        for(Attendees__c attendee : [SELECT id, Contact__c  FROM Attendees__c WHERE Outreach_Request__c	 =: recordId And RecordTypeId =: informationSessionAttendeeRecordType WITH SECURITY_ENFORCED]){
            consumerIdToAttendeeMap.put(attendee.Contact__c, attendee);
        }

        numberOfAttendeesAlreadyPresent = consumerIdToAttendeeMap.values().size();
            
        for(ConsumerWrapper consumerWrapperRecord : consumerWrapperList){
            if(consumerWrapperRecord.isSelected){
                if(!consumerIdToAttendeeMap.containsKey(consumerWrapperRecord.consumerId)){
                    isSelected = true;
                    Attendees__c attendee = new Attendees__c();
                    attendee.contact__c = consumerWrapperRecord.consumerId;
                    attendee.Outreach_Request__c	 = recordId;
                    attendee.RecordTypeId = informationSessionAttendeeRecordType;
                    attendeeList.add(attendee);
                    
                    Task task = new Task();
                    task.OwnerId = informationOutreach.OwnerId;
                    task.Subject = 'Send out Information Package To ' + consumerWrapperRecord.consumerName;
                    task.WhatId = informationOutreach.Id;
                    task.Description__c = 'Please send out the information package to the attendee.';
                    task.ActivityDate = Date.Today() + 7;
                    task.WhoId = consumerWrapperRecord.consumerId;
                    taskList.add(task);
                    count++;
                }
            }
        }
        
        if(count > 10 - (numberOfAttendeesAlreadyPresent != Null ? numberOfAttendeesAlreadyPresent : 0)){
            String  message = 10 - + (numberOfAttendeesAlreadyPresent != Null ? numberOfAttendeesAlreadyPresent : 0) + ' slots only.';
            result.put('error', message);
            return result;
        }else if(attendeeList.Size()>0){
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Attendees__c', attendeeList, 'insert', true, 'NC_InformationSessionConsumerRequest','sendInviationToConsumer');
            Insert decision.getRecords();
            //Insert attendeeList;
            String  message = 'Invitation send successfully.';
            result.put('success', message);       
            if(taskList.size() > 0){
                //Insert taskList;
                SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Task', taskList, 'insert', true, 'NC_InformationSessionConsumerRequest','sendInviationToConsumer' );
                Insert decision1.getRecords();
            }
            return result;
        }else if(isSelected){
            String  message = 'Consumer Already Invited.';
            result.put('warning', message);
            return result;
        }else{
            String  message = 'Please select a consumer.';
            result.put('error', message);
            return result;
        }
    }


    class ConsumerWrapper{
        @AuraEnabled public String consumerName;
        @AuraEnabled public String consumerId;
        @AuraEnabled public String consumerEmailId;
        @AuraEnabled public Boolean isSelected;
       
        public ConsumerWrapper(){
            this.consumerName = '';
            this.consumerId = '';
            this.consumerEmailId = '';
            this.isSelected = false;
        }
    }
}