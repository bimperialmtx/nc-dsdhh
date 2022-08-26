/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_Open_DocumentController {
    
    /*
    *********************************************************
    @Method Name    : getPageURL
    @description    : Decide hearing aid or equipment authorization letter based on authorization record type
    @param          : String recordId
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static string getPageURL(String recordId){
        String url = '';
        Authorization__c authorization = [SELECT Id, RecordType.DeveloperName FROM Authorization__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        if(authorization.RecordType.DeveloperName == NC_Constant.AUTHORIZATION_RECORDTYPE_HEARING_AID){
            PageReference pageRef = Page.NC_HA_Authorization;
            pageRef.getParameters().put('id',recordId);
            url = pageRef.getURL();
        }else{
            PageReference pageRef = Page.NC_EquipmentAuthorization;
            pageRef.getParameters().put('id',recordId);
            url = pageRef.getURL();
        }
        return url;
    }
}