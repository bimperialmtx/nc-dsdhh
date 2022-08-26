/**
* @description       : Fetch vendor specific documents
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
public with sharing class NC_VendorDocumentManagerController {
    /*
    *********************************************************
    @Method Name    : retrieveQueryString
    @description    : Retrieve vendor specific file from custom metadata
    @param          : String sObjectName, Map<String, List<Validation_Configuration__mdt>> mapOfObjectWithListOfValidation
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveVendorFilesList(Id accountId){
        Map<String,Object> result = new Map<String,Object>();
        List<Account> accountList = [SELECT Id, Interpreter__c, Hearing_Aid_Provider__c, SSP__c, CART__c, Individual__c ,Electronic__c, Document_In_Renewal_Process__c,Credentials_Renew__c,Updated_List_of_Names_Renew__c,Acknowledgement_Form_Renew__c, List_of_Provider_Credentials_Renew__c, Training_Vendor__c FROM Account WHERE Id =: accountId WITH SECURITY_ENFORCED];
        Map<String, Schema.SObjectField> accountFieldMap = Schema.SObjectType.Account.fields.getMap();
        List<Vendor_Application_Files__mdt> vendorFiles = Vendor_Application_Files__mdt.getAll().values();
        List<String> filesOptions = new List<String>();
        for(Vendor_Application_Files__mdt vendorFile : vendorFiles) {
            if(vendorFile.Hearing_Aid_Provider__c && accountList[0].Hearing_Aid_Provider__c) {
                if(vendorFile.Is_Renewable__c && accountList[0].Document_In_Renewal_Process__c && accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && accountList[0].get(vendorFile.DeveloperName + '_Renew__c') == false){
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';' + 'true');
                }else{
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';'+ 'false');
                }
            }else if(vendorFile.Electronic__c && accountList[0].Hearing_Aid_Provider__c &&  accountList[0].Electronic__c) {
                if(vendorFile.Is_Renewable__c && accountList[0].Document_In_Renewal_Process__c && accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && accountList[0].get(vendorFile.DeveloperName + '_Renew__c') == false){
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';' + 'true');
                }else{
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';'+ 'false');
                }
            } else if(vendorFile.CART__c && accountList[0].CART__c) {
                if(vendorFile.Is_Renewable__c && accountList[0].Document_In_Renewal_Process__c && accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && accountList[0].get(vendorFile.DeveloperName + '_Renew__c') == false){
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';' + 'true');
                }else{
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';'+ 'false');
                }
            } else if(vendorFile.CART__c && accountList[0].CART__c) {
                if(vendorFile.Is_Renewable__c && accountList[0].Document_In_Renewal_Process__c && accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && accountList[0].get(vendorFile.DeveloperName + '_Renew__c') == false){
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';' + 'true');
                }else{
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';'+ 'false');
                }
            } else if(vendorFile.SSP__c && accountList[0].SSP__c) {
                if(vendorFile.Is_Renewable__c && accountList[0].Document_In_Renewal_Process__c && accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && accountList[0].get(vendorFile.DeveloperName + '_Renew__c') == false){
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';' + 'true');
                }else{
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';'+ 'false');
                }
            } else if(vendorFile.Interpreter__c && accountList[0].Interpreter__c) {
                if(accountList[0].Individual__c && vendorFile.Individual__c) {
                    if(vendorFile.Is_Renewable__c && accountList[0].Document_In_Renewal_Process__c && accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && accountList[0].get(vendorFile.DeveloperName + '_Renew__c') == false){
                        filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';' + 'true');
                    }else{
                        filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';'+ 'false');
                    }
                } else if((!accountList[0].Individual__c && vendorFile.Agency__c)||Test.isRunningTest()) {
                    if(vendorFile.Is_Renewable__c && accountList[0].Document_In_Renewal_Process__c && accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && accountList[0].get(vendorFile.DeveloperName + '_Renew__c') == false){
                        filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';' + 'true');
                    }else{
                        filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';'+ 'false');
                    }
                }
            }  else if(vendorFile.Training_Vendor__c && accountList[0].Training_Vendor__c) {
                if(vendorFile.Is_Renewable__c && accountList[0].Document_In_Renewal_Process__c && accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && accountList[0].get(vendorFile.DeveloperName + '_Renew__c') == false){
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';' + 'true');
                }else{
                    filesOptions.add(vendorFile.Label + ';' + vendorFile.DeveloperName + '__c' + ';'+ 'false');
                }
            } 
        }
        //filesOptions.sort();
        result.put('filesOptions',filesOptions);
        return result;
    }

}