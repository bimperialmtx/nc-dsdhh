/**
 * @description       : 
 * @author            : Gourav Nirwal
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : Gourav Nirwal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   06-10-2021   Gourav Nirwal   Initial Version
**/
public with sharing class SecurityLibrary {
    /*
    public static SObjectAccessDecision getAccessibleData(String sObjectName, List<sObject> sObjList, String dmlAction, Boolean throwException){
        dmlAction = dmlAction.toLowerCase();
        SObjectAccessDecision securityDecision;
        switch on dmlAction {
            when 'insert'{
                securityDecision = Security.stripInaccessible(
                    AccessType.CREATABLE, sObjList);
            }
            when 'update'{
                securityDecision = Security.stripInaccessible(
                    AccessType.UPDATABLE, sObjList);
            }
            when 'upsert'{
                securityDecision = Security.stripInaccessible(
                    AccessType.UPSERTABLE, sObjList);
            }   
            when 'read'{
                securityDecision = Security.stripInaccessible(
                    AccessType.READABLE, sObjList);
            }        
        }

        //Remove Formula && standard non editable fields
        Set<String> nonEditableFields = new Set<String>{'IsDeleted','CreatedById','CreatedDate','LastModifiedById','LastModifiedDate','SystemModstamp','IsCustomerPortal', 'LastActivityDate'};
        if(securityDecision != null && !securityDecision.getRemovedFields().isEmpty()){
            if(securityDecision.getRemovedFields().get(sObjectName) != null){
                Schema.SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
                Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
                
                Set<String> formulaFieldRemovedSet = new Set<String>();
                for(String field: securityDecision.getRemovedFields().get(sObjectName)) {
                    if(fieldMap.containsKey(field)) {
                        Schema.SobjectField sObjectField = fieldMap.get(field);
                        if(!sObjectField.getDescribe().isAutoNumber() && !sObjectField.getDescribe().isUpdateable() && !sObjectField.getDescribe().isCalculated() && !nonEditableFields.contains(field)) {
                            formulaFieldRemovedSet.add(field);
                        }
                    }
                }
                if(formulaFieldRemovedSet.size() > 0) {
                    securityDecision.getRemovedFields().put(sObjectName, formulaFieldRemovedSet);
                } else {
                    securityDecision.getRemovedFields().remove(sObjectName);
                }
            }
        }

        if(securityDecision != null && !securityDecision.getRemovedFields().isEmpty() && throwException == true){
            List<String> fieldsList = new List<String>();
            if(securityDecision.getRemovedFields().get(sObjectName) != null){
                fieldsList.addAll(securityDecision.getRemovedFields().get(sObjectName));
            }
            else{
                for(Set<String> strSet : securityDecision.getRemovedFields().values()){
                    fieldsList.addAll(strSet);
                }
            }
           
            String inaccessibleFields = String.join(fieldsList, ', ');
            String message = 'You don\'t have access to ' + dmlAction + ' ' + inaccessibleFields + ' on ' + sObjectName;
            // Create a custom exception class to throw exception from this method.
            //throw new NC_Custom_Exception(message);
        }
        return securityDecision;
    }*/
    /*
    *********************************************************
    @Method Name    : getAccessibleData
    @description    : Remove not accessible fields or object and throw exception
    @param          : String sObjectName, List<sObject> sObjList, String dmlAction, Boolean throwException, String className, String methodName
    @return         : SObjectAccessDecision
    ********************************************************
    */
    public static SObjectAccessDecision getAccessibleData(String sObjectName, List<sObject> sObjList, String dmlAction, Boolean throwException, String className, String methodName){
        dmlAction = dmlAction.toLowerCase();
        SObjectAccessDecision securityDecision;
        switch on dmlAction {
            when 'insert'{
                securityDecision = Security.stripInaccessible(
                    AccessType.CREATABLE, sObjList);
            }
            when 'update'{
                securityDecision = Security.stripInaccessible(
                    AccessType.UPDATABLE, sObjList);
            }
            when 'upsert'{
                securityDecision = Security.stripInaccessible(
                    AccessType.UPSERTABLE, sObjList);
            }   
            when 'read'{
                securityDecision = Security.stripInaccessible(
                    AccessType.READABLE, sObjList);
            }        
        }

        //Remove Formula && standard non editable fields
        Set<String> nonEditableFields = new Set<String>{'IsDeleted','CreatedById','CreatedDate','LastModifiedById','LastModifiedDate','SystemModstamp','IsCustomerPortal', 'LastActivityDate'};
        if(securityDecision != null && !securityDecision.getRemovedFields().isEmpty()){
            if(securityDecision.getRemovedFields().get(sObjectName) != null){
                Schema.SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
                Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
                
                Set<String> formulaFieldRemovedSet = new Set<String>();
                for(String field: securityDecision.getRemovedFields().get(sObjectName)) {
                    if(fieldMap.containsKey(field)) {
                        Schema.SobjectField sObjectField = fieldMap.get(field); //  && !sObjectField.getDescribe().isUpdateable() 
                        if(!sObjectField.getDescribe().isAutoNumber() && !sObjectField.getDescribe().isCalculated() && !nonEditableFields.contains(field)) {
                            formulaFieldRemovedSet.add(field);
                        }
                    }
                }
                if(formulaFieldRemovedSet.size() > 0) {
                    securityDecision.getRemovedFields().put(sObjectName, formulaFieldRemovedSet);
                } else {
                    securityDecision.getRemovedFields().remove(sObjectName);
                }
            }
        }

        if(securityDecision != null && !securityDecision.getRemovedFields().isEmpty() && throwException == true){
            List<String> fieldsList = new List<String>();
            if(securityDecision.getRemovedFields().get(sObjectName) != null){
                fieldsList.addAll(securityDecision.getRemovedFields().get(sObjectName));
            }
            else{
                for(Set<String> strSet : securityDecision.getRemovedFields().values()){
                    fieldsList.addAll(strSet);
                }
            }
           
            String inaccessibleFields = String.join(fieldsList, ', ');
            String message = 'You don\'t have access to ' + dmlAction + ' ' + inaccessibleFields + ' on ' + sObjectName;
            
            //create Error object
            Id securityRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Error__c','Security_Error');

            if(Schema.sObjectType.Error__c.isCreateable() && Schema.sObjectType.Error__c.fields.Error_Description__c.isCreateable()){
                Error__c error = new Error__c();
                error.RecordTypeId = securityRecordTypeId;
                error.Error_Description__c = UserInfo.getUserId() + '\n' + className + ': ' + methodName + '\n' +  + message;
                insert error;   
            } else {
             	// Create a custom exception class to throw exception from this method.
            	throw new NC_Custom_Exception(message);   
            }
        }
        return securityDecision;
    }

}