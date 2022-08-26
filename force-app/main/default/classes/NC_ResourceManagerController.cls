/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_ResourceManagerController {
    public Requested_Resource__c requestedResource {get;set;}
    public Resource__c resource {get;set;}
    public Date dueDate {get;set;}
    public String scanCode{get;set;}
    public String errorMessage{get;set;}
    private ApexPages.StandardController cstr;
        
    public NC_ResourceManagerController(ApexPages.StandardController controller) {
        requestedResource = new Requested_Resource__c();
        resource = new Resource__c();
        if(!Test.isRunningTest()) {
            controller.addFields(new String[]{
                NC_Constant.RESOUCE_FIELD_CATEGORY ,
                NC_Constant.RESOUCE_FIELD_REGIONAL_CENTER
            });
        }
        cstr = controller;
    }

    /*
    *********************************************************
    @Method Name    : resourceCheckOut
    @description    : Check out resource with validations
    @param          : 
    @return         : void
    ********************************************************
    */
    public void  resourceCheckOut(){
        errorMessage = '';
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            Resource_Loan__c loanRequest = (Resource_Loan__c)cstr.getRecord(); 
            List<Resource__c> resourceList = [SELECT Id, Status__c, Category__c, Regional_Center__c FROM Resource__c WHERE Bar_Code_Number__c =: scanCode WITH SECURITY_ENFORCED LIMIT 1 ];
            List<Requested_Resource__c> requestedResourceList = new List<Requested_Resource__c>();
            if(resourceList.isEmpty()) {
                errorMessage = NC_Constant.RESOURCE_BARCODE_NOT_VALID ;
            } else if(resourceList[0].Status__c == NC_Constant.RETURN_RESOURCE_STATUS_UNAVAILABLE || resourceList[0].Status__c == NC_Constant.RETURN_RESOURCE_STATUS_INACTIVE) {
                errorMessage = 'You can not check-out an "' + resourceList[0].Status__c + '" resource.';
                updateStatus(loanRequest.Id);
            } else if(String.isBlank(loanRequest.Category__c)) {
                errorMessage = 'Category cannot be blank. Add Category to proceed with Resource Check-Out.';
            } else if(loanRequest.Category__c != resourceList[0].Category__c) {
                errorMessage = 'You can only check-out "' + loanRequest.Category__c + '" type of resources.';
            } else if(loanRequest.Regional_Center__c != resourceList[0].Regional_Center__c) {
                errorMessage = NC_Constant.RESOURCE_SHOULD_BE_OF_SAME_REGIONAL_CENTER; 
            } else if(dueDate < Date.today()) {
                errorMessage = 'Due date cannot be in past'; 
            } else { 
                resourceList[0].Status__c = dueDate.year() == 2999 ? NC_Constant.RETURN_RESOURCE_STATUS_INACTIVE : NC_Constant.RETURN_RESOURCE_STATUS_UNAVAILABLE;
                resourceList[0].Condition_of_Resource__c = requestedResource.Condition_of_Resource__c; 
                requestedResourceList.add(new Requested_Resource__c(
                Resource__c = resourceList[0].Id, 
                Resource_Loan__c = loanRequest.Id, 
                Due_Date__c = dueDate,
                Condition_of_Resource__c = requestedResource.Condition_of_Resource__c,
                State__c = NC_Constant.RESOURCE_STATE_CHECKEDOUT));
                // TAPM have read access on Resource__c
                upsert resourceList;
                if(Schema.SObjectType.Requested_Resource__c.isCreateable() || Schema.SObjectType.Requested_Resource__c.isUpdateable()) {
                    upsert requestedResourceList;
                }
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            errorMessage = ex.getMessage();            
        }
    }

    /*
    *********************************************************
    @Method Name    : updateStatus
    @description    : update resource loan status
    @param          : Id resourceLoanId
    @return         : void
    ********************************************************
    */
    public void updateStatus(Id resourceLoanId){
        Resource_Loan__c resourceLoan = new Resource_Loan__c();
        resourceLoan = [SELECT Id, Status__c FROM Resource_Loan__c WHERE Id =: resourceLoanId WITH SECURITY_ENFORCED LIMIT 1 ];
        resourceLoan.Status__c = NC_Constant.RESOURCE_LOAN_STATUS;
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Resource_Loan__c', new List<Resource_Loan__c>{resourceLoan}, 'update', true,'NC_ResourceManagerController','updateStatus');
        update decision.getRecords();
    }

    /*
    *********************************************************
    @Method Name    : resourceCheckIn
    @description    : Check in Resource
    @param          : 
    @return         : void
    ********************************************************
    */
    public void  resourceCheckIn(){
        errorMessage = '';
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            Resource_Loan__c loanRequest = (Resource_Loan__c)cstr.getRecord(); 
            List<Resource__c> resourceList = [SELECT Id, Status__c, Category__c FROM Resource__c WHERE Bar_Code_Number__c =: scanCode WITH SECURITY_ENFORCED LIMIT 1 ];
            List<Requested_Resource__c> requestedResourceList = [SELECT Id, Resource__c, State__c,Checked_In_Date__c FROM Requested_Resource__c WHERE Resource_Loan__c =: loanRequest.Id  AND Resource__r.Bar_Code_Number__c =: scanCode AND State__c = 'Checked-Out' WITH SECURITY_ENFORCED];
            if(resourceList.isEmpty()) {
                errorMessage = NC_Constant.RESOURCE_BARCODE_NOT_VALID ;
            } else if(requestedResourceList.isEmpty()) {
                errorMessage = NC_Constant.RESOURCE_NOT_CHECKOUT ;
            }else if(requestedResourceList.size() > 0) {
                requestedResourceList[0].State__c = NC_Constant.RESOURCE_STATE_CHECKEDIN ;
                requestedResourceList[0].Checked_In_Date__c = Date.today();
                requestedResourceList[0].Returned_Resource_Status__c = requestedResource.Returned_Resource_Status__c;
                requestedResourceList[0].Condition_of_Resource__c = requestedResource.Condition_of_Resource__c;
                String state = requestedResource.Returned_Resource_Status__c == NC_Constant.RETURN_RESOURCE_STATUS_GOOD ? NC_Constant.RETURN_RESOURCE_STATUS_AVAILABLE : NC_Constant.RETURN_RESOURCE_STATUS_INACTIVE;
                resourceList[0].Status__c = state;
                resourceList[0].Condition_of_Resource__c = requestedResource.Condition_of_Resource__c;
                resourceList[0].Returned_Resource_Status__c = requestedResource.Returned_Resource_Status__c;
                //Require read access to users and update from Check In button
                upsert resourceList;
                if(Schema.SObjectType.Requested_Resource__c.isCreateable() || Schema.SObjectType.Requested_Resource__c.isUpdateable()) {
                    upsert requestedResourceList;
                }
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            errorMessage = ex.getMessage();            
        }
    }
    
    public Pagereference redirect() {
        return cstr.view();
    }
}