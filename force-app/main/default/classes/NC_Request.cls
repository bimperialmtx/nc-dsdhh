/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_Request {

    /*
    *********************************************************
    @Method Name    : getConsumerName
    @description    : Get consumer name and check NDBEDP request 
    @param          : String contactId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> getConsumerName(String contactId){
        String parentContactId = '';
        Map<String,Object> result=new Map<String,Object>();
        result.put('EDS',true);
        result.put('NDBEDP',true);
        Set<String> roleSet=new Set<String>{'EDS_Program_Assistant','EDS_Program_Coordinator'};
        if(String.isNotBlank(contactId)){
            parentContactId = [SELECT Id, Name FROM Contact WHERE Id=:contactId LIMIT 1].Name;
            User u=[SELECT Id,Contact.Name,UserRole.DeveloperName FROM User WHERE Id=:userInfo.getUserId()];
            if(u.UserRole.DeveloperName!=NULL && roleSet.contains(u.UserRole.DeveloperName)){
                result.put('NDBEDP',false);
            }
            result.put('Name',parentContactId);
            //return parentContactId;
            return result;
        }
        return null;
    }

    /*
    *********************************************************
    @Method Name    : getRecordTypeId
    @description    : Get recordtype id by developername
    @param          : String requestRecordTypeName
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static String getRecordTypeId(String requestRecordTypeName){
        String recordTypeId = '';
        if(String.isNotBlank(requestRecordTypeName)){
            recordTypeId = [SELECT Id, DeveloperName, Name, SobjectType FROM RecordType WHERE DeveloperName = :requestRecordTypeName AND SobjectType='Case'].Id;
            return recordTypeId;
        }
        return null;
    }

    /*
    *********************************************************
    @Method Name    : saveData
    @description    : save case data
    @param          : String dataObj
    @return         : Map<Id,Boolean>
    ********************************************************
    */
    @AuraEnabled
    public static Map<Id,Boolean> saveData(String dataObj){
        Map<Id,Boolean> alreadyPresentCaseMap = new Map<Id,Boolean>();
        List<Case> alreadyPresentCaseList = new List<Case>();
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        Id edsRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','Equipment');
        List<String> statusList = new List<String>{'Approved','Denied','Rejected'};
        try {
            RequestDataWrapper requestWrapper = (RequestDataWrapper) JSON.deserialize(dataObj, RequestDataWrapper.class);
            Case caseItem = requestWrapper.RequesDataHandler();
            if(edsRecordTypeId != caseItem.recordTypeId){
                alreadyPresentCaseList =[SELECT Id,Status FROM Case WHERE Status NOT IN:statusList AND RecordTypeId =:ndbedpRecordTypeId AND ContactId=:caseItem.ContactId WITH SECURITY_ENFORCED];
            if(alreadyPresentCaseList.size()>0){
                alreadyPresentCaseMap.put(alreadyPresentCaseList[0].Id,false);
                return alreadyPresentCaseMap;
            }
            else{
            //insert caseItem;
            SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Case', new List<Case>{caseItem}, 'insert', true,'NC_Request','saveData');
            insert decision.getRecords();
            caseItem = (Case)decision.getRecords()[0];
            alreadyPresentCaseMap.put(caseItem.Id,true);
            return alreadyPresentCaseMap;
            }
         }
         else{
            //insert caseItem;
            SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Case', new List<Case>{caseItem}, 'insert', true,'NC_Request','saveData');
            insert decision.getRecords();
            caseItem = (Case)decision.getRecords()[0];
            alreadyPresentCaseMap.put(caseItem.Id,true);
            return alreadyPresentCaseMap;
         }
        }
        catch (Exception e) {
             
            throw new AuraHandledException('Error: '+e.getMessage());
                }

   }
    public class RequestDataWrapper{
        @AuraEnabled public string requestType;
        @AuraEnabled public string contactId;
        @AuraEnabled public string consumerName;
        @AuraEnabled public List<string> EquipmentTypes;

        public Case RequesDataHandler() {
            Case caseValue = new Case();
            caseValue.ContactId=contactId;
           // caseValue.Equipment_Types__c = String.join(EquipmentTypes, ';');
            caseValue.Status= 'Submitted';
            if(requestType == 'EDS'){
                caseValue.Request_Type__c ='EDS';
                caseValue.Equipment_Types__c = String.join(EquipmentTypes, ';');
                caseValue.recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
            }
            else if(requestType == 'NDBEDP'){
                caseValue.Request_Type__c ='NDBEDP';
                caseValue.recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
            }
            return caseValue;
    }
    
}
}