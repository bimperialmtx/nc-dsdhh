/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_PaginatorController {
    /*
    *********************************************************
    @Method Name    : retrieveRecords
    @description    : Retrieve all records
    @param          : Map<String,Object> parameters
    @return         : Map<String,Object>
    ********************************************************
    */
        @AuraEnabled
        public static Map<String,Object> retrieveRecords(Map<String,Object> parameters) {
                return retrieveRecordsWithSharing(parameters);
        }

    /*
    *********************************************************
    @Method Name    : retrieveRecordsWithSharing
    @description    : Retrieve all records with sharing
    @param          : Map<String,Object> parameters
    @return         : Map<String,Object>
    ********************************************************
    */
        public static Map<String,Object> retrieveRecordsWithSharing(Map<String,Object> parameters) {
            Map<String,Object> results = new Map<String,Object>();
            String queryString = 'SELECT Id';// + (parameters.get('fields')).toString() + 
            for(object obj : (List<Object>)parameters.get('fields')) {
                if(!((String)obj).equalsIgnoreCase('Id'))
                    queryString += ', ' + (String)obj;
            }
            List<Id> recordIdList = new  List<Id>();
            if(parameters.containsKey('recordIdList')){
                //recordIdList =  (List<Object>)parameters.get('recordIdList');
                for (Object instance : (List<Object>)parameters.get('recordIdList')){
                    Map<Object,Object> temp = ( Map<Object,Object>)instance;
                    recordIdList.add((Id)temp.get('Id'));
                }
            }
            queryString += ' FROM ' + parameters.get('objectName');
            Integer pageDifference = Integer.valueof(parameters.get('newPageNo')) - Integer.valueof(parameters.get('previousPageNo'));
            Integer pageLimit = (pageDifference > 0 ? pageDifference : pageDifference * -1) * Integer.valueof(parameters.get('limit'));
            String filters = '';
            String searchString = parameters.containsKey('searchStr') ? (String)parameters.get('searchStr') : '';
            
            //Condition to show cases on search only
        
            if((Boolean)parameters.get('showRecordsOnSearchOnly') == true && String.isBlank(searchString)){
                results.put('totalCount',0);
                results.put('query','No Records Can Be Displayed Without search string');
                results.put('records',new List<sObject>());
                return results;
            }
    
            if( String.isNotBlank((searchString))) {
                filters += ' ( '; 
                for(Object obj : (List<Object>)parameters.get('searchableFields')) {
                    if((String.valueof(obj)).contains('.')) {
                        List<String> objFieldList = (String.valueof(obj)).split('\\.');
                        String parentFieldName = '';
                        String objectName  = '';
                        if(objFieldList[objFieldList.size() - 2].contains('__r')){
                            parentFieldName = objFieldList[objFieldList.size() - 2].replace('__r','__c');
                            objectName  = Schema.getGlobalDescribe().get((String)parameters.get('objectName')).getDescribe().fields.getMap().get((String)parentFieldName).getDescribe().getReferenceTo()[0].getDescribe().getName();
                        }else{
                            parentFieldName = objFieldList[objFieldList.size() - 2];
                            objectName  = parentFieldName;
                        } 
                        String fieldName = objFieldList[objFieldList.size() - 1];
                        Schema.DisplayType displayType = Schema.getGlobalDescribe().get((String)objectName).getDescribe().fields.getMap().get((String)fieldName).getDescribe().getType();
                        if( displayType == Schema.DisplayType.String || displayType == Schema.DisplayType.Email || displayType == Schema.DisplayType.Picklist) {
                            filters += filters != ' ( ' ? ' OR ' : ' ';
                            filters +=  (String)obj + ' LIKE \'%' + String.escapeSinglequotes(searchString) + '%\' ';
                        }
                    } else {
                        Schema.DisplayType displayType = Schema.getGlobalDescribe().get((String)parameters.get('objectName')).getDescribe().fields.getMap().get((String)obj).getDescribe().getType();
                        if( displayType == Schema.DisplayType.String || displayType == Schema.DisplayType.Email || displayType == Schema.DisplayType.Picklist) {
                            filters += filters != ' ( ' ? ' OR ' : ' ';
                            filters +=  (String)obj + ' LIKE \'%' + String.escapeSinglequotes(searchString) + '%\' ';
                        }
                    }
                }
                filters += ' )';
            }
            if(parameters.containsKey('whereClause') && String.isNotBlank((String)parameters.get('whereClause'))) {
                filters += filters != '' ? ' AND ' : '';
                filters += parameters.get('whereClause');
            }
            String countFilter = filters == '' ? '' : ' WHERE ' + filters;
            
            Integer reccount = 0;
            
            Map<String,sObject> duplicateCheckMap = new Map<String,sObject>();
            if(parameters.containsKey('distinctField') && parameters.get('distinctField') != ''){
                List<Sobject> queryCountResult = Database.query('SELECT Id ,'+  String.escapeSingleQuotes(String.valueOf(parameters.get('distinctField')))+ ' FROM ' + parameters.get('objectName') + countFilter);
                for(sObject record : queryCountResult){
                    String parentFieldName = '';
                    if((String.valueof(String.valueOf(parameters.get('distinctField')))).contains('.')) {
                        List<String> objFieldList = (String.valueof(String.valueOf(parameters.get('distinctField')))).split('\\.');
                         parentFieldName = objFieldList[objFieldList.size() - 2].replace('__r','__c');
                    }else{
                        parentFieldName = String.valueOf(parameters.get('distinctField'));
                    }
                    duplicateCheckMap.put(String.valueOf(record.get(parentFieldName)),record);
                }
                reccount = duplicateCheckMap.values().size();
            }else{
                 reccount = Database.countQuery('SELECT Count() FROM ' + parameters.get('objectName') + countFilter);
            }
            results.put('totalCount',reccount);
            
            List<Sobject> queryResult = new List<Sobject>();
            if(duplicateCheckMap.isEmpty()){
                filters = filters != '' ? ' WHERE ' +  filters : filters;
                filters += ' ORDER BY ' + parameters.get('sortBy') + ' ' + parameters.get('sortDir') + '  NULLS LAST , ID '  + parameters.get('sortDir');
                if(parameters.containsKey('limit')) {
                    if((Integer.valueOf(parameters.get('newPageNo'))  - 1 ) * Integer.valueof(parameters.get('limit')) >= 2000){
                        queryResult = findOffset( queryString + filters ,(Integer.valueOf(parameters.get('newPageNo'))  - 1 ) * Integer.valueof(parameters.get('limit')), Integer.valueof(parameters.get('limit')));
                    }else{
                        filters += ' LIMIT ' + Integer.valueof(parameters.get('limit')) + ' OFFSET ' + (Integer.valueOf(parameters.get('newPageNo'))  - 1 ) * Integer.valueof(parameters.get('limit')) ;
                    }
                }
            }else{
                filters += filters != '' ? ' AND ' : '';
                Set<String> stringSet = duplicateCheckMap.keySet();
                String parentFieldName = '';
                if((String.valueof(String.valueOf(parameters.get('distinctField')))).contains('.')) {
                    List<String> objFieldList = (String.valueof(String.valueOf(parameters.get('distinctField')))).split('\\.');
                     parentFieldName = objFieldList[objFieldList.size() - 2].replace('__r','__c');
                }else{
                    parentFieldName = String.valueOf(parameters.get('distinctField'));
                }
                filters += parentFieldName + ' IN : stringSet ';
                filters = filters != '' ? ' WHERE ' +  filters : filters;
                filters += ' ORDER BY ' + parameters.get('sortBy') + ' ' + parameters.get('sortDir') + '  NULLS LAST , ID '  + parameters.get('sortDir');
                Set<Id> recordIdSearch = new Set<Id>();
                if(parameters.containsKey('limit')) {
                    if((Integer.valueOf(parameters.get('newPageNo'))  - 1 ) * Integer.valueof(parameters.get('limit')) >= 2000){
                        queryResult = findOffset( queryString + filters ,(Integer.valueOf(parameters.get('newPageNo'))  - 1 ) * Integer.valueof(parameters.get('limit')),Integer.valueof(parameters.get('limit')));
                    }else{
                        filters += ' LIMIT ' + Integer.valueof(parameters.get('limit')) + ' OFFSET ' + (Integer.valueOf(parameters.get('newPageNo'))  - 1 ) * Integer.valueof(parameters.get('limit')) ;
                    }
                }
            }
            List<Sobject> records = new List<Sobject>();
            results.put('query',queryString + filters);
    
            queryResult = queryResult.isEmpty() ? Database.query(queryString + filters) : queryResult;
            records = queryResult;
            
            results.put('records',records);
            return results;//;
        }
    
    /*
    *********************************************************
    @Method Name    : findOffset
    @description    : offset on queried records
    @param          : String query,Integer offSet,Integer limitValue
    @return         : List<Sobject>
    ********************************************************
    */
        public static List<Sobject> findOffset(String query,Integer offSet,Integer limitValue) {
            List<Sobject> results = Database.query(query);
            List<Sobject> returnList = new List<Sobject>();
            Integer count = 1;
            for(Integer i = offSet; i < results.size() ; i++){
                returnList.add(results[i]);
                count++;
                if(count > limitValue){
                    break;
                }
            }
            return returnList;
        }
    }