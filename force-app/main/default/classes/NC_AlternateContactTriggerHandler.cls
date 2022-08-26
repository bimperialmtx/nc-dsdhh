/*
*   Class Name: NC_AlternateContactTriggerHandler
*   Description: Alternate Contact Trigger Handler -- Logics on insert, update and delete
*
*   Date              New/Modified            User                 Identifier                Description
*   14/07/2020         new        hiten.aggarwal@mtxb2b.com
*/
public without sharing class NC_AlternateContactTriggerHandler {

    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'after Insert' trigger event
    @param          : List<Alternate_Contact__c> newList
    @return         : void
    ********************************************************
    */
    public static void afterInsert(List<Alternate_Contact__c> newList){
        changePrimaryContact(newList,NULL);
    }
    
    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<Alternate_Contact__c> newList, Map<Id,Alternate_Contact__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Alternate_Contact__c> newList, Map<Id,Alternate_Contact__c> oldMap){
        changePrimaryContact(newList,oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : changePrimaryContact
    @description    : Validate and change primart alternate contact
    @param          : List<Alternate_Contact__c> newList, Map<Id,Alternate_Contact__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void changePrimaryContact(List<Alternate_Contact__c> newList, Map<Id,Alternate_Contact__c> oldMap){
        List<Alternate_Contact__c> alternateContactList = new List<Alternate_Contact__c>();
        List<Contact> contactList = new List<Contact>();
        Map<Id,Alternate_Contact__c> contactIdPrimaryAlternateContactMap = new Map<Id,Alternate_Contact__c>();
        Map<Id,Boolean> contactToIsMinorMap = new Map<Id,Boolean>();
        for(Alternate_Contact__c alternativeContact : newList){
           if((oldMap == NULL || oldMap.get(alternativeContact.Id).Primary_Alternate_Contact__c  != alternativeContact.Primary_Alternate_Contact__c)
                && alternativeContact.Primary_Alternate_Contact__c){
                if(alternativeContact.Related_To__c == alternativeContact.Consumer__c){
                    alternativeContact.addError('Consumer cannot be alternate contact for itself.');    
                 }
                contactIdPrimaryAlternateContactMap.put(alternativeContact.Consumer__c, alternativeContact);
            }
        }
        for(Alternate_Contact__c alternativeContact : [SELECT Id,Primary_Alternate_Contact__c FROM Alternate_Contact__c 
                                                       Where Consumer__c IN: contactIdPrimaryAlternateContactMap.keySet() 
                                                       AND Id NOT IN: contactIdPrimaryAlternateContactMap.values() WITH SECURITY_ENFORCED]){
            alternativeContact.Primary_Alternate_Contact__c = False;
            alternateContactList.add(alternativeContact);                                         
        }
        
        
        for(Contact contactRecord : [SELECT Id,Relationship_Type__c, Power_of_Attorney__c, Legal_Guardian__c, 
                                     Primary_Alternative_Contact__c,Is_Minor__c
                                     FROM Contact Where ID IN: contactIdPrimaryAlternateContactMap.keySet() WITH SECURITY_ENFORCED]){
             if(contactIdPrimaryAlternateContactMap.containsKey(contactRecord.Id) && 
                (contactRecord.Primary_Alternative_Contact__c != contactIdPrimaryAlternateContactMap.get(contactRecord.Id).Id 
                || contactRecord.Relationship_Type__c != contactIdPrimaryAlternateContactMap.get(contactRecord.Id).Relationship_Type__c 
                || contactRecord.Power_of_Attorney__c != contactIdPrimaryAlternateContactMap.get(contactRecord.Id).Power_of_Attorney__c
                || contactRecord.Legal_Guardian__c != contactIdPrimaryAlternateContactMap.get(contactRecord.Id).Legal_Guardian__c)){
                    contactRecord.Primary_Alternative_Contact__c = contactIdPrimaryAlternateContactMap.get(contactRecord.Id).Related_To__c;
                    contactRecord.Relationship_Type__c = contactIdPrimaryAlternateContactMap.get(contactRecord.Id).Relationship_Type__c;
                    contactRecord.Power_of_Attorney__c = contactIdPrimaryAlternateContactMap.get(contactRecord.Id).Power_of_Attorney__c;
                    contactRecord.Legal_Guardian__c = contactIdPrimaryAlternateContactMap.get(contactRecord.Id).Legal_Guardian__c;
                    contactToIsMinorMap.put(contactRecord.Id,contactRecord.Is_Minor__c);
                    contactList.add(contactRecord);
             }
        }
        
        for(Alternate_Contact__c alternativeContact : contactIdPrimaryAlternateContactMap.values()){
            if(contactToIsMinorMap.containsKey(alternativeContact.Consumer__c) && contactToIsMinorMap.get(alternativeContact.Consumer__c) && alternativeContact.Relationship_Type__c != 'Parent'
               && alternativeContact.Relationship_Type__c != 'Guardian'){
                alternativeContact.addError('Only Parent or Guardian can be selected as primary alternate contact');
            }
        }
        
        if(!contactList.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Contact', contactList, 'update', true,'NC_AlternateContactTriggerHandler','changePrimaryContact');
            Update objectDecision.getRecords();
        }
                
        if(!alternateContactList.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Alternate_Contact__c', alternateContactList, 'update', true,'NC_AlternateContactTriggerHandler','changePrimaryContact');
            Update objectDecision.getRecords();
        }
    }
    
}