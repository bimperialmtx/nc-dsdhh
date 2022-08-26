/*
*   Class Name: NC_Utility
*   Description: Utility Methods and Variables
*
*   Date            New/Modified         User                 Identifier                Description
*   21/04/2020         New         Shubham Dadhich(mtx)
*   13/05/2020         Modified    Shubham Dadhich(mtx)                                 Adding Profile Id Utility
*/

public without sharing class NC_Utility {

    /*
    *********************************************************
    @Method Name    : RecordTypeUtilityMethod
    @description    : Get Record Type Id from Its Developer Name
    @param          : String sObjectName, String RecordType_DeveloperName
    @return         : Id
    ********************************************************
    */
    public static Id RecordTypeUtilityMethod(String sObjectName, String RecordType_DeveloperName){
        Map<String, Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();
        return globalDescribe.get(sObjectName).getDescribe().getRecordTypeInfosByDeveloperName().get(RecordType_DeveloperName).RecordTypeId;
    }

    /*
    *********************************************************
    @Method Name    : GetRequestRecordTypeId
    @description    : Get Record Type Id from Its Developer Name for Request Object
    @param          : String RecordType_DeveloperName
    @return         : Id
    ********************************************************
    */
    public static Id GetRequestRecordTypeId(String RecordType_DeveloperName){
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordType_DeveloperName).getRecordTypeId();
    }

    /*
    *********************************************************
    @Method Name    : getProfileId
    @description    : Get Profile Id from Its Name
    @param          : String Profile_Name
    @return         : Id
    ********************************************************
    */
    public static Id getProfileId(String Profile_Name){
        return [SELECT Id FROM Profile WHERE Name=:Profile_Name LIMIT 1].Id;
    }
    
    /*
    *********************************************************
    @Method Name    : getFieldSet
    @description    : String fieldSetName, String ObjectName
    @param          : String ObjectName, String fieldSetName
    @return         : List<Schema.FieldSetMember>
    ********************************************************
    */
    public static List<Schema.FieldSetMember> getFieldSet(String ObjectName, String fieldSetName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);  
        return fieldSetObj.getFields(); 
    } 
    
    /*
    *********************************************************
    @Method Name    : calculateCurrentFiscalYearStartDate
    @description    : Get The current Fiscal Year
    @param          : Date refernceDate
    @return         : Date
    ********************************************************
    */
    public static Date calculateCurrentFiscalYearStartDate(Date refernceDate){
        refernceDate = refernceDate != NULL ? refernceDate : Date.today();
        Date currentFiscalYearStartDate;
        If(refernceDate > date.newInstance(Date.today().year(), 7, 1)){
            currentFiscalYearStartDate = date.newInstance(Date.today().year(), 7, 1);
        }else{
            currentFiscalYearStartDate = date.newInstance(Date.today().year()-1, 7, 1);
        }
        return currentFiscalYearStartDate;
    }
    
    /*
    *********************************************************
    @Method Name    : getRegionalCenterIdToNameMap
    @description    : Get The Regional Center
    @param          : 
    @return         : Map<Id,String>
    ********************************************************
    */
    public static Map<Id,String> getRegionalCenterIdToNameMap(){
        Map<Id,String> regionalCenterIdToNameMap = new Map<Id,String>();
        Id RecordTypeId_RegionaCenter = NC_Utility.RecordTypeUtilityMethod('Account',NC_Constant.Account_Regional_Center_RecordType);
        for(Account accountRecord: [SELECT Id,Name FROM ACCOUNT WHERE RecordTypeId =: RecordTypeId_RegionaCenter WITH SECURITY_ENFORCED]){
            regionalCenterIdToNameMap.put(accountRecord.Id, accountRecord.Name);
        }
        return regionalCenterIdToNameMap;
    }
}