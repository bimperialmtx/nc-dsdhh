/*
*   Class Name: NC_ResourceTriggerHandler
*   Description: Resource Trigger Handler
*
*   Date            New/Modified         User                 Identifier                Description
*   16/07/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_ResourceTriggerHandler {
    
    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : before Insert for Resource Trigger
    @param          : List<Resource__c> newList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Resource__c> newList){
        createResourceBarcode(newList, null);
        updateStatusWhenBarcodePrintedAndAffixed(newList,NULL);
    }
    
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : before Update for Resource Trigger
    @param          : List<Resource__c> newList, Map<Id,Resource__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Resource__c> newList, Map<Id,Resource__c> oldMap){
        List<Resource__c> resourceList = new List<Resource__c>();
        for(Resource__c resource: newList) {
            if(resource.Regional_Center__c != oldMap.get(resource.id).Regional_Center__c || resource.Category__c != oldMap.get(resource.id).Category__c) {
                resourceList.add(resource);
            }
        }
        if(resourceList.size() > 0) {
         	createResourceBarcode(resourceList, oldMap);   
        }
        updateStatusWhenBarcodePrintedAndAffixed(newList,oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : After Update for Resource Trigger
    @param          : List<Resource__c> listOfResource, Map<Id, Resource__c> mapOfResource
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Resource__c> listOfResource, Map<Id, Resource__c> mapOfResource){
       Set<String> setOfResourceCategory = new Set<String>();
       for(Resource__c resource : listOfResource){
            if(resource.Status__c != mapOfResource.get(resource.Id).Status__c && resource.Status__c == NC_Constant.RETURN_RESOURCE_STATUS_AVAILABLE){
                setOfResourceCategory.add(resource.Category__c);
            }
       }
       if(!setOfResourceCategory.isEmpty()){
            notifieResourceLoanOwners(setOfResourceCategory);
       }
    }

    /*
    *********************************************************
    @Method Name    : updateStatusWhenBarcodePrintedAndAffixed
    @description    : update status on barcode fixed
    @param          : List<Resource__c> newList, Map<Id,Resource__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void updateStatusWhenBarcodePrintedAndAffixed(List<Resource__c> newList, Map<Id,Resource__c> oldMap){
        for(Resource__c resourceRecord : newList){
            if((oldMap == NULL || (oldMap.get(resourceRecord.Id).Barcode_Printed__c != resourceRecord.Barcode_Printed__c 
                                  || oldMap.get(resourceRecord.Id).Barcode_Affixed__c != resourceRecord.Barcode_Affixed__c)) &&
                resourceRecord.Barcode_Affixed__c && resourceRecord.Barcode_Printed__c && resourceRecord.Status__c == 'In Process'){
                resourceRecord.Status__c = 'Available';
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : notifieResourceLoanOwners
    @description    : Notify Resource Loan Owners for Avaiable Resources
    @param          : Set<String> setOfResourceCategory
    @return         : void
    ********************************************************
    */
    public static void notifieResourceLoanOwners(Set<String> setOfResourceCategory){
        Boolean isEquipmentAssigned = false;
        Boolean isMaterialAssigned = false;
        Map<Id, String> mapOfOwnerWithMessage = new Map<Id, String>();
        for(Resource_Loan__c resourceLoan : [SELECT Id, OwnerId, Category__c, Priority__c, CreatedDate FROM Resource_Loan__c WHERE Category__c IN : setOfResourceCategory AND Priority__c =: NC_Constant.HIGH_PRIORITY AND Status__c =: NC_Constant.RESOURCE_LOAN_STATUS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
            if(resourceLoan.Category__c != NC_Constant.RESOURCE_CATEGORY_MATERIAL && !isEquipmentAssigned){
                mapOfOwnerWithMessage.put(resourceLoan.OwnerId, 'Your Resource is avaiable please review the record you created : ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Requested_Resource__c/'+resourceLoan.Id+'/view');
                isEquipmentAssigned = true;
            }
            if(resourceLoan.Category__c == NC_Constant.RESOURCE_CATEGORY_MATERIAL && !isMaterialAssigned){
                mapOfOwnerWithMessage.put(resourceLoan.OwnerId, 'Your Resource is avaiable please review the record you created : ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Requested_Resource__c/'+resourceLoan.Id+'/view');
                isMaterialAssigned = true;
            }
        }
        NC_SendBulkEmail.notifieResourceLoanOwner(mapOfOwnerWithMessage);
    }
    
    /*
    *********************************************************
    @Method Name    : createResourceBarcode
    @description    : Create/Generate barcode for Resource
    @param          : List<Resource__c> newList
    @return         : void
    ********************************************************
    */
    private static void createResourceBarcode(List<Resource__c> newList, Map<Id,Resource__c> oldMap){
        Map<Id,String> regionalCenterIdToNameMap = NC_Utility.getRegionalCenterIdToNameMap();
        Map<Id,Integer> regionalCenterToResourceCountMap = new Map<Id,Integer>();
        Integer numberOfResource = 0;

        for(Resource__c resourceRecord : [SELECT Id,CreatedDate,Bar_Code_Number__c,Resource_Number__c,Regional_Center__c FROM Resource__c WHERE Bar_Code_Number__c != NULL WITH SECURITY_ENFORCED Order By Resource_Number__c  DESC  ]){
            numberOfResource = numberOfResource == 0 ? Integer.valueOf(resourceRecord.Resource_Number__c) : numberOfResource;
            Integer resourceNumber = Integer.valueOf(resourceRecord.Bar_Code_Number__c.substring(resourceRecord.Bar_Code_Number__c.length() - 5 , resourceRecord.Bar_Code_Number__c.length()));
            if(!regionalCenterToResourceCountMap.containsKey(resourceRecord.Regional_Center__c)){
                regionalCenterToResourceCountMap.put(resourceRecord.Regional_Center__c,resourceNumber);
            }
            if(regionalCenterIdToNameMap.size() == regionalCenterToResourceCountMap.size()){
                Break;
            }
        }
        for(Resource__c resource : newList){
            Integer lastCount = regionalCenterToResourceCountMap.containsKey(resource.Regional_Center__c) ? regionalCenterToResourceCountMap.get(resource.Regional_Center__c) + 1 : 1 ;
            numberOfResource++;
            
            if(oldMap != null && resource.Regional_Center__c != oldMap.get(resource.id).Regional_Center__c && resource.Category__c == oldMap.get(resource.id).Category__c) {
                numberOfResource = numberOfResource == 1 ? numberOfResource : numberOfResource - 1;
            }
            if(oldMap != null && resource.Category__c != oldMap.get(resource.id).Category__c && resource.Regional_Center__c == oldMap.get(resource.id).Regional_Center__c) {
                numberOfResource = numberOfResource == 1 ? numberOfResource : numberOfResource - 1;
                lastCount = lastCount == 1 ? lastCount : lastCount - 1;
            }
            if(oldMap != null && resource.Category__c != oldMap.get(resource.id).Category__c && resource.Regional_Center__c != oldMap.get(resource.id).Regional_Center__c) {
                numberOfResource = numberOfResource == 1 ? numberOfResource : numberOfResource - 1;
                lastCount = lastCount == 1 ? lastCount : lastCount - 1;
            }
            
            resource.Bar_Code_Number__c = barCodeGenrator(resource, regionalCenterIdToNameMap, lastCount);
            resource.Resource_Number__c = numberOfResource;
            regionalCenterToResourceCountMap.put(resource.Regional_Center__c, lastCount);
        }
    }
    
    /*
    *********************************************************
    @Method Name    : barCodeGenrator
    @description    : Generate barcode for Resource
    @param          : Resource__c record, Map<Id,String> regionalCenterIdToNameMap, Integer lastCount
    @return         : void
    ********************************************************
    */
    private Static String barCodeGenrator(Resource__c record, Map<Id,String> regionalCenterIdToNameMap, Integer lastCount){
        String barCode = 'DSDHH.';
        
        barCode += NC_Constant.categoryToCodeMap.get(record.Category__c);
        if(regionalCenterIdToNameMap.containsKey(record.Regional_Center__c)){
            barCode += NC_Constant.regionalCenterToNumberMap.get(regionalCenterIdToNameMap.get(record.Regional_Center__c));
        }
        barCode += String.ValueOf(lastCount).leftPad(5, '0');
        return barCode;
    }
}