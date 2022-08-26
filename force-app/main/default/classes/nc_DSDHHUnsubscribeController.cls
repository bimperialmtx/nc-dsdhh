/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class nc_DSDHHUnsubscribeController {
    
    /*
    *********************************************************
    @Method Name    : getApplicationRecords
    @description    : Retrieve all case using contact id
    @param          : String contactId
    @return         : Contact
    ********************************************************
    */
    @AuraEnabled
    public static Contact getApplicationRecords(String contactId){
        String conId=NC_CryptoEncryption.decodeString(contactId);
        Contact contactRecord = new Contact();
        if(String.isNotBlank(conId)){
            list<Contact> contactList = [SELECT Id ,Communications_Type__c ,Why_You_Unsubscribed__c,
                                        LastName ,Hearing_Disability__c, Other_Reason_For_Unsubscribe__c
                                        FROM Contact WHERE Id =: conId WITH SECURITY_ENFORCED];
            contactRecord = contactList[0];
        }
        return contactRecord;
    }

    /*
    *********************************************************
    @Method Name    : saveData
    @description    : Save contact data
    @param          : contact contactRecord
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void saveData( contact contactRecord  ){
    
     if(Schema.sObjectType.Contact.isUpdateable())
     {
        update contactRecord; 
     }
         
    }

    /*
    *********************************************************
    @Method Name    : fatchMultiPicklist
    @description    : Fetch multi picklist
    @param          : String objectName, String fieldName
    @return         : List<SelectOptionWrapper>
    ********************************************************
    */
    @AuraEnabled
    public static List<SelectOptionWrapper> fatchMultiPicklist(String objectName, String fieldName){
        List<SelectOptionWrapper> opts = new List<SelectOptionWrapper>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            opts.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
        }    
        
        return opts;
    }

    public class SelectOptionWrapper{
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        
        public SelectOptionWrapper(string value, string label){
            this.value = value;
            this.label = label;
        }
    }
}