/*
*   Class Name: NC_RollupUtility
*   Description: Utility for The Roll Up Summry
*
*   Date            New/Modified         User                 Identifier                Description
*   06/10/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_RollupUtility {
    
    /*
    *********************************************************
    @Method Name    : rollUpTrigger
    @description    : Roll Summry Field
    @param          : list<fieldDefinition> fieldDefinitions,list<sObject> records, String childObject, String childParentLookupField,String parentObject, String queryFilter
    @return         : void
    ********************************************************
    */
    public static void rollUpTrigger(list<fieldDefinition> fieldDefinitions,list<sObject> records, String childObject, String childParentLookupField,String parentObject, String queryFilter) {
        //Limit the size of list by using Sets which do not contain duplicate
        //elements prevents hitting governor limits
        set<Id> parentIds = new set<Id>();
        for(sObject objectRecord : records) {
            parentIds.add((Id)objectRecord.get(childParentLookupField));
        }
        //populate query text strings to be used in child aggregrator and
        //parent value assignment
        String fieldsToAggregate = '';
        String parentFields = '';
        for(fieldDefinition defination : fieldDefinitions) {
            fieldsToAggregate += defination.operation + '(' + defination.childField + ') ' +', ';
            parentFields += defination.parentField + ', ';
        }
        //Using dynamic SOQL with aggergate results to populate parentValueMap
        String aggregateQuery = 'Select ' + String.escapeSingleQuotes(fieldsToAggregate) + String.escapeSingleQuotes(childParentLookupField) + ' from ' + String.escapeSingleQuotes(childObject) + ' where ' + String.escapeSingleQuotes(childParentLookupField) + ' IN :parentIds ' + String.escapeSingleQuotes(queryFilter) + ' ' +' group by ' + String.escapeSingleQuotes(childParentLookupField);
        //Map will contain one parent record Id per one aggregate object
        map<Id, AggregateResult> parentValueMap =
        new map <Id, AggregateResult>();
        for(AggregateResult query : Database.query(aggregateQuery)){
            parentValueMap.put((Id)query.get(childParentLookupField), query);
        }
        //list of parent object records to update
        list<sObject> parentsToUpdate = new list<sObject>();
        String parentQuery = 'select ' + String.escapeSingleQuotes(parentFields) + ' Id ' + ' from ' + String.escapeSingleQuotes(parentObject) + ' where Id IN :parentIds';
        //for each affected parent object, retrieve aggregate results and
        //for each field definition add aggregate value to parent field
        for(sObject record : Database.query(parentQuery)) {
            Integer row = 0; //row counter reset for every parent record
            for(fieldDefinition defination : fieldDefinitions) {
                String field = 'expr' + row.format();
                AggregateResult result = parentValueMap.get(record.Id);
                //r will be null if no records exist
                //(e.g. last record deleted)
                if(result != null) {
                    Decimal value = ((Decimal)result.get(field) == null ) ? 0 : (Decimal)result.get(field);
                    record.put(defination.parentField, value);
                } else {
                    record.put(defination.parentField, 0);
                }
                row += 1; //plus 1 for every field definition after first
            }
            parentsToUpdate.add(record);
        }
        //if parent records exist, perform update of all parent records
        //with a single DML statement
        if(parentsToUpdate.Size() > 0) {
            for(Sobject sobj: parentsToUpdate) {
                if(sobj.getSObjectType() == Authorization__c.getSObjectType()){
                    sobj.put('Update_If_Vendor_Inactive__c', true);
                }
                if(sobj.getSObjectType() == Communication_Access_Request__c.getSObjectType()) {
                    sobj.put('Is_Roll_Up__c', true);
                }
            }
            
            update parentsToUpdate;
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('sObject', parentsToUpdate, 'update', true,'NC_RollupUtility','rollUpTrigger');
            //update decision.getRecords();
        }
    }

    public class fieldDefinition{
        public String operation;
        public String childField;
        public String parentField;
        
        public fieldDefinition (String operation, String childField, String parentField) {
            this.operation = operation;
            this.childField = childField;
            this.parentField = parentField;
        }
    }
}