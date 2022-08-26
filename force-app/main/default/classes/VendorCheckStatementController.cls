/**
 * @description       : 
 * @author            : Saurav Nirwal
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-29-2021   Saurav Nirwal   Initial Version
**/
public with sharing class VendorCheckStatementController {
    /*
    *********************************************************
    @Method Name    : retrieveCheckStatements
    @description    : Retrieve check statement records with filter
    @param          : String vendorId, Integer offset, Integer recordLimit, String searchFilter, Integer month, Integer year, Boolean isPrinted, Boolean isMailed, Boolean isElectronic
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveCheckStatements(String vendorId, Integer offset, Integer recordLimit, String searchFilter, Integer month, Integer year, Boolean isPrinted, Boolean isMailed, Boolean isElectronic) {
        Map<String,Object> result = new Map<String,Object>();
        List<CheckStatementWrapper> wrapList = new List<CheckStatementWrapper>();
        Integer count = 0;
        List<ContentVersion> documents = new List<ContentVersion>();
        try {
            Map<String, C1_Check_Statement__c> checkStatementMap = new Map<String, C1_Check_Statement__c>();
            Map<String, String> checkStatementDocMap = new Map<String, String>();
            String checkStatementQuery = 'SELECT Id, Name, Printed__c, Mailed__c FROM C1_Check_Statement__c WHERE Vendor__c =: vendorId ';
            if(isPrinted != null) {
                checkStatementQuery += ' AND Printed__c =: isPrinted ';
            }
            if(isMailed != null) {
                checkStatementQuery += ' AND Mailed__c =: isMailed ';
            }
            if(isElectronic != null) {
                checkStatementQuery += ' AND Vendor__r.Electronic__c =: isElectronic ';
            }

            for(C1_Check_Statement__c checkStatement: Database.query(checkStatementQuery)) {
                checkStatementMap.put(checkStatement.Id, checkStatement);
            }

            if(checkStatementMap.size() > 0) {
                for(ContentDocumentLink cdl: [SELECT ContentDocumentId, Visibility, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: checkStatementMap.keySet() AND CALENDAR_MONTH(SystemModstamp) =: month AND CALENDAR_YEAR(SystemModstamp) =: year WITH SECURITY_ENFORCED]) {
                    checkStatementDocMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                } 

                Set<String> contentDocumentIds = checkStatementDocMap.keySet();
                String queryString = 'SELECT Id,Title, CreatedDate, LastModifiedDate,ContentSize,  PathOnClient, ContentDocumentId FROM ContentVersion ';
                String whereclause = ' WHERE ContentDocumentId IN: contentDocumentIds ';
                whereclause += ' AND Check_Statement__c = true ';
                whereclause += ' AND CALENDAR_MONTH(CreatedDate) =: month ';
                whereclause += ' AND CALENDAR_YEAR(CreatedDate) =: year ';
                if(String.isNotBlank(searchFilter)) {
                    string strgkeyword = '%'+searchFilter+'%';
                    whereclause += ' AND Title LIKE :strgkeyword ';
                }
                String limitClause = ' ORDER BY LastModifiedDate DESC LIMIT : recordLimit OFFSET : offset ';
                count = Database.countQuery(' SELECT COUNT() FROM ContentVersion ' + whereclause);
                documents = Database.query(queryString + whereclause + limitClause);

                // Map<Id, ContentDistribution> mapOfContentDistribution = getContentDistribution(documents);
                // List<ContentDistribution> newContentDistributionList = new List<ContentDistribution>();

                // for (ContentVersion cv: documents) {
                //     if (!mapOfContentDistribution.containsKey(cv.Id)) {
                //         ContentDistribution newContentDistribution = new ContentDistribution( Name = 'Test', ContentVersionId = cv.Id, PreferencesAllowViewInBrowser = true );
                //         newContentDistributionList.add(newContentDistribution);
                //     }
                // }
                // insert newContentDistributionList;

                // mapOfContentDistribution = getContentDistribution(documents);

                for(ContentVersion cv: documents) {
                    CheckStatementWrapper wrap = new CheckStatementWrapper();
                    if(checkStatementDocMap.containsKey(cv.ContentDocumentId)) {
                        String checkStatementId = checkStatementDocMap.get(cv.ContentDocumentId);
                        if(checkStatementMap.containsKey(checkStatementId)) {
                            wrap.checkStatement = checkStatementMap.get(checkStatementId);
                            wrap.cv = cv;
                            // wrap.cd = mapOfContentDistribution.get(cv.Id);
                            wrapList.add(wrap);
                        }
                    }
                }

                
            }
            result.put('total',count);
            result.put('records',wrapList);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // private static Map<Id, ContentDistribution> getContentDistribution(List<ContentVersion> documents) {
    //     Map<Id, ContentDistribution> mapOfContentDistribution = new Map<Id, ContentDistribution>();
        
    //     for (ContentDistribution contentdistribute : [
    //         SELECT Id, Name, ContentDownloadUrl, ContentVersionId, DistributionPublicUrl 
    //         FROM ContentDistribution 
    //         WHERE ContentVersionId in :documents]) {

    //         mapOfContentDistribution.put(contentdistribute.ContentVersionId, contentdistribute);
    //     }

    //     return mapOfContentDistribution;
    // }

    /*
    *********************************************************
    @Method Name    : markStatementPrintedAndMailed
    @description    : update check statement as printed and mailed
    @param          : String checkStatementId, Boolean markPrinted, Boolean markMailed
    @return         : C1_Check_Statement__c
    ********************************************************
    */
    @AuraEnabled
    public static C1_Check_Statement__c markStatementPrintedAndMailed(String checkStatementId, Boolean markPrinted, Boolean markMailed){
        C1_Check_Statement__c checkStatement = new C1_Check_Statement__c();
        try {
            if(String.isNotBlank(checkStatementId)) {
                checkStatement.Id = checkStatementId;
                if(markPrinted != null) {
                    checkStatement.Printed__c = markPrinted;    
                }
                if(markMailed != null) {
                    checkStatement.Mailed__c = markMailed;
                }
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('C1_Check_Statement__c', new List<C1_Check_Statement__c>{checkStatement}, 'update', true,'VendorCheckStatementController','markStatementPrintedAndMailed');
                update decision.getRecords();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return checkStatement;
    }

    public class CheckStatementWrapper {
        @AuraEnabled
        public C1_Check_Statement__c checkStatement {get;set;}
        
        @AuraEnabled
        public ContentVersion cv {get;set;}

        // @AuraEnabled 
        // public ContentDistribution cd {get; set;}
    }
/*
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getCheckStatements(String vendorId) {
        Set<String> contentDocumentIds = new Set<String>();
        try{
            if(String.isNotBlank(vendorId)){
                for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: vendorId WITH SECURITY_ENFORCED]) {
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
                return [SELECT Id,Title, CreatedDate, LastModifiedDate, ContentSize, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds WITH SECURITY_ENFORCED LIMIT :5 OFFSET :0 ] ;
            }
        } catch (Exception e) {

        }
        return new List<ContentVersion>();
    }

    @AuraEnabled(cacheable=true)
public static string getContentVersion(Id docId){
    return [
        SELECT Id, IsLatest, Title, ContentDocumentId 
        FROM ContentVersion 
        WHERE ContentDocumentId=:docId 
        LIMIT 1
    ].Id;
}
@AuraEnabled(cacheable=true)
public static List<ContentVersion>  fetchDataOnSearch(String userId,String searchKeyTitle,Date searchKeyDate){
    Set<String> contentDocumentIds = new Set<String>();
    string strgkeyword = '%'+searchKeyTitle+'%';
    try{
        if(String.isNotBlank(userId)){
            for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: userId WITH SECURITY_ENFORCED]) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
            if(searchKeyTitle==null && searchKeyDate==null){
                return [SELECT Id,Title, CreatedDate, LastModifiedDate, ContentSize, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds WITH SECURITY_ENFORCED LIMIT :5 ]; 
            }
            else{
            return [SELECT Id,Title, CreatedDate, LastModifiedDate, ContentSize, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds AND (Title LIKE :strgkeyword  OR DAY_ONLY(CreatedDate) =: searchKeyDate) WITH SECURITY_ENFORCED LIMIT :5 ];
            }
        }
    } catch (Exception e) {

    }
    return new List<ContentVersion>();


}

@AuraEnabled(cacheable=true)
public static List<ContentVersion>  paginationMethod(String userId,String searchKeyTitle,Date searchKeyDate,Integer pageNumber){
    Integer maxValue= pageNumber *5;
   // if(pageNumber>1){
    Integer offsetValue = (pageNumber -1)*5;
    Set<String> contentDocumentIds = new Set<String>();
    string strgkeyword = '%'+searchKeyTitle+'%';
    try{
        if(String.isNotBlank(userId)){
            for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: userId WITH SECURITY_ENFORCED]) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
            return [SELECT Id,Title, CreatedDate, LastModifiedDate, ContentSize, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds WITH SECURITY_ENFORCED  LIMIT :5
            OFFSET :offsetValue ];
        }
    } catch (Exception e) {

    }
    return new List<ContentVersion>();

}*/
}