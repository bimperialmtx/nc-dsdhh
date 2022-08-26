/*
**   Class Name: NC_LwcCustomPathController
**   Description: Controller For NC_LwcCustomPath

**     Date            New/Modified           User                 Identifier                Description
**   20-05-2020             New          Hiten Aggarwal(mtx)
*/

public without sharing class NC_LwcCustomPathController {
    
    /*
    *********************************************************
    @Method Name    : getPicklistValues
    @description    : Get picklist values by object, field and record type name
    @param          : String fieldApiName, Id recordId, String recordTypesNames
    @return         : List<stepWrapper>
    ********************************************************
    */
    @AuraEnabled
    public static List<stepWrapper> getPicklistValues(String fieldApiName, Id recordId, String recordTypesNames){
        
        Boolean flag = false;
        Boolean isCorrectRecordType = true;
        List<SelectOption> options = new List<SelectOption>();
        Map<String, Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();
        String sObjectName = recordId.getSobjectType().getDescribe().getName();
        
        String query = 'SELECT Id,' ;
        query = String.isNotBlank(recordTypesNames) ? query + 'RecordTypeId,' : query;
        query = query + String.escapeSingleQuotes(fieldApiName) + ' FROM '+ String.escapeSingleQuotes(sObjectName) +' WHERE Id =: recordId';
        List<SObject> sObjectList = Database.query(query);
        if(String.isNotBlank(recordTypesNames)){
            List<String> recordTypeNameList = recordTypesNames.trim().split(';');
            string recordtypename = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosById().get(String.valueOf(sObjectList[0].get('RecordTypeId'))).getDeveloperName();
            if(!recordTypeNameList.contains(recordtypename)){
                isCorrectRecordType = false;
            }
        }

        List<stepWrapper> stepWrapperList = new List<stepWrapper>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{sObjectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldApiName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    stepWrapper stepWrapper = new stepWrapper();
                    stepWrapper.value = entry.getValue();
                    if(entry.getValue() == sObjectList[0].get(fieldApiName) && flag == false){
                        stepWrapper.isCurrent = true;
                        stepWrapper.isUpcoming = false;
                        stepWrapper.isCompleted = false;
                        flag = true;
                    }else if(flag == false && sObjectList[0].get(fieldApiName) != NULL){
                        stepWrapper.isCompleted = true;
                        stepWrapper.isCurrent = false;
                        stepWrapper.isUpcoming = false;
                    }else if(flag == true || isCorrectRecordType){
                        stepWrapper.isCompleted = false;
                        stepWrapper.isCurrent = false;
                        stepWrapper.isUpcoming = true;
                    }
                    stepWrapperList.add(stepWrapper);
                }
            }
        }
        return stepWrapperList;
        
    }
    
   /*
    * Class Name: stepWrapper
    * Description: For storing if each value of picklist selected or not
    * 
    */
    
    public class stepWrapper{
        @AuraEnabled public String  value{get;set;}
        @AuraEnabled public Boolean isCompleted{get;set;}
        @AuraEnabled public Boolean isCurrent{get;set;}
        @AuraEnabled public Boolean isUpcoming{get;set;}
        
        public stepWrapper(){
            this.value = '';
            this.isCompleted = false;
            this.isCurrent = false;
            this.isUpcoming = false;
        }
        
    }
    
}