public class NC_ResourceLoanTriggerHandler {
    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before Insert' trigger event
    @param          : List<Resource_Loan__c> newResourceLoanList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Resource_Loan__c> newList){
    }

    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'after Insert' trigger event
    @param          : List<Resource_Loan__c> newResourceLoanList
    @return         : void
    ********************************************************
    */
    public static void afterInsert(List<Resource_Loan__c> newList){
        autoPopulateAgencywhenConsumerIsSelected(newList,NULL);
    }    

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<Resource_Loan__c> newList, Map<Id,Resource_Loan__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Resource_Loan__c> newList, Map<Id,Resource_Loan__c> oldMap){
        autoPopulateAgencywhenConsumerIsSelected(newList,oldMap);
    }

    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Resource_Loan__c> newList, Map<Id,Resource_Loan__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Resource_Loan__c> newList,Map<Id,Resource_Loan__c> oldMap){
    }
    
    /*
    *********************************************************
    @Method Name    : autoPopulateAgencywhenConsumerIsSelected
    @description    : autoPopulateAgencywhenConsumerIsSelected on insert or update
    @param          : List<Resource_Loan__c> newList, Map<Id,Resource_Loan__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void autoPopulateAgencywhenConsumerIsSelected(List<Resource_Loan__c> newList, Map<Id,Resource_Loan__c> oldMap){
        Set<Id> contactIdSet=new Set<Id>();
        Set<Id> resourceLoanIdSet=new Set<Id>();
        List<Resource_Loan__c> resourceLoanRecordsList=new  List<Resource_Loan__c>();
        Id consumerResourceLoanRecordTypeId = Schema.SObjectType.Resource_Loan__c.getRecordTypeInfosByName().get('Consumer Resource Loan').getRecordTypeId();
        for(Resource_Loan__c resourceLoanRecord : newList){
            if((oldMap == null || oldMap.get(resourceLoanRecord.Id).Consumer__c != resourceLoanRecord.Consumer__c)
               && resourceLoanRecord.Consumer__c != NULL && resourceLoanRecord.RecordTypeId == consumerResourceLoanRecordTypeId){
                   contactIdSet.add(resourceLoanRecord.Consumer__c);
                   resourceLoanIdSet.add(resourceLoanRecord.Id);
               }
        }
        for(Resource_Loan__c resourceLoan:[SELECT Id,Consumer__c,Agency__c,Consumer__r.AccountId FROM Resource_Loan__c WHERE Id IN: resourceLoanIdSet]){
            resourceLoan.Agency__c=resourceLoan.Consumer__r.AccountId;
            resourceLoanRecordsList.add(resourceLoan);
        }
        if(!resourceLoanRecordsList.isEmpty()){
            update resourceLoanRecordsList;
        }
    }
}