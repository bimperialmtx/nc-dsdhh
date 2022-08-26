/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_EventAuthorizationTriggerHandler {
    
    public static Id ndbedpTrainingCost = NC_Utility.RecordTypeUtilityMethod('Event_Authorization__c', 'NDBEDP_Training_Attendee_cost');
    public static Id ndbedpOutreachCost = NC_Utility.RecordTypeUtilityMethod('Event_Authorization__c', 'NDBEDP_Outreach_Attendee_Cost');

    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'after insert' trigger event
    @param          : List<Event_Authorization__c> newList
    @return         : void
    ********************************************************
    */
    public static void afterInsert(List<Event_Authorization__c> newList){
        List<Event_Authorization__c> eventAuthList = new List<Event_Authorization__c>();
        for(Event_Authorization__c eventAuth: newList) {
            Event_Authorization__c eventAuthObj = new Event_Authorization__c(); 
            eventAuthObj.id = eventAuth.id;
            eventAuthObj.NDBEDP_Total_Cost_Rollup__c = eventAuth.NDBEDP_Total_Cost__c;
            eventAuthList.add(eventAuthObj);
        }
        if(eventAuthList.size() > 0) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Event_Authorization__c', eventAuthList, 'update', true,'NC_EventAuthorizationTriggerHandler','afterInsert');
            update objectDecision.getRecords();
           // update eventAuthList;
        }
        updateNDBEDPBudget(newList, null);
    }

    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before update' trigger event
    @param          : List<Event_Authorization__c> newList ,Map<Id, Event_Authorization__c> oldMap, Map<Id, Event_Authorization__c> newMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Event_Authorization__c> newList ,Map<Id, Event_Authorization__c> oldMap, Map<Id, Event_Authorization__c> newMap){
        for(Event_Authorization__c eventAuth: newList) {
            eventAuth.NDBEDP_Total_Cost_Rollup__c = eventAuth.NDBEDP_Total_Cost__c;
        }
    }

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after update' trigger event
    @param          : List<Event_Authorization__c> newList ,Map<Id, Event_Authorization__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Event_Authorization__c> newList ,Map<Id, Event_Authorization__c> oldMap){
        updateNDBEDPBudget(newList, oldMap);
    }

    /*
    *********************************************************
    @Method Name    : afterDelete
    @description    : calling this method on 'after delete' trigger event
    @param          : Map<Id, Event_Authorization__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterDelete(Map<Id, Event_Authorization__c> oldMap){
        updateNDBEDPBudget(null, oldMap);
    }

    /*
    *********************************************************
    @Method Name    : afterUndelete
    @description    : calling this method on 'after undelete' trigger event
    @param          : List<Event_Authorization__c> newList
    @return         : void
    ********************************************************
    */
    public static void afterUndelete(List<Event_Authorization__c> newList){
        updateNDBEDPBudget(newList, null);
    }

    /*
    *********************************************************
    @Method Name    : updateNDBEDPBudget
    @description    : Update NDBEDP budget on change on cost fields
    @param          : List<Event_Authorization__c> newList, Map<Id, Event_Authorization__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateNDBEDPBudget(List<Event_Authorization__c> newList, Map<Id, Event_Authorization__c> oldMap) {
        List<Budget_Management__c> updateBudgetList = new List<Budget_Management__c>();
        Map<Id, Event_Authorization__c> eventAuthMap = new Map<Id, Event_Authorization__c>();
        Map<Id, Event_Authorization__c> eventAuthOldMap = new Map<Id, Event_Authorization__c>();

        if(newList == null && oldMap != null) {
            for(Id eventAuthId: oldMap.keySet()) {
                if((oldMap.get(eventAuthId).recordTypeId == ndbedpTrainingCost || oldMap.get(eventAuthId).recordTypeId == ndbedpOutreachCost)
                    && oldMap.get(eventAuthId).NDBEDP_Total_Cost__c > 0) {
                        eventAuthMap.put(eventAuthId, null);
                        eventAuthOldMap.put(eventAuthId, oldMap.get(eventAuthId));
                }
            }
        } else {
            for(Event_Authorization__c eventAuth: newList) {
                if(oldMap != null && newList != null
                && (eventAuth.recordTypeId == ndbedpTrainingCost || eventAuth.recordTypeId == ndbedpOutreachCost)
                && eventAuth.NDBEDP_Total_Cost__c != oldMap.get(eventAuth.id).NDBEDP_Total_Cost__c) {
                    eventAuthMap.put(eventAuth.id, eventAuth);
                    eventAuthOldMap.put(eventAuth.id, oldMap.get(eventAuth.id));
                } else if (oldMap == null && newList != null
                    && (eventAuth.recordTypeId == ndbedpTrainingCost || eventAuth.recordTypeId == ndbedpOutreachCost)
                    && eventAuth.NDBEDP_Total_Cost__c > 0) {
                        eventAuthMap.put(eventAuth.id, eventAuth);
                        eventAuthOldMap.put(eventAuth.id, null);
                }
            }   
        }
        if(eventAuthMap.size() > 0) {
            Id eventAuthRecordId;
            Date currentDate = System.today();
            List<Budget_Management__c> budgetList = [SELECT Amount_Utilized__c, Total_Amount__c FROM Budget_Management__c WHERE Budget_Type__c = 'NDBEDP Budget' AND Start_Date_Fiscal_Year_Formula__c <=: currentDate AND End_Date_Fiscal_Year_Formula__c >=: currentDate WITH SECURITY_ENFORCED LIMIT 1];
            Decimal amountUtilized = budgetList[0].Amount_Utilized__c;
            for(Id eventAuthId: eventAuthMap.keySet()) {
                if(!budgetList.isEmpty()) {
                    amountUtilized -= (eventAuthOldMap.containsKey(eventAuthId) && eventAuthOldMap.get(eventAuthId) != null) ?  eventAuthOldMap.get(eventAuthId).NDBEDP_Total_Cost__c : 0;
                    amountUtilized += (eventAuthMap.containsKey(eventAuthId) && eventAuthMap.get(eventAuthId) != null) ?  eventAuthMap.get(eventAuthId).NDBEDP_Total_Cost__c : 0;
                    eventAuthRecordId = eventAuthId;
                } else {
                    trigger.newmap.get(eventAuthId).addError('NDBEDP Budget not available for current year.');
                    break;
                }
            }
            //if(amountUtilized <= budgetList[0].Total_Amount__c) {
                Budget_Management__c budget = new Budget_Management__c();
                budget.id = budgetList[0].id;
                budget.Amount_Utilized__c = amountUtilized;
                updateBudgetList.add(budget);
            //} else {
                //trigger.newmap.get(eventAuthRecordId).addError('Insufficient NDBEDP Budget for current year.');
            //}
        }

        if(updateBudgetList.size() > 0) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Budget_Management__c', updateBudgetList, 'update', true,'NC_EventAuthorizationTriggerHandler','updateNDBEDPBudget');
            update objectDecision.getRecords();
           // update updateBudgetList;
        }
    }
}