/*
*   Class Name: NC_ValidationUtility
*   Description: 
*
*   Date            New/Modified         User                 Identifier                Description
*   30/04/2020         New             Gourav(mtx)
*   
*/
public without sharing class NC_ValidationUtility {

    /*
    *********************************************************
    @Method Name    : retrieveQueryString
    @description    : Retrieve query string to get latest data
    @param          : String sObjectName, Map<String, List<Validation_Configuration__mdt>> mapOfObjectWithListOfValidation
    @return         : String
    ********************************************************
    */
    public static String retrieveQueryString(String sObjectName, Map<String, List<Validation_Configuration__mdt>> mapOfObjectWithListOfValidation) {
        String queryString = ' SELECT Id ';
        Map<String, Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();
        if(mapOfObjectWithListOfValidation != null && mapOfObjectWithListOfValidation.containsKey(sObjectName) && globalDescribe.containsKey(sObjectName)){
            Map<String,Schema.SobjectField> fieldsMap = globalDescribe.get(sObjectName).getDescribe().fields.getMap();
            for(Validation_Configuration__mdt validationRecord : mapOfObjectWithListOfValidation.get(sObjectName)){
                if(String.isNotBlank(validationRecord.Field_API_Name__c)){
                    if(fieldsMap.containsKey(validationRecord.Field_API_Name__c)){
                        queryString += ', ' + String.escapeSingleQuotes(validationRecord.Field_API_Name__c);
                    }
                }
                if(String.isNotBlank(validationRecord.Required_Field_API_Name__c) ){
                    queryString += ', ' + String.escapeSingleQuotes(validationRecord.Required_Field_API_Name__c);
                } else if(String.isNotBlank(validationRecord.Field_Set_Name__c)){
                    if(globalDescribe.get(sObjectName).getDescribe().fieldSets.getMap().containsKey(validationRecord.Field_Set_Name__c)) {
                        for(Schema.FieldSetMember fieldSetMemberObj : globalDescribe.get(sObjectName).getDescribe().fieldSets.getMap().get(validationRecord.Field_Set_Name__c).getFields()) {
                            queryString += ', ' + String.escapeSingleQuotes(fieldSetMemberObj.getFieldPath());
                        }
                    }
                }
                queryString += ' FROM ' +  String.escapeSingleQuotes(sObjectName) + ' ';
                if(String.isNotBlank(validationRecord.Record_Type_Developer_Name__c) ) {
                    Map<String,Schema.RecordTypeInfo> recordTypeMap = globalDescribe.get(sObjectName).getDescribe().getRecordTypeInfosByDeveloperName();
                    if(recordTypeMap.containsKey(validationRecord.Record_Type_Developer_Name__c)) {
                        queryString += ' WHERE RecordtypeId = \'' + String.escapeSingleQuotes(recordTypeMap.get(validationRecord.Record_Type_Developer_Name__c).RecordTypeId) + '\'';
                    }
                }
            }
        }
        return queryString;
    }

    /*
    *********************************************************
    @Method Name    : getCustomSetting
    @description    : Get validation custom settings
    @param          : 
    @return         : Map<String, List<Validation_Configuration__mdt>>
    ********************************************************
    */
    public static Map<String, List<Validation_Configuration__mdt>> getCustomSetting(){
        Map<String, List<Validation_Configuration__mdt>> globalSetting = new Map<String, List<Validation_Configuration__mdt>>();
        for(Validation_Configuration__mdt validationConfig : [SELECT Id, DeveloperName,Object_API_Name__c,Field_API_Name__c, Required_Field_API_Name__c, Field_Set_Name__c, Record_Type_Developer_Name__c, Error_Message__c, Operator__c, Field_Value__c FROM Validation_Configuration__mdt WHERE Is_Active__c = true]){
            if(!globalSetting.containsKey(validationConfig.Object_API_Name__c)){
                globalSetting.put(validationConfig.Object_API_Name__c, new List<Validation_Configuration__mdt>());
            }
            globalSetting.get(validationConfig.Object_API_Name__c).add(validationConfig);
        }
        return globalSetting;
    }

    /*
    *********************************************************
    @Method Name    : retrieveErrorMap
    @description    : put error in map and return
    @param          : List<Sobject> newList, String objectName
    @return         : Map<Id, String>
    ********************************************************
    */
    public static Map<Id, String> retrieveErrorMap(List<Sobject> newList, String objectName) {
        Map<String, List<Validation_Configuration__mdt>> validationConfigurationMap = getCustomSetting();
        Map<Id, String> mapOfSobjectidWithMessage = new Map<Id, String>();
        if(validationConfigurationMap.containsKey(objectName)) {
            Set<Id> recordIdSet = new Set<Id>();
            for(Sobject record : newList) {
                recordIdSet.add(record.Id);
            }
            String value = retrieveQueryString('Case',validationConfigurationMap);
            value += value.contains('WHERE') ? ' AND Id IN: recordIdSet' : ' WHERE Id IN: recordIdSet';
            for(Sobject record : Database.query(value)){
                String message = validation(record, objectName, validationConfigurationMap);
                if(String.isNotBlank(message)){
                    mapOfSobjectidWithMessage.put(record.Id, message);
                }
            }
        }
        return mapOfSobjectidWithMessage;
    }
    
    /*
    *********************************************************
    @Method Name    : validation
    @description    : validate record with condition and values
    @param          : Sobject sObjectRecord, String sObjectName, Map<String, List<Validation_Configuration__mdt>> mapOfObjectWithListOfValidation
    @return         : String
    ********************************************************
    */
    public static String validation(Sobject sObjectRecord, String sObjectName, Map<String, List<Validation_Configuration__mdt>> mapOfObjectWithListOfValidation){
        String fields = '';
        String message = '';
        Map<String, Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();
        Boolean flag = false;
        if(mapOfObjectWithListOfValidation != null && mapOfObjectWithListOfValidation.containsKey(sObjectName) && globalDescribe.containsKey(sObjectName)){
            Map<String,Schema.SobjectField> fieldsMap = globalDescribe.get(sObjectName).getDescribe().fields.getMap();
            for(Validation_Configuration__mdt validationRecord : mapOfObjectWithListOfValidation.get(sObjectName)){
                message = validationRecord.Error_Message__c;
                if(String.isNotBlank(validationRecord.Field_API_Name__c)){
                    if(fieldsMap.containsKey(validationRecord.Field_API_Name__c)){
                        if(validationRecord.Operator__c == 'Equal'){
                            flag = String.valueOf(sObjectRecord.get(validationRecord.Field_API_Name__c)) == validationRecord.Field_Value__c;
                        } else if(validationRecord.Operator__c == 'Not Equal'){
                            flag = String.valueOf(sObjectRecord.get(validationRecord.Field_API_Name__c)) != validationRecord.Field_Value__c;
                        }
                    }
                }
                if(flag) {
                    if(String.isNotBlank(validationRecord.Required_Field_API_Name__c)){
                        if(retrieveValue(sObjectRecord,validationRecord.Required_Field_API_Name__c) == null)
                            fields += fields == '' ? retrieveLabel(globalDescribe,validationRecord.Required_Field_API_Name__c,fieldsMap) : ', ' + retrieveLabel(globalDescribe,validationRecord.Required_Field_API_Name__c,fieldsMap);
                    } else if(String.isNotBlank(validationRecord.Field_Set_Name__c)){
                        if(globalDescribe.get(sObjectName).getDescribe().fieldSets.getMap().containsKey(validationRecord.Field_Set_Name__c)) {
                            for(Schema.FieldSetMember fieldSetMemberObj : globalDescribe.get(sObjectName).getDescribe().fieldSets.getMap().get(validationRecord.Field_Set_Name__c).getFields()) {
                                if(retrieveValue(sObjectRecord,fieldSetMemberObj.getFieldPath()) == null)
                                    fields += fields == '' ? fieldSetMemberObj.getLabel() : ', ' + fieldSetMemberObj.getLabel();
                            }
                        }
                    }
                }
            }
        }
        return String.isBlank(fields) ? '' : message + ' ' + fields;
    }

    /*
    *********************************************************
    @Method Name    : retrieveValue
    @description    : Retrieve field value from record
    @param          : Sobject record,String field
    @return         : object
    ********************************************************
    */
    public static object retrieveValue(Sobject record,String field) {
        Object val;
        if(field.indexOf('.') != -1) {
            List<String> fieldsString = field.split('\\.');
            for(Integer counter = 0; counter < fieldsString.size(); counter++) {
                String fieldName = fieldsString[counter].replace('__r','__c');
                if(record == null) {
                    return null;
                }
                if(counter < fieldsString.size() - 1)
                    record = record.getSobject(fieldName);
                if(counter == fieldsString.size() - 1)
                    val = record.get(fieldName);
            }
            return val;
        } else {
            val = record.get(field);
        }
        return val;
    }

    /*
    *********************************************************
    @Method Name    : retrieveLabel
    @description    : Retrieve field label from record
    @param          : Map<String, Schema.SobjectType> globalDescribe, String field, Map<String,Schema.SobjectField> fieldsMap
    @return         : String
    ********************************************************
    */
    public static String retrieveLabel(Map<String, Schema.SobjectType> globalDescribe, String field, Map<String,Schema.SobjectField> fieldsMap) {
        String val;
        if(field.indexOf('.') != -1) {
            List<String> fieldsString = field.split('\\.');
            String objectName = fieldsString[fieldsString.size() - 2].replace('__r','__c');
            if(globalDescribe.containsKey(objectName)) {
                Map<String,Schema.SobjectField> fldMp = globalDescribe.get(objectName).getdescribe().fields.getMap();
                if(fldMp.containsKey(fieldsString[fieldsString.size() - 1])) {
                    val = fldMp.get(fieldsString[fieldsString.size() - 1]).getDescribe().getLabel();
                }
            }
            return val;
        } else {
            val = fieldsMap.get(field).getDescribe().getLabel();
        }
        return val;
    }
}