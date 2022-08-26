/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_ResourceTransferController {
    
    /*
    *********************************************************
    @Method Name    : getRegionalCenter
    @description    : Get regional center with resource validations
    @param          : String id
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> getRegionalCenter(String id){
        Map<String,Object> result = new Map<String, Object>();
        List<RegionalsCentersWrapper> regionalCenterWrapperList = new List<RegionalsCentersWrapper>();
        Resource__c resource = [SELECT Id, Regional_Center__r.Name, Status__c, Category__c FROM Resource__c WHERE Id =: id WITH SECURITY_ENFORCED LIMIT 1];
        String regionalCenterName = resource.Regional_Center__r.Name;
        RegionalsCentersWrapper regionalCenterWrapperObj;
        if(resource.Status__c != 'Available' && resource.Status__c != 'Approved Transfer'){
            result.put('message','Resource is not Available');
        }else if((resource.Category__c == 'Demo Equipment' || resource.Category__c == 'Equipment/Media State Asset') && resource.Status__c != 'Approved Transfer'){
            result.put('message','Please take approval before transfer the Staff Resources');
        }else for(Account accountObj : [SELECT Id, Name FROM Account WHERE RecordTypeId =: NC_Utility.RecordTypeUtilityMethod('Account',NC_Constant.Account_Regional_Center_RecordType) WITH SECURITY_ENFORCED]){
            if(regionalCenterName != accountObj.Name){
                regionalCenterWrapperObj = new RegionalsCentersWrapper();
                regionalCenterWrapperObj.name = accountObj.Name;
                regionalCenterWrapperObj.id = accountObj.Id;
                regionalCenterWrapperList.add(regionalCenterWrapperObj);
            }
            result.put('result', regionalCenterWrapperList);
        }
        return result;
    }

    /*
    *********************************************************
    @Method Name    : transferResourceToRegional
    @description    : Transfer resource to Regional Center
    @param          : String id, String regionalCenterId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void transferResourceToRegional(String id, String regionalCenterId){
        Resource__c resource = [SELECT Id, Regional_Center__c, Available_From_Regional_Center__c, Status__c FROM Resource__c WHERE Id =: id WITH SECURITY_ENFORCED];
        resource.Available_From_Regional_Center__c = resource.Regional_Center__c;
        resource.Regional_Center__c = regionalCenterId;
        resource.Status__c = NC_Constant.STATUS_PENDING_SHIPMENT;
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Resource__c', new List<Resource__c>{resource}, 'update', true,'NC_ResourceTransferController','transferResourceToRegional');
        update decision.getRecords();
    }

    public class RegionalsCentersWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String id;
        public RegionalsCentersWrapper(){
            name = '';
            id = '';
        }
    }
}