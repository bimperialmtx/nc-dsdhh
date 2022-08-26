/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_CreateAppointmentController {
    /*
    *********************************************************
    @Method Name    : retrieveVendor
    @description    : Retrieve Authorization related details
    @param          : Id authorizationId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> retrieveVendor(Id authorizationId){
        Map<String,Object> result = new Map<String,Object>();
        List<Authorization__c> authorizationList =  [SELECT Vendor__c,Consumer__c, (SELECT Id FROM Appointments__r) FROM Authorization__c WHERE Id =:  authorizationId WITH SECURITY_ENFORCED];
        if(authorizationList.size() > 0) {
            result.put('authorization',authorizationList[0]);
            result.put('order',authorizationList[0].Appointments__r.size() + 1);
        }
        return result;
    }
}