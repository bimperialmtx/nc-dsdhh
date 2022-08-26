/*
**   Class Name: NC_LicensesTriggerHandler
**   Description: Triggerhandler on License
**
**     Date            New/Modified           User                 Identifier                Description
**   05-15-2020             New          Shubham Dadhich
*/
public without sharing class NC_LicensesTriggerHandler {
    
    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before insert' trigger event
    @param          : List<License__c> newLicensesList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<License__c> newLicensesList){
        duplicateLicenseNumberCheck(newLicensesList,null);
    }
    
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<License__c> newLicensesList, Map<Id,License__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<License__c> newLicensesList, Map<Id,License__c> oldMap){
        duplicateLicenseNumberCheck(newLicensesList,oldMap);
        validateDocument(newLicensesList);
    }

    /*
    *********************************************************
    @Method Name    : validateDocument
    @description    : Validate proof of license to be uploaded field
    @param          : List<License__c> licensesList
    @return         : void
    ********************************************************
    */
    public static void validateDocument(List<License__c> licensesList) {
        for(License__c selectedLicense : licensesList) {
            if(selectedLicense.Status__c == 'Submitted' && ! selectedLicense.Proof_of_License_Uploaded__c) {
                selectedLicense.addError('Proof of License needs to be uploaded.');
            }
        }
    }
      
    /*
    *********************************************************
    @Method Name    : duplicateLicenseNumberCheck
    @description    : Check for duplicate license
    @param          : List<License__c> newList, Map<Id,License__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void duplicateLicenseNumberCheck(List<License__c> newList, Map<Id,License__c> oldMap){
        Set<String> licenseNumberSet = new Set<String>();
        Map<String, License__c> licenseNumberToLicenseMap = new Map<String, License__c>();
        for(License__c selectedLicense : newList){
            if((oldMap == NULL || oldMap.get(selectedLicense.Id).License_Number__c != selectedLicense.License_Number__c) 
               && selectedLicense.License_Number__c != NULL){
                if(!licenseNumberToLicenseMap.containsKey(selectedLicense.License_Number__c)){
                    licenseNumberToLicenseMap.put(selectedLicense.License_Number__c,selectedLicense);
                }else{
                    selectedLicense.addError('A License Already Exist With Same License Number.');
                }
            }
        }
        for(License__c license: [SELECT Id, License_Number__c FROM License__c WHERE License_Number__c IN: licenseNumberToLicenseMap.keySet() WITH SECURITY_ENFORCED]){
            licenseNumberSet.add(license.License_Number__c);
            
        }
        
        for(License__c license : licenseNumberToLicenseMap.values()){
            if(licenseNumberSet.contains(license.License_Number__c)){
                license.addError('A License Already Exist With Same License Number.');
            }
        }
    }
}