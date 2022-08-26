/*
*   Class Name: NC_AccountTriggerHandler
*   Description: Account Trigger Handler -- Logics on insert, update and delete
*
*   Date            New/Modified         User                 Identifier                Description
*   28/04/2020         New         Shubham Dadhich(mtx)
*   24/07/2020         New         Hiten Aggarwal(mtx)
*   31/03/2021         New         Upendra Dubey(mtx)
*/
public without sharing class NC_AccountTriggerHandler {
     
	public static Id accountVendorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'Vendor');
    public static Id accountTrainerRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'NDBEDP_Trainer');
    public static Set<Id> vendorTrainerTypeSet = new Set<Id>{accountVendorRecordTypeId, accountTrainerRecordTypeId};
    public static Boolean isTriggerExecuted = false;
    public static Boolean isSubmittedAndErrorVendor = false;

    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before Insert' trigger event
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Account> newAccountList) {
        Id assessorRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Assessor').getRecordTypeId();
        for(Account acc : newAccountList) {
            if (acc.RecordTypeId == assessorRecTypeId && acc.Status__c=='Approved') {
                acc.Active__c=true;
            }
            if (acc.RecordTypeId == assessorRecTypeId && acc.Active__c==true) {
                 acc.Status__c='Approved';
            }
        }

         updateDetailsFromCounty(newAccountList,NULL);
        //updateDetailsFromCounty(newAccountList,oldMap);
        populateRenewalDate(newAccountList);
        populateElectronic(newAccountList);
        updateAlternatePhoneNumber(newAccountList);
        updateCellPhoneNumber(newAccountList);
        updatePhoneNumber(newAccountList);
        updateTTYNumber(newAccountList);
        updateVideoPhoneNumber(newAccountList);
        fetchRelatedCounty(newAccountList);
        updateTaxCode(newAccountList,NULL);
        updateRemitToStateVal(newAccountList,NULL);
        mapPhysicalToMailingAddress(newAccountList);
       // updateTheEmailField(newAccountList,NULL);
       // updateIsVendorPortal(newAccountList,NULL);
        isTriggerExecuted = true;
    }

    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Account> newAccountList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Account> newAccountList, Map<Id,Account> oldMap){
        Id assessorRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Assessor').getRecordTypeId();
        for(Account acc : newAccountList) {
            if (acc.RecordTypeId == assessorRecTypeId && acc.Status__c=='Approved' && acc.Status__c != oldMap.get(acc.Id).Status__c) {
                acc.Active__c=true;
            }
            if(acc.Active__c != oldMap.get(acc.Id).Active__c && acc.Active__c==false){
                acc.Status__c='Inactive';
            }
            if(vendorTrainerTypeSet.contains(acc.RecordTypeId) && acc.Active__c != oldMap.get(acc.Id).Active__c && acc.Active__c==true && acc.Status__c == 'Inactive'){
                acc.Status__c='Approved';
            }
             if(acc.RecordTypeId == assessorRecTypeId && acc.Active__c && acc.Active__c != oldMap.get(acc.Id).Active__c){
                acc.Comment__c=null;
            }
        }
        validateVendorStatus(newAccountList, oldMap);
        timeValidation(newAccountList, oldMap);
        updateDetailsFromCounty(newAccountList,oldMap);
        updateRenewalDate(newAccountList,oldMap);    
        fetchRelatedCounty(newAccountList);
        mapPhysicalAndMailingAddressToRemitAddress(newAccountList);
        mapPhysicalToMailingAddress(newAccountList);
        electronicPaymentFormTrueInformationSectionRequired(newAccountList);
        validateDocument(newAccountList,oldMap);
        putAccountOnCompleteRenewal(newAccountList,oldMap);
       	previousRecordInactiveDuplicateRecordApproved(newAccountList, oldMap);
        updateTaxCode(newAccountList,NULL);
        updateRemitToStateVal(newAccountList,NULL);
        updateVendorInProgress(newAccountList, oldMap);
        updateNCASErrorN(newAccountList, oldMap);
        updateNCASErrorX(newAccountList, oldMap);
        updateVendorActive(newAccountList, oldMap);
        populateElectronic(newAccountList);
        updateAlternatePhoneNumber(newAccountList);
        updateCellPhoneNumber(newAccountList);
        updatePhoneNumber(newAccountList);
        updateVideoPhoneNumber(newAccountList);
        updateTheEmailField(newAccountList,oldMap);
        updateTTYNumber(newAccountList);
        restrictUpdateIsVendorPortal(newAccountList, oldMap);
        updateIsVendorPortal(newAccountList, oldMap);
        updateStatusFieldForActive(newAccountList, oldMap);
        validateNDBEDPTrainer(newAccountList, oldMap);
        validateAssessor(newAccountList, oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<Account> newAccountList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Account> newAccountList, Map<Id,Account> oldMap){
        trackVendorFields(newAccountList,oldMap);
        unfreezeRecord(newAccountList, oldMap);
        submitNCASErrorVendorForApproval(newAccountList, oldMap);
        synWithNDBEDP(newAccountList,oldMap);
    }

    /*
    *********************************************************
    @Method Name    : synWithNDBEDP
    @description    : Sync Assessor with NDBEDP
    @param          : List<Account> newAccountList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void synWithNDBEDP(List<Account> newList, Map<Id, Account> oldMap){
        List<Account> assessorListNDBEDP = new List<Account>();
        List<String> actionCodes= new List<String>{'SHC','SHP', 'PO', 'POC', 'ASG','WIP'};
        List<String> actionCodes2= new List<String>{'AGT' , 'POB', 'APPROV', 'APPRV','APPAG' , 'WLFND' , 'WLCNS','WLAGT' , 'WLEQP'};
        Request_Equipment__c requestEquipment;
        Case openRequest;
        for(Account user : newList) {
            if (user.Patron_ID__c!=null && (oldMap.get(user.Id).BillingStreet != user.BillingStreet || oldMap.get(user.Id).BillingCity != user.BillingCity || oldMap.get(user.Id).BillingPostalCode != user.BillingPostalCode
                    || oldMap.get(user.Id).BillingCountryCode != user.BillingCountryCode || oldMap.get(user.Id).BillingStateCode != user.BillingStateCode)) {
                assessorListNDBEDP.add(user);
            }
        }
        for(Case obj :[SELECT Id,External_Assessor__c,MatReqStatus__c FROM Case WHERE External_Assessor__c IN:assessorListNDBEDP AND MatReqStatus__c='Open' AND MatRequestObj__c!=NULL]){
            openRequest=obj;
        }
        if (openRequest!=null) {
            for(Request_Equipment__c reqEquip :[SELECT Id, LineStatus__c,LastActionCode__c,MatRequestLineObj__c FROM Request_Equipment__c
            WHERE Request__c  =:openRequest.Id AND MatRequestLineObj__c!=NULL AND LastActionCode__c IN :actionCodes2 WITH SECURITY_ENFORCED LIMIT 1]){
                requestEquipment = reqEquip;
            }
        }

        if (!assessorListNDBEDP.isEmpty() && openRequest!=null && requestEquipment!=null) {
            System.enqueueJob(new NC_NDBEDPTrainerSearch(assessorListNDBEDP)); 
        }
    }
    
    /*
    *********************************************************
    @Method Name    : submitNCASErrorVendorForApproval
    @description    : Submit record for approval when NCAS Error is occured
    @param          : List<Account> newAccountList, Map<Id, Account> oldMap
    @return         : void
    ********************************************************
    */
    private static void submitNCASErrorVendorForApproval(List<Account> newAccountList, Map<Id, Account> oldMap) {
        Set<Id> sendForApprovalIds = new Set<Id>();
        List<Account> accountList = new List<Account>();
        for(Account accountRecord: newAccountList) {
            if(oldMap != NULL 
                && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
                && (accountRecord.Status__c == 'Submitted and Rejected' || accountRecord.Status__c == 'Pending Approval')
                && oldMap.get(accountRecord.Id).MM102_error_reason__c != accountRecord.MM102_error_reason__c
                && accountRecord.MM102_error_reason__c != null) {
                    sendForApprovalIds.add(accountRecord.Id);
            }
            if(oldMap != NULL 
                && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
                && accountRecord.Status__c == 'Pending Documents'
                && accountRecord.Equipment_Provider__c
                && accountRecord.Approved_Equipment_Provider__c) {
                    Account newAcc = new Account();
                    newAcc.id = accountRecord.id;
                    newAcc.Status__c = 'Pending Approval';
                    accountList.add(newAcc);
            }
        }
        if(sendForApprovalIds.size() > 0) {
            submitForApproval(sendForApprovalIds);
        }
        if(accountList.size() > 0) {
            //update accountList;
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Account', accountList, 'update', true,'NC_AccountTriggerHandler','submitNCASErrorVendorForApproval');
            update objectDecision.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : submitForApproval
    @description    : Submit record ids for approval
    @param          : Set<Id> recordIds
    @return         : void
    ********************************************************
    */
    public static void submitForApproval(Set<Id> recordIds) {
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        for(Id recordId: recordIds) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('');
            req.setObjectId(recordId);      
            processList.add(req);
        }
        Approval.process(processList);
    }

    /*
    *********************************************************
    @Method Name    : populateRenewalDate
    @description    : Update document renewal date based on vendor type
    @param          : List<User> userNewList
    @return         : void
    ********************************************************
    */
    private static void populateRenewalDate(List<Account> newAccountList){
        Id vendorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
       //List<Vendor_Application_Files_Renewal_Info__mdt> vendorFiles = [SELECT Label, DeveloperName, Initial_Renewal_date__c, Vendor_Type__c FROM Vendor_Application_Files_Renewal_Info__mdt] ;
       List<Vendor_Application_Files_Renewal_Info__mdt> vendorFiles = Vendor_Application_Files_Renewal_Info__mdt.getAll().values();

        for(Account selectedAccount : newAccountList) {
            if(selectedAccount.RecordTypeId == vendorRecordTypeId ) {
                for(Vendor_Application_Files_Renewal_Info__mdt vendorFile : vendorFiles) {
                    if(vendorFile.Vendor_Type__c == 'Hearing Aid' && selectedAccount.Hearing_Aid_Provider__c ||
                        vendorFile.Vendor_Type__c == 'CART'  && selectedAccount.CART__c ||
                        vendorFile.Vendor_Type__c == 'Interpreter Individual'  && selectedAccount.Interpreter__c && selectedAccount.Individual__c ||
                        vendorFile.Vendor_Type__c == 'Interpreter Agency'  && selectedAccount.Interpreter__c && !selectedAccount.Individual__c || 
                        vendorFile.Vendor_Type__c == 'SSP'  && selectedAccount.SSP__c ||
                        vendorFile.Vendor_Type__c == 'Training Vendor'  && selectedAccount.Training_Vendor__c) {
                        Date renewalDate = vendorFile.Initial_Renewal_date__c;
                        do {
                            renewalDate = renewalDate.addYears(1);
                        } while(renewalDate < Date.today());
                        selectedAccount.Yearly_Document_Renewal_Date__c = renewalDate;
                        renewalDate = vendorFile.Initial_Renewal_date__c;
                        do {
                            renewalDate = renewalDate.addYears(3);
                        } while(renewalDate < Date.today());
                        selectedAccount.Complete_Cycle_Renewal_Date__c = renewalDate;
                    }    
                }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateAlternatePhoneNumber
    @description    : Update Alternate phone number from phone
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    private static void updateAlternatePhoneNumber(List<Account> newAccountList){
        
        String phone='';
        for(Account selectedAccount : newAccountList) {
                if(selectedAccount.Alternative_Phone__c!=null){
                phone=String.valueOf(selectedAccount.Alternative_Phone__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //   phone=phone.replace('1', '');
                    // }
                }
                selectedAccount.Alternative_Phone__c=phone;

               }
        }
    }
   
    /*
    *********************************************************
    @Method Name    : updateCellPhoneNumber
    @description    : Update Cell phone number from phone
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    private static void updateCellPhoneNumber(List<Account> newAccountList){
        
        String phone='';
        for(Account selectedAccount : newAccountList) {
                if(selectedAccount.Cell_Phone__c!=null){
                phone=String.valueOf(selectedAccount.Cell_Phone__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //   phone=phone.replace('1', '');
                    // }
                }
                selectedAccount.Cell_Phone__c=phone;

               }
        }
    }

    /*
    *********************************************************
    @Method Name    : updatePhoneNumber
    @description    : Update phone number from phone
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    private static void updatePhoneNumber(List<Account> newAccountList){
        
        String phoneNumber='';
        for(Account selectedAccount : newAccountList) {
                if(selectedAccount.Phone!=null){
                phoneNumber=String.valueOf(selectedAccount.Phone);
                if(phoneNumber.contains('-')){
                    phoneNumber=phoneNumber.replaceAll('-','');
                }
                if(phoneNumber.contains('(')){
                    phoneNumber=phoneNumber.replace('(','');
                }
                if(phoneNumber.contains(')')){
                    phoneNumber=phoneNumber.replace(')','');
                }
                if(phoneNumber.contains(' ')){
                    phoneNumber=phoneNumber.replace(' ','');
                }
                if(phoneNumber.contains('+1')){
                    phoneNumber = phoneNumber.replace('+1','');
                    // if(phoneNumber.contains('1'))
                    // {
                    //     phoneNumber=phoneNumber.replace('1', '');
                    // }
                }
                selectedAccount.Phone=phoneNumber;

               }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateTTYNumber
    @description    : Update TTY number from phone
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    private static void updateTTYNumber(List<Account> newAccountList){
        
        String phone='';
        for(Account selectedAccount : newAccountList) {
                if(selectedAccount.TTY__c!=null){
                phone=String.valueOf(selectedAccount.TTY__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //   phone=phone.replace('1', '');
                    // }
                }
                selectedAccount.TTY__c=phone;

               }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateVideoPhoneNumber
    @description    : Update Video phone number from phone
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    private static void updateVideoPhoneNumber(List<Account> newAccountList){
        
        String phone='';
        for(Account selectedAccount : newAccountList) {
                if(selectedAccount.Video_Phone__c!=null){
                phone=String.valueOf(selectedAccount.Video_Phone__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //   phone=phone.replace('1', '');
                    // }
                }
                selectedAccount.Video_Phone__c=phone;

               }
        }
    }

    /*
    *********************************************************
    @Method Name    : populateElectronic
    @description    : Set Electronic to true if Electronic pay vendor is selected yes
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    private static void populateElectronic(List<Account> newAccountList){
        Id vendorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
        Id ndbedoTrainerRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account','NDBEDP_Trainer');
        for(Account selectedAccount : newAccountList) {
            if(selectedAccount.RecordTypeId == vendorRecordTypeId || selectedAccount.RecordTypeId == ndbedoTrainerRecordTypeId) {
                if(selectedAccount.Electronic_Pay_Vendor__c=='Yes'){
                selectedAccount.Electronic__c = True;
                }
                else{
                    selectedAccount.Electronic__c = false;
                }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateRenewalDate
    @description    : Update document renewal date based on vendor type
    @param          : List<Account> newAccountList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    private static void updateRenewalDate(List<Account> newAccountList, Map<Id,Account> oldMap){
        Id vendorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
        for(Account selectedAccount : newAccountList) {
            if(selectedAccount.RecordTypeId == vendorRecordTypeId && selectedAccount.Update_Yearly_Document_Renewal_Date__c) {
                selectedAccount.Update_Yearly_Document_Renewal_Date__c = false;
                selectedAccount.Yearly_Document_Renewal_Date__c = selectedAccount.Yearly_Document_Renewal_Date__c.addYears(1);
                //To Skip Yearly Renewal during three year renewal
                if(selectedAccount.Yearly_Document_Renewal_Date__c == selectedAccount.Complete_Cycle_Renewal_Date__c){
                    selectedAccount.Yearly_Document_Renewal_Date__c = selectedAccount.Yearly_Document_Renewal_Date__c.addYears(1);
                }
            }
            if(selectedAccount.RecordTypeId == vendorRecordTypeId && selectedAccount.Update_Complete_Cycle_Renewal_Date__c) {
                selectedAccount.Update_Complete_Cycle_Renewal_Date__c = false;
                selectedAccount.Complete_Cycle_Renewal_Date__c = selectedAccount.Complete_Cycle_Renewal_Date__c.addYears(3);
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateRemitToStateVal
    @description    : Update document renewal date based on vendor type
    @param          : List<Account> newAccountList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    private static void updateRemitToStateVal(List<Account> newAccountList, Map<Id,Account> oldMap){
       // List <State_Code__mdt > stateMetaList = State_Code__mdt.getAll();
       List<String> stateList = new List<String>();
    //     Map<String, State_Code__mdt> stateMetaMap = State_Code__mdt.getAll();
    //     for(String mapValue : stateMetaMap.keySet()){
    //         stateList.add(stateMetaMap.get(mapValue).MasterLabel) ;
    //    }

    for(State_Code__mdt mapValue :[SELECT Id,MasterLabel from State_Code__mdt]){
        stateList.add(mapValue.MasterLabel);
    }
        for(Account selectedAccount : newAccountList) {
            if(vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)) {
              if(selectedAccount.Remit_to_State_Cd__c!=null && stateList.contains(selectedAccount.Remit_to_State_Cd__c.toUpperCase())) {
                selectedAccount.Remit_to_State_Val__c ='Y';
              }
              else{
                selectedAccount.Remit_to_State_Val__c ='N';
              }
        }
      }
    }

    /*
    *********************************************************
    @Method Name    : updateTaxCode
    @description    : Update tax code value based on the w9 Entity type.
    @param          : List<Account> newAccountList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    private static void updateTaxCode(List<Account> newAccountList, Map<Id,Account> oldMap){
        for(Account selectedAccount : newAccountList) {
            if(vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId) && selectedAccount.W9_Entity_Type__c !=null) {
                if(selectedAccount.W9_Entity_Type__c == 'Sole/LLC/Partnership - Communication Access'){
                    selectedAccount.X1099_Code__c ='M7';
                }
                if(selectedAccount.W9_Entity_Type__c == 'Sole/LLC/Partnership - Equipment'){
                    selectedAccount.X1099_Code__c ='M6';
                }
                if(selectedAccount.W9_Entity_Type__c == 'Corporation - Any'){
                    selectedAccount.X1099_Code__c ='NO';
                }
                
        }
        //selectedAccount.Electronic_Pay_Vendor__c  ||
        if(vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId) && ( selectedAccount.Electronic_Pay_Vendor__c=='Yes' || selectedAccount.Bank_Reference__c!=null)){ //&& selectedAccount.Bank_Reference__c!=null
            selectedAccount.Pay_Info_Indicator__c = 'E';
            selectedAccount.Pay_Information__c = selectedAccount.Bank_Reference__c;
        }
        else{
            selectedAccount.Pay_Info_Indicator__c = '';
            selectedAccount.Pay_Information__c = '';
        }
    }
}
    
    /*
    *********************************************************
    @Method Name    : putAccountOnCompleteRenewal
    @description    : Update All The Document To Not Uploaded Status, Put The Vendor Application Back to Pending Document.
    @param          : List<Account> newList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    private static void putAccountOnCompleteRenewal(List<Account> newList, Map<Id,Account> oldMap){
        Id vendorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
      //  List<Vendor_Application_Files__mdt> vendorFiles = [SELECT Label, DeveloperName, Interpreter__c, Hearing_Aid_Provider__c, SSP__c, CART__c, Individual__c, Agency__c,Training_Vendor__c FROM Vendor_Application_Files__mdt];
        List<Vendor_Application_Files__mdt> vendorFiles = Vendor_Application_Files__mdt.getAll().values();
        // Map<String,Vendor_Application_Files__mdt>vendorFilesMap=
        // for(String vendorValue:vendorFilesMap.keySet()){
        //     vendorFiles.add(vendorFilesMap.get(vendorValue));
        // }
        Map<String, Schema.SObjectField> accountFieldMap = Schema.SObjectType.Account.fields.getMap();
        for(Account selectedAccount : newList){
            if(oldMap != Null && selectedAccount.Document_In_Complete_Renewal_Process__c != oldMap.get(selectedAccount.Id).Document_In_Complete_Renewal_Process__c
               && selectedAccount.Document_In_Complete_Renewal_Process__c == TRUE && selectedAccount.Status__c == 'Approved'){
                selectedAccount.Status__c = 'Pending Documents';
                   for(Vendor_Application_Files__mdt vendorFile : vendorFiles) {
                       if((vendorFile.Hearing_Aid_Provider__c && selectedAccount.Hearing_Aid_Provider__c) ||
                         (vendorFile.CART__c && selectedAccount.CART__c) ||
                         (vendorFile.SSP__c && selectedAccount.SSP__c)   ||
                         (vendorFile.Training_Vendor__c && selectedAccount.Training_Vendor__c) ||
                         ((vendorFile.Interpreter__c && selectedAccount.Interpreter__c) &&( 
                             (selectedAccount.Individual__c && vendorFile.Individual__c)  || 
                             (!selectedAccount.Individual__c && vendorFile.Agency__c)))) {
                                  if(accountFieldMap.containsKey(vendorFile.DeveloperName + '__c') && selectedAccount.get(vendorFile.DeveloperName + '__c') == TRUE){
                                     selectedAccount.put(vendorFile.DeveloperName + '__c',false);
                                  }
                                  if(accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c') && selectedAccount.get(vendorFile.DeveloperName + '_Renew__c') == TRUE){
                                     selectedAccount.put(vendorFile.DeveloperName + '_Renew__c',false);
                                  } 
                             }
                   }
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateAssessor
    @description    : Validate Assessor records
    @param          : List<Account> newList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
     public static void validateAssessor(List<Account> newList, Map<Id, Account> oldMap){
        Id accountAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'Assessor');
        Map<Id,Account> accIdMap=new  Map<Id,Account>();
        for(Account acc:newList){
            if(!acc.Active__c  && acc.Active__c != oldMap.get(acc.Id).Active__c && acc.RecordTypeId == accountAssessorRecordTypeId){
                accIdMap.put(acc.Id,acc);
            }
        }
       for(Case cas : [SELECT Id,MatReqStatus__c,External_Assessor__c,Status FROM Case WHERE External_Assessor__c IN :accIdMap.keySet()]){
             if(cas.Status!='Denied' && cas.MatReqStatus__c!='Closed'){
                accIdMap.get(cas.External_Assessor__c).addError('The assessor is assigned to a request which is not closed yet.');
             }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : fetchRelatedCounty
    @description    : Fetch Related County on the basis of City And Zipcode and populate it on Account
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    private static void fetchRelatedCounty(List<Account> newAccountList){

        List<String> zipCodeList = new List<String>();
        List<String> cityList = new List<String>();
        Map<String, Id> mapOfRegionalAccountNameWithId = new Map<String, Id>();
        Id RecordTypeId_RegionaCenter = NC_Utility.RecordTypeUtilityMethod('Account',NC_Constant.Account_Regional_Center_RecordType);
        //Add Values to City List and Zip List
        for(Account accRecord : newAccountList){
            cityList.add(accRecord.BillingCity);
            zipCodeList.add(accRecord.BillingPostalCode);
        }

        //Fetch Regional Center Account
        for(Account accRegional : [SELECT Id, Name FROM Account WHERE RecordTypeId =: RecordTypeId_RegionaCenter WITH SECURITY_ENFORCED]){
            mapOfRegionalAccountNameWithId.put(accRegional.Name, accRegional.Id);
        }

        //Fethcing County On the basis of CityList and ZipList
        for(Regional_Center_And_County__mdt regionalCenterCountyRecord : [SELECT Id, Regional_Center__c,County__c, City__c, Zip_Code__c, Region__c FROM Regional_Center_And_County__mdt WHERE Zip_Code__c IN: zipCodeList AND City__c IN: cityList]){
            for(Account accRecord : newAccountList){
                if(regionalCenterCountyRecord.City__c == accRecord.BillingCity && regionalCenterCountyRecord.Zip_Code__c == accRecord.BillingPostalCode){
                    // Inserting Values in County Field
                    accRecord.County__c = regionalCenterCountyRecord.County__c;
                    accRecord.Region__c = regionalCenterCountyRecord.Region__c != NULL ? regionalCenterCountyRecord.Region__c : NULL;
                    if(accRecord.recordTypeId != RecordTypeId_RegionaCenter && mapOfRegionalAccountNameWithId.containsKey(regionalCenterCountyRecord.Regional_Center__c)){
                        accRecord.Regional_Center__c = mapOfRegionalAccountNameWithId.get(regionalCenterCountyRecord.Regional_Center__c);
                    }
                }
            }
        }

    }
    
    /*
    *********************************************************
    @Method Name    : updateDetailsFromCounty
    @description    : Update Region and Regional Center from County
    @param          : List<Account> newList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    private static void updateDetailsFromCounty(List<Account> newList, Map<Id,Account> oldMap){
        Map<Account,String> accountToCountyMap = new Map<Account,String>();
        Map<String, Id> mapOfRegionalAccountNameWithId = new Map<String, Id>();
        Id RecordTypeId_RegionaCenter = NC_Utility.RecordTypeUtilityMethod('Account',NC_Constant.Account_Regional_Center_RecordType);
       
        
        for(Account selectedAccount : newList){
            if((oldMap == NULL || oldMap.get(selectedAccount.Id).County__c != selectedAccount.County__c) && selectedAccount.County__c != NULL){
                if( selectedAccount.County__c == 'Out of State' ){
					selectedAccount.Region__c = 'Out of State';                    
                }else{
                    accountToCountyMap.put(selectedAccount ,selectedAccount.County__c);
                }
            }
            if(String.IsNotBlank(selectedAccount.Bank_Acct_No__c) || String.IsNotBlank(selectedAccount.Bank_Acct_Name__c) || String.IsNotBlank(selectedAccount.Bank_Name_1__c) || String.IsNotBlank(selectedAccount.The_Bank_Account_Number__c) ) {
                selectedAccount.Vpy_Indicator__c = '1';
            } else {
                selectedAccount.Vpy_Indicator__c = '0';
            }
        }
         //Fetch Regional Center Account
        for(Account accRegional : [SELECT Id, Name FROM Account WHERE RecordTypeId =: RecordTypeId_RegionaCenter WITH SECURITY_ENFORCED]){
            mapOfRegionalAccountNameWithId.put(accRegional.Name, accRegional.Id);
        }
        
        for(Regional_Center_And_County__mdt regionalCenterCountyRecord : [SELECT Id, Regional_Center__c, County__c, City__c, Zip_Code__c, Region__c 
                                                                          FROM Regional_Center_And_County__mdt 
                                                                          WHERE County__c IN: accountToCountyMap.values()]){
              for(Account accountRecord: accountToCountyMap.keySet()){
                  if(accountToCountyMap.get(accountRecord) == regionalCenterCountyRecord.County__c){
                      accountRecord.Region__c = regionalCenterCountyRecord.Region__c;
                      if(accountRecord.recordTypeId != RecordTypeId_RegionaCenter && mapOfRegionalAccountNameWithId.containsKey(regionalCenterCountyRecord.Regional_Center__c)){
                        accountRecord.Regional_Center__c = mapOfRegionalAccountNameWithId.get(regionalCenterCountyRecord.Regional_Center__c);
                    }
                  }                                                           
               }
        }
                
    } 

    /*
    *********************************************************
    @Method Name    : validateDocument
    @description    : Validate Vendor specific documents before approval
    @param          : List<Account> vendorsList , Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateDocument(List<Account> vendorsList , Map<Id,Account> oldMap) {
        if(!isTriggerExecuted) {
         	Id vendorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account','Vendor');
             Id NDBEDPRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account','NDBEDP_Trainer');
           // List<Vendor_Application_Files__mdt> vendorFiles = [SELECT Label, DeveloperName, Interpreter__c, Hearing_Aid_Provider__c, SSP__c, CART__c, Individual__c, Agency__c, Training_Vendor__c FROM Vendor_Application_Files__mdt];
            List<Vendor_Application_Files__mdt> vendorFiles = Vendor_Application_Files__mdt.getAll().values();
            // Map<String,Vendor_Application_Files__mdt>vendorFilesMap=
            // for(String vendorValue:vendorFilesMap.keySet()){
            //     vendorFiles.add(vendorFilesMap.get(vendorValue));
            // }
            Map<String, Schema.SObjectField> accountFieldMap = Schema.SObjectType.Account.fields.getMap();
            
            for(Account selectedAccount : vendorsList) {
                if(selectedAccount.RecordTypeId == vendorRecordTypeId && 
                   selectedAccount.Status__c != oldMap.get(selectedAccount.id).Status__c &&
                   ((selectedAccount.Status__c == NC_Constant.ACCOUNT_PENDING_APPROVAL) ||
                   (selectedAccount.Status__c == NC_Constant.APPROVED) ||
                   (selectedAccount.Status__c == 'Renewal Pending'))) {
                      for(Vendor_Application_Files__mdt vendorFile : vendorFiles) {
                          if((vendorFile.Hearing_Aid_Provider__c && selectedAccount.Hearing_Aid_Provider__c) ||
                             (vendorFile.CART__c && selectedAccount.CART__c) ||
                             (vendorFile.SSP__c && selectedAccount.SSP__c)   ||
                             (vendorFile.Training_Vendor__c && selectedAccount.Training_Vendor__c) ||
                             ((vendorFile.Interpreter__c && selectedAccount.Interpreter__c) &&( 
                                 (selectedAccount.Individual__c && vendorFile.Individual__c)  || 
                                 (!selectedAccount.Individual__c && vendorFile.Agency__c)))) {
                                     
                                     if(accountFieldMap.containsKey(vendorFile.DeveloperName + '__c')){
                                         if(!Boolean.valueof(selectedAccount.get(vendorFile.DeveloperName + '__c'))) {
                                             selectedAccount.addError(System.Label.Vendor_Approval_validation_Message);
                                         }
                                     }
                                     if(selectedAccount.Status__c == 'Renewal Pending'){
                                         if(accountFieldMap.containsKey(vendorFile.DeveloperName + '_Renew__c')){
                                             if(!Boolean.valueof(selectedAccount.get(vendorFile.DeveloperName + '_Renew__c'))) {
                                                 selectedAccount.addError('Please upload all the highlighted documents under the Document Manager section before submitting the Application for Renewal.');
                                             } 
                                        } 
                                     }
                                 } 
                      }
                }
                // NDBEDP Document validation 
                if(selectedAccount.RecordTypeId == NDBEDPRecordTypeId && 
                    (oldMap.get(selectedAccount.Id).status__c == NC_Constant.CONSUMER_STATUS_PENDING_DOCUMENT && selectedAccount.status__c == NC_Constant.CONSUMER_STATUS_PENDING_APPROVAL)
                    && (!selectedAccount.Resume_Equipment_Training_History__c || !selectedAccount.Required_Certifications__c ||
                        !selectedAccount.W_9_Form__c || !selectedAccount.Signed_Federal_ID_Number__c 
                        || !selectedAccount.Signed_original_copy_of_the_Proposal__c)){
                        selectedAccount.addError(NC_Constant.NDBEDP_TRIGGER_ERROR_NDBEDP_TRAINER_UPLOADED);
                }
            }   
        }
    }
    
    /*
    *********************************************************
    @Method Name    : electronicPaymentFormTrueInformationSectionRequired
    @description    : Electronic Pay vendor required field validation
    @param          : List<Account> newAccountList
    @return         : void
    ********************************************************
    */
    public static void electronicPaymentFormTrueInformationSectionRequired(List<Account> newAccountList) {
        List<Schema.FieldSetMember> fieldSetMembers= new List<Schema.FieldSetMember>();
        for(Account selectedAccount : newAccountList) {
            String errorMessageFields = '';
            //selectedAccount.Electronic_Pay_Vendor__c == True &&
            if( selectedAccount.Electronic_Pay_Vendor__c == 'Yes' && vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)) {
                fieldSetMembers = Schema.SObjectType.Account.fieldSets.Electronic_Pay_Vendor.getFields();
            } else if(vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)) {
                fieldSetMembers = Schema.SObjectType.Account.fieldSets.Non_Electronic_Vendor_Validation.getFields();
            }
            for(FieldSetMember selectedFieldSetMember : fieldSetMembers) {
                Schema.DescribeFieldResult describeFiledResult = selectedFieldSetMember.getSObjectField().getDescribe();
                if(selectedAccount.get(describeFiledResult.getName()) == null) {
                    errorMessageFields += errorMessageFields == '' ? describeFiledResult.getLabel() : ', ' + describeFiledResult.getLabel();
                }
            }
            if(errorMessageFields != '' && vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)) {
                selectedAccount.addError('Following fields are required (' + errorMessageFields + ')');
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : trackVendorFields
    @description    : for tracking Email fields of vendor
    @param          : List<Account> newList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    private static void trackVendorFields(List<Account> newList, Map<Id,Account> oldMap){
        Id vendorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account',NC_Constant.Account_Vendor_RecordType);
        List<Schema.FieldSetMember> fieldSetMemberList =  NC_Utility.getFieldSet('Account','Tracking_Fields');
        Map<String,Set<Id>> groupNameToAccountMap = new Map<String,Set<Id>>();
        Map<String,String> contractorGroupNameMap = NC_Constant.contractorGroupNameMap;
        
        for(Account selectedAccount: newList){
            if(oldMap != NULL && selectedAccount.RecordTypeId == vendorRecordTypeId){
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    if( oldMap.get(selectedAccount.Id).get(fieldSetMemberObj.getFieldPath()) != selectedAccount.get(fieldSetMemberObj.getFieldPath())){
                        if(selectedAccount.Hearing_Aid_Provider__c){
                            if(!groupNameToAccountMap.containsKey(contractorGroupNameMap.get('Hearing_Aid_Provider__c'))){
                                groupNameToAccountMap.put(contractorGroupNameMap.get('Hearing_Aid_Provider__c'),new Set<Id>());
                            }
                            groupNameToAccountMap.get(contractorGroupNameMap.get('Hearing_Aid_Provider__c')).add(selectedAccount.Id);
                        } 
                        if(selectedAccount.CART__c){
                            if(!groupNameToAccountMap.containsKey(contractorGroupNameMap.get('CART__c'))){
                                groupNameToAccountMap.put(contractorGroupNameMap.get('CART__c'),new Set<Id>());
                            }
                            groupNameToAccountMap.get(contractorGroupNameMap.get('CART__c')).add(selectedAccount.Id);
                        } 
                        if(selectedAccount.Equipment_Provider__c){
                            if(!groupNameToAccountMap.containsKey(contractorGroupNameMap.get('Equipment_Provider__c'))){
                                groupNameToAccountMap.put(contractorGroupNameMap.get('Equipment_Provider__c'),new Set<Id>());
                            }
                            groupNameToAccountMap.get(contractorGroupNameMap.get('Equipment_Provider__c')).add(selectedAccount.Id);
                        } 
                        if(selectedAccount.SSP__c){
                            if(!groupNameToAccountMap.containsKey(contractorGroupNameMap.get('SSP__c'))){
                                groupNameToAccountMap.put(contractorGroupNameMap.get('SSP__c'),new Set<Id>());
                            }
                            groupNameToAccountMap.get(contractorGroupNameMap.get('SSP__c')).add(selectedAccount.Id);
                        } 
                        if(selectedAccount.Interpreter__c){
                            if(!groupNameToAccountMap.containsKey(contractorGroupNameMap.get('Interpreter__c'))){
                                groupNameToAccountMap.put(contractorGroupNameMap.get('Interpreter__c'),new Set<Id>());
                            }
                            groupNameToAccountMap.get(contractorGroupNameMap.get('Interpreter__c')).add(selectedAccount.Id);
                        } 
                    }
                }
            }
        }
        
        if(groupNameToAccountMap.values().size()>0){
            NC_SendBulkEmail.semdEmailToGroups(groupNameToAccountMap, 'Vendor_Information_Updated');
        }
    }

    public static Boolean avoidRecursion = false;

    /*
    *********************************************************
    @Method Name    : unfreezeRecord
    @description    : Change all Vendor update in progress records to previous status
    @param          : List<Account> newList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void unfreezeRecord(List<Account> newList, Map<Id,Account> oldMap) {
        
        if(!avoidRecursion) {
            avoidRecursion = true;
            List<Id> accountIds = new List<Id>();
            List<Account> accountList = new List<Account>();
            List<SObject> sObjectList = new List<SObject>();
            for(Account selectedAccount : newList) {
                //oldMap.get(selectedAccount.Id).Status__c == selectedAccount.Status__c && selectedAccount.Status__c == 'Vendor Update In Progress'
                if(oldMap.get(selectedAccount.Id).NCAS_Status__c != selectedAccount.NCAS_Status__c
                && selectedAccount.NCAS_Status__c == 'Y – record in NCAS') {
                        Account acc = new Account();
                        acc.Id = selectedAccount.Id;
                        acc.Status__c = String.isNotBlank(selectedAccount.Previous_Status__c) ? selectedAccount.Previous_Status__c : selectedAccount.Status__c;
                        accountList.add(acc);

                        accountIds.add(selectedAccount.Id);
                    }
            }
            SObjectAccessDecision sobjdecision =  SecurityLibrary.getAccessibleData('Account', accountList, 'update', true, 'NC_AccountTriggerHandler','unfreezeRecord');
            update sobjdecision.getRecords();
            if(accountIds.size() > 0) {
                Map<Id, String> authorizationStatusMap = new Map<Id, String>();
                Map<Id, String> staffReqStatusMap = new Map<Id, String>();
                for(Invoice__c invoice: [SELECT Status__c, Previous_Status__c, Authorization__r.Status__c, Authorization__r.Previous_Status__c, Authorization__r.Staffing_User_Request__r.Status__c, Authorization__r.Staffing_User_Request__r.Previous_Status__c FROM Invoice__c WHERE Authorization__r.Vendor__c IN: accountIds WITH SECURITY_ENFORCED]) {
                    
                    if(invoice.Status__c == 'Vendor Update In Progress') {
                        Invoice__c newInv = new Invoice__c();
                        newInv.id = invoice.id;
                        newInv.Status__c = invoice.Previous_Status__c;
                        sObjectList.add(newInv);
                    }
                    
                    if(invoice.Authorization__c != null && invoice.Authorization__r.Status__c == 'Vendor Update In Progress') {
                        authorizationStatusMap.put(invoice.Authorization__c, invoice.Authorization__r.Previous_Status__c);
                        
                        if(invoice.Authorization__r.Staffing_User_Request__c != null
                            && invoice.Authorization__r.Staffing_User_Request__r.Status__c == 'Vendor Update In Progress') {
                            staffReqStatusMap.put(invoice.Authorization__r.Staffing_User_Request__c, invoice.Authorization__r.Staffing_User_Request__r.Previous_Status__c);
                        }
                    }
                }

                for(Authorization__c authRecord: [SELECT Previous_Status__c, Staffing_User_Request__r.Status__c, Staffing_User_Request__r.Previous_Status__c, (SELECT id FROM Invoices__r) FROM Authorization__c WHERE Vendor__r.Id IN: accountIds WITH SECURITY_ENFORCED]) {
                    if(authRecord.Invoices__r.size () == 0) {
                        authorizationStatusMap.put(authRecord.Id, authRecord.Previous_Status__c);
                    }
                    if(authRecord.Staffing_User_Request__c != null 
                        && authRecord.Staffing_User_Request__r.Status__c != 'Vendor Approved'
                        && authRecord.Staffing_User_Request__r.Status__c != 'Rejected') {
                        staffReqStatusMap.put(authRecord.Staffing_User_Request__c, authRecord.Staffing_User_Request__r.Previous_Status__c);
                    }
                }
    
                for(Staffing_User_Request__c staffReqRecord: [SELECT Previous_Status__c, (SELECT id FROM Authorizations__r) FROM Staffing_User_Request__c WHERE Account__r.Id IN: accountIds AND Status__c NOT IN ('Vendor Approved','Rejected') WITH SECURITY_ENFORCED]) {
                    if(staffReqRecord.Authorizations__r.size () == 0) {
                        staffReqStatusMap.put(staffReqRecord.Id, staffReqRecord.Previous_Status__c);
                    }
                }

                for(Id authId: authorizationStatusMap.keySet()) {
                    Authorization__c auth = new Authorization__c();
                    auth.id = authId;
                    auth.Status__c = authorizationStatusMap.get(authId);
                    sObjectList.add(auth);
                }

                for(Id staffReqId: staffReqStatusMap.keySet()) {
                    Staffing_User_Request__c newReq = new Staffing_User_Request__c();
                    newReq.id = staffReqId;
                    newReq.Status__c = staffReqStatusMap.get(staffReqId);
                    sObjectList.add(newReq);
                }

                
                if(sObjectList.size() > 0) {
                    SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('SObject', sObjectList, 'update', true,'NC_AccountTriggerHandler','unfreezeRecord');
                    update decision.getRecords();
                    //update sObjectList;
                }
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : previousRecordInactiveDuplicateRecordApproved
    @description    : Clone record in case of Vendor Error X
    @param          : List<Account> newList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void previousRecordInactiveDuplicateRecordApproved(List<Account> newList, Map<Id,Account> oldMap){
    list<Account> cloneForOldAccount = new List<Account>();
    list<Account> activeFalse = new List<Account>();
  //  Set<id> triggerIds = oldMap.keySet();
        
        for(Account selectedAccount : newList){
            List<Schema.FieldSetMember> fieldSetMemberList =  NC_Utility.getFieldSet('Account','Duplicate_Fields');
            Boolean flag = false;
            if(oldMap != Null 
            && vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)
            && selectedAccount.Status__c == 'Approved' && selectedAccount.Active__c)
            {
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    if( oldMap.get(selectedAccount.Id).get(fieldSetMemberObj.getFieldPath()) != selectedAccount.get(fieldSetMemberObj.getFieldPath())) {
                        flag = true;
                        break;
                    }
                }
            }

            Boolean groupUpdateRequired = false;
            if(oldMap != null 
            && vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)
            && selectedAccount.MM102_error_reason__c != null
            && selectedAccount.Status__c == 'Pending Approval'
            && selectedAccount.NCAS_Status__c == null
            && !selectedAccount.GroupNumberUpdated__c) {
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    if( oldMap.get(selectedAccount.Id).get(fieldSetMemberObj.getFieldPath()) != selectedAccount.get(fieldSetMemberObj.getFieldPath())) {
                        groupUpdateRequired = true;
                        selectedAccount.GroupNumberUpdated__c = true;
                        break;
                    }
                }
            }

            Boolean isVendorErrorX = false;
            if(oldMap != null 
            && vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)
            && oldMap.get(selectedAccount.id).MM102_error_reason__c != selectedAccount.MM102_error_reason__c
            && selectedAccount.MM102_error_reason__c != null
            && selectedAccount.NCAS_Status__c == 'X - Error') {
                isVendorErrorX = true;
                isSubmittedAndErrorVendor = true;
            }

            if(flag || groupUpdateRequired){
                if(selectedAccount.Group_Number__c != null){
                    List<String> groupCodeList = NC_Constant.groupCodeList;
                    if(groupCodeList.indexOf(selectedAccount.Group_Number__c) != -1) {
                        selectedAccount.Group_Number__c = groupCodeList[groupCodeList.indexOf(selectedAccount.Group_Number__c)  + 1];
                    }
                }else{
                    selectedAccount.Group_Number__c = '00';
                }
            }

            if(flag || isVendorErrorX) {
                Account oldRecord = oldMap.get(selectedAccount.Id);
                Account newRecord = oldRecord.clone(false,false,false,false);
                newRecord.Cloned_For__c = selectedAccount.Id;
                newRecord.ShippingCountry = null;
                newRecord.ShippingState = null;
                //newRecord.NCAS_Status__c = null;
                // newRecord.NCAS_Status__c = oldRecord.NCAS_Status__c;
               // newRecord.NCAS_Status__c = 'N – record not in NCAS';
               if(isVendorErrorX) {
                    newRecord.MM102_error_reason__c = selectedAccount.MM102_error_reason__c;
               } else {
                    newRecord.Status__c = 'Inactive';
               }
                newRecord.Sent_to_NCAS__c = false;
                newRecord.Active__c = false;
                newRecord.Update_In_Progress__c = true;
                // If(newRecord.NCAS_Status__c == 'Y – record in NCAS'){
                //     newRecord.Active__c = false;
                // }
                cloneForOldAccount.add(newRecord);

                if(isVendorErrorX) {
                    selectedAccount.Error__c = null;
                    selectedAccount.NCAS_Status__c = null;
                    selectedAccount.GroupNumberUpdated__c = false;
                    selectedAccount.Status__c = 'Pending Approval';
                } else {
                    selectedAccount.Active__c = false;
                    selectedAccount.NCAS_Status__c = null;
                    selectedAccount.Sent_to_NCAS__c = true;
                }
            }
        }

            if(cloneForOldAccount.size()>0){
                //Cannot provide CRUD check as it is getting used in user having edit access
                //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Account', cloneForOldAccount, 'insert', true,'NC_AccountTriggerHandler','previousRecordInactiveDuplicateRecordApproved');
                //insert decision.getRecords();
                insert cloneForOldAccount;
            }
    }
    
    /*
    *********************************************************
    @Method Name    : timeValidation
    @description    : Field lock validation after some time and vendor update in progress validation
    @param          : List<Account> newAccountList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void timeValidation(List<Account> newAccountList, Map<Id,Account> oldMap) {
        list<Account> cloneForOldAccount = new List<Account>();
        list<Account> activeFalse = new List<Account>();
        List<Schema.FieldSetMember> fieldSetMemberList =  NC_Utility.getFieldSet('Account','Duplicate_Fields');
        //  Set<id> triggerIds = oldMap.keySet();
        if(System.now().hour() >= 17 || Test.isRunningTest()) {
            for(Account selectedAccount : newAccountList){
                String errorMessageFields = '';
                Boolean flag = false;
                if(oldMap != Null && selectedAccount.Active__c && selectedAccount.Status__c == 'Approved' && vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)) {
                    for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                        Schema.DescribeFieldResult describeFiledResult = fieldSetMemberObj.getSObjectField().getDescribe();
                        if( oldMap.get(selectedAccount.Id).get(fieldSetMemberObj.getFieldPath()) != selectedAccount.get(fieldSetMemberObj.getFieldPath())) {
                            errorMessageFields += errorMessageFields == '' ? describeFiledResult.getName() : ', ' + describeFiledResult.getName();
                        }
                    }
                }
                if(errorMessageFields != '') {
                    selectedAccount.addError('Following fields are can\'t be modified after 5 PM (' + errorMessageFields + ')');
                }
            }
        }
        
        for(Account selectedAccount : newAccountList){
            String errorMessageFields = '';
            Boolean flag = false;
            if(oldMap != Null && !selectedAccount.Active__c && selectedAccount.Status__c == 'Vendor Update In Progress' && selectedAccount.NCAS_Status__c == null && vendorTrainerTypeSet.contains(selectedAccount.RecordTypeId)) {
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    Schema.DescribeFieldResult describeFiledResult = fieldSetMemberObj.getSObjectField().getDescribe();
                    if(oldMap.get(selectedAccount.Id).get(fieldSetMemberObj.getFieldPath()) != selectedAccount.get(fieldSetMemberObj.getFieldPath())) {
                        flag = true;
                    }
                }
            }
            if(flag) {
                selectedAccount.addError('Vendor is locked as Vendor Update in progress');
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateVendorInProgress
    @description    : Update status vendor in progess if record is picked up by NCAS
    @param          : List<Account> newAccountList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateVendorInProgress(List<Account> newAccountList, Map<Id,Account> oldMap) {
        Set<Id> vendorInProgressAccounts = new Set<Id>();
        
        for(Account selectedAccount : newAccountList) {
            
            if(selectedAccount.Status__c == 'Vendor Update In Progress' && selectedAccount.NCAS_Status__c == null) {
                selectedAccount.addError('Update NCAS Status to proceed');
            }
            
            if(oldMap != null
            && oldMap.get(selectedAccount.Id).Sent_to_NCAS__c != selectedAccount.Sent_to_NCAS__c
            && selectedAccount.Sent_to_NCAS__c == false
            && selectedAccount.Active__c == false
            && selectedAccount.Status__c == 'Approved'
            && selectedAccount.NCAS_Status__c == null) {
                vendorInProgressAccounts.add(selectedAccount.Id);
            }
        }

        if(vendorInProgressAccounts.size() > 0) {
            List<SObject> sObjectList = new List<SObject>();
            List<Invoice__c> invList = new List<Invoice__c>();
            Map<Id, String> authorizationStatusMap = new Map<Id, String>();
            Map<Id, String> staffReqStatusMap = new Map<Id, String>();

            for(Invoice__c invoice: [SELECT Status__c, Sent_to_NCAS__c, Authorization__r.Status__c, Authorization__r.Staffing_User_Request__r.Status__c FROM Invoice__c WHERE Authorization__r.Vendor__c IN: vendorInProgressAccounts AND Status__c NOT IN ('Paid', 'Canceled', 'Submitted and Error', 'Vendor Update In Progress', 'Pending Cancellation') WITH SECURITY_ENFORCED]) {
                Boolean isApproved = false;
                if(invoice.Status__c == 'Approved' && invoice.Sent_to_NCAS__c == false) {
                    isApproved = true;
                }
                if(!isApproved) {
                    Invoice__c newInv = new Invoice__c();
                    newInv.id = invoice.id;
                    newInv.Previous_Status__c = invoice.Status__c;
                    newInv.Status__c = 'Vendor Update In Progress';
                    invList.add(newInv);
                }
                
                if(invoice.Authorization__c != null && !isApproved) {
                    if(invoice.Authorization__r.Status__c != 'Cancelled') {
	                    authorizationStatusMap.put(invoice.Authorization__c, invoice.Authorization__r.Status__c);
                    }

                    if(invoice.Authorization__r.Staffing_User_Request__r.Status__c != 'Vendor Approved'
                        && invoice.Authorization__r.Staffing_User_Request__r.Status__c != 'Rejected'
                        && invoice.Authorization__r.Staffing_User_Request__c != null) {
                        staffReqStatusMap.put(invoice.Authorization__r.Staffing_User_Request__c, invoice.Authorization__r.Staffing_User_Request__r.Status__c);
                    }
                }
            }

            for(Authorization__c authRecord: [SELECT Status__c, Staffing_User_Request__r.Status__c, (SELECT id FROM Invoices__r) FROM Authorization__c WHERE Vendor__r.Id IN: vendorInProgressAccounts WITH SECURITY_ENFORCED]) {
                if(authRecord.Invoices__r.size () == 0) {
                    authorizationStatusMap.put(authRecord.Id, authRecord.Status__c);
                }
                if(authRecord.Staffing_User_Request__c != null 
                    && authRecord.Staffing_User_Request__r.Status__c != 'Vendor Approved'
                    && authRecord.Staffing_User_Request__r.Status__c != 'Rejected') {
                    staffReqStatusMap.put(authRecord.Staffing_User_Request__c, authRecord.Staffing_User_Request__r.Status__c);
                }
            }

            for(Staffing_User_Request__c staffReqRecord: [SELECT Status__c, (SELECT id FROM Authorizations__r) FROM Staffing_User_Request__c WHERE Account__r.Id IN: vendorInProgressAccounts AND Status__c NOT IN ('Vendor Approved','Rejected') WITH SECURITY_ENFORCED]) {
                if(staffReqRecord.Authorizations__r.size () == 0) {
                    staffReqStatusMap.put(staffReqRecord.Id, staffReqRecord.Status__c);
                }
            }

            for(Id authId: authorizationStatusMap.keySet()) {
                Authorization__c auth = new Authorization__c();
                auth.id = authId;
                auth.Previous_Status__c = authorizationStatusMap.get(authId);
                auth.Status__c = 'Vendor Update In Progress';
                sObjectList.add(auth);
            }

            for(Id staffReqId: staffReqStatusMap.keySet()) {
                Staffing_User_Request__c newReq = new Staffing_User_Request__c();
                newReq.id = staffReqId;
                newReq.Previous_Status__c = staffReqStatusMap.get(staffReqId);
                newReq.Status__c = 'Vendor Update In Progress';
                sObjectList.add(newReq);
            }

            if(sObjectList.size() > 0) {
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('SObject', sObjectList, 'update', true,'NC_AccountTriggerHandler','updateVendorInProgress');
                update decision.getRecords();
                
                SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Invoice__c', invList, 'update', true,'NC_AccountTriggerHandler','updateVendorInProgress');
                update decision1.getRecords();
            }
            
            for(Account accRecord: newAccountList) {
                if(vendorInProgressAccounts.contains(accRecord.Id)) {
                    accRecord.Previous_Status__c = accRecord.Status__c;
                    accRecord.Status__c = 'Vendor Update In Progress';
                }
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateNCASErrorN
    @description    : Update status to NCAS Error N and Error N validations
    @param          : List<Account> newList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateNCASErrorN(List<Account> newList, Map<Id,Account> oldMap) {
        for(Account accountRecord: newList) {
            if(oldMap != NULL 
            && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
            && oldMap.get(accountRecord.Id).NCAS_Status__c != accountRecord.NCAS_Status__c
            && accountRecord.NCAS_Status__c == 'N – record not in NCAS') {
                accountRecord.MM102_error_reason__c = null;
                accountRecord.Action_Taken_to_resolve__c = null;
                accountRecord.Action_Taken_to_resolve_Required__c = false;
                accountRecord.Status__c = 'Submitted and Rejected';
            }

            if(oldMap != NULL 
            && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
            && oldMap.get(accountRecord.Id).Status__c == 'Submitted and Rejected'
            && accountRecord.Status__c == 'Pending Approval'
            && accountRecord.MM102_error_reason__c == null) {
                accountRecord.addError('MM102 Error Reason required before approval');
            }
            
            if(oldMap != NULL 
            && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
            && accountRecord.NCAS_Status__c == 'N – record not in NCAS'
            && accountRecord.Action_Taken_to_resolve_Required__c
            && accountRecord.Action_Taken_to_resolve__c == null) {
                accountRecord.addError('Action Taken to resolve is required before approval');
            }

            if(oldMap != NULL 
            && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
            && accountRecord.NCAS_Status__c == 'N – record not in NCAS'
            && accountRecord.Status__c == 'Approved') {
                accountRecord.NCAS_Status__c = null;
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateNCASErrorX
    @description    : NCAS Error X validations
    @param          : List<Account> newList, Map<Id,Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateNCASErrorX(List<Account> newList, Map<Id,Account> oldMap) {
        for(Account accountRecord: newList) {
            if(oldMap != NULL 
            && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
            && oldMap.get(accountRecord.Id).NCAS_Status__c != accountRecord.NCAS_Status__c
            && accountRecord.NCAS_Status__c == 'X - Error') {
                accountRecord.MM102_error_reason__c = null;
                accountRecord.Action_Taken_to_resolve__c = null;
                accountRecord.Action_Taken_to_resolve_Required__c = false;
                accountRecord.Status__c = 'Submitted and Error';
            }

            if(oldMap != NULL 
            && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
            && oldMap.get(accountRecord.Id).Status__c == 'Submitted and Error'
            && accountRecord.Status__c == 'Pending Approval'
            && accountRecord.MM102_error_reason__c == null) {
                accountRecord.addError('MM102 Error Reason required before approval');
            }

            if(oldMap != NULL 
            && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
            && accountRecord.MM102_error_reason__c != null
            && accountRecord.Action_Taken_to_resolve_Required__c
            && accountRecord.Action_Taken_to_resolve__c == null) {
                accountRecord.addError('Action Taken to resolve is required before approval');
            }

            if(oldMap != NULL 
            && vendorTrainerTypeSet.contains(accountRecord.recordTypeId)
            && accountRecord.NCAS_Status__c == 'X - Error'
            && accountRecord.Status__c == 'Approved') {
                accountRecord.NCAS_Status__c = null;
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : mapPhysicalAndMailingAddressToRemitAddress
    @description    : Populate Physical address to Remit address 
    @param          : List<Account> newList
    @return         : void
    ********************************************************
    */
    public static void mapPhysicalAndMailingAddressToRemitAddress(List<Account> newList){
 
        for(Account acc : newList) {
            if(acc.Same_As_Physical_Address__c == true && acc.Same_As_Mailing_address__c == true){
                acc.addError('Select only one: Same as Physical Address or Same as Mailing Address');
            }
            if(acc.Same_As_Physical_Address__c){
                acc.Remit_to_Addr_Ln_1__c = acc.BillingStreet;
                acc.Remit_to_Addr_Ln_2__c = acc.BillingCity;
                acc.Remit_to_State_Cd__c = acc.BillingStateCode;
                acc.Remit_to_Postal_Cd__c = acc.BillingPostalCode;
                acc.Remit_to_Addr_Ln_3__c = acc.BillingCountry;
            }
            if(acc.Same_As_Mailing_address__c){
                acc.Remit_to_Addr_Ln_1__c = acc.ShippingStreet;
                acc.Remit_to_Addr_Ln_2__c = acc.ShippingCity;
                acc.Remit_to_State_Cd__c = acc.ShippingStateCode;
                acc.Remit_to_Postal_Cd__c = acc.ShippingPostalCode;
                acc.Remit_to_Addr_Ln_3__c = acc.ShippingCountry;
            }
        }  
    }
    
    /*
    *********************************************************
    @Method Name    : mapPhysicalToMailingAddress
    @description    : Populate Physical address to Mailing address 
    @param          : List<Account> newList
    @return         : void
    ********************************************************
    */
    public static void mapPhysicalToMailingAddress(List<Account> newList){
 
        for(Account acc : newList) {
    
            if(acc.Same_As_Physical_Address_to_Mailing_Addr__c){
                acc.ShippingCountry = acc.BillingCountry;
                acc.ShippingStreet = acc.BillingStreet;
                acc.ShippingState = acc.BillingState;
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingStateCode = acc.BillingStateCode;
                acc.ShippingPostalCode = acc.BillingPostalCode;
                
            }
        }  
    }

    /*
    *********************************************************
    @Method Name    : updateVendorActive
    @description    : Update Vendor to active and its validations
    @param          : List<Account> newList, Map<Id, Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateVendorActive(List<Account> newList, Map<Id, Account> oldMap){
        for(Account accRecord: newList) {
            if(accRecord.recordTypeId == accountVendorRecordTypeId
            && accRecord.Equipment_Provider__c
            && accRecord.Status__c != oldMap.get(accRecord.id).Status__c
            && accRecord.Status__c == 'Approved') {
                accRecord.Approved_Equipment_Provider__c = true;
            }
            if(vendorTrainerTypeSet.contains(accRecord.recordTypeId)
            && accRecord.NCAS_Status__c == 'Y – record in NCAS' 
            && (accRecord.Status__c == 'Approved' || accRecord.Status__c == 'Vendor Update In Progress')){
                accRecord.Active__c = true;
            }
             if(oldMap != NULL 
                && !isSubmittedAndErrorVendor
                && oldMap.get(accRecord.Id).Status__c == 'Submitted and Error'
               	&& oldMap.get(accRecord.Id).MM102_error_reason__c != null
                && oldMap.get(accRecord.Id).NCAS_Status__c == 'X - Error'){
                    accRecord.addError('Cannot update the record as the status is Submitted and Error');
                }
        }
    }

    /*
    *********************************************************
    @Method Name    : restrictUpdateIsVendorPortal
    @description    : Update is vendor on portal
    @param          : List<Account> newList, Map<Id, Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void restrictUpdateIsVendorPortal(List<Account> newList, Map<Id, Account> oldMap){
        List<Account> accountList = new List<Account>();
        List<String> statusList =new List<String>{'Approved','Denied','Closed'};
        Id accountTrainerRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'NDBEDP_Trainer');
        Id accountAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'Assessor');
        Id caseNDBEDPRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case', 'NDBEDP');
        Id caseNDBEDPFollowUpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case', 'NDBEDP_Follow_up');
        Id caseNDBEDPAdditionalTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case', 'NDBEDP_Additional_Training');
        for(Account accountValue:newList){
            if(accountValue.Is_Vendor_on_Portal__c && oldMap.get(accountValue.Id).Is_Vendor_on_Portal__c != accountValue.Is_Vendor_on_Portal__c && (accountValue.RecordTypeId == accountTrainerRecordTypeId || accountValue.RecordTypeId == accountAssessorRecordTypeId)){
                accountList.add(accountValue);
            }
        }
        // for(Case caseValue:[SELECT Id, External_Assessor__c,NDBEDP_Trainer__c,Status,RecordTypeId FROM Case WHERE Status NOT IN:statusList]){
        //    if(caseValue.RecordTypeId == caseNDBEDPFollowUpRecordTypeId ||caseValue.RecordTypeId == caseNDBEDPRecordTypeId ){
        //     trigger.newmap.get(caseValue.External_Assessor__r.Id).addError('Cannot update field as the NDBEDP/NDBEDP Service Request is InProgress');
        //    }
        //    if(caseValue.RecordTypeId == caseNDBEDPAdditionalTrainingRecordTypeId ){
        //     trigger.newmap.get(caseValue.NDBEDP_Trainer__r.Id).addError('Cannot update field as the NDBEDP/NDBEDP Service Request is InProgress');
        //    }
        for(Account accountValue :[SELECT Id,(SELECT Id FROM Requests1__r WHERE Status NOT IN:statusList),(SELECT Id FROM Requests2__r WHERE Status NOT IN:statusList) FROM Account WHERE Id IN :accountList]){
            if(accountValue.Requests1__r.size()>0 || accountValue.Requests2__r.size()>0 ){
            trigger.newmap.get(accountValue.Id).addError('Cannot update field as the NDBEDP/NDBEDP Service Request is InProgress');
            }
        }
       }
       
    /*
    *********************************************************
    @Method Name    : updateTheEmailField
    @description    : validate is vendor on portal
    @param          : List<Account> newList, Map<Id, Account> oldMap
    @return         : void
    ********************************************************
    */
       public static void updateTheEmailField(List<Account> newList, Map<Id, Account> oldMap){
        Id accountTrainerRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'NDBEDP_Trainer');
        Id accountAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'Assessor');
        for(Account acc:newList){
            if((acc.RecordTypeId == accountAssessorRecordTypeId || acc.RecordTypeId == accountTrainerRecordTypeId ) && acc.Email__c == null && acc.Is_Vendor_on_Portal__c == true ){
                trigger.newmap.get(acc.Id).addError('Please Provide the Email Adddress.');
               
            }
            if((acc.RecordTypeId == accountAssessorRecordTypeId || acc.RecordTypeId == accountTrainerRecordTypeId ) && acc.Last_Name__c == null && acc.Is_Vendor_on_Portal__c == true ){
                trigger.newmap.get(acc.Id).addError('Please Provide the Last Name');
               
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateIsVendorPortal
    @description    : Create portal user if is vendor on portal selected
    @param          : List<Account> newList, Map<Id, Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateIsVendorPortal(List<Account> newList, Map<Id, Account> oldMap){
        Id accountTrainerRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'NDBEDP_Trainer');
        Id accountAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'Assessor');
        List<Contact> insertContactList = new List<Contact>();
        List<Id> accountIdList = new List<Id>();
        for(Account accountValue:newList){
            if(accountValue.Is_Vendor_on_Portal__c && (oldMap.get(accountValue.Id).Status__c =='Approved'||accountValue.Status__c =='Approved') && (oldMap.get(accountValue.Id).Active__c ||accountValue.Active__c) && oldMap.get(accountValue.Id).Is_Vendor_on_Portal__c != accountValue.Is_Vendor_on_Portal__c && (accountValue.RecordTypeId == accountTrainerRecordTypeId || accountValue.RecordTypeId == accountAssessorRecordTypeId )){
                accountIdList.add(accountValue.Id);
            }
        }
        for(Account account:[SELECT Id,First_Name__c,Last_Name__c ,Email__c,Is_Vendor_on_Portal__c,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIdList AND Email__c!=null WITH SECURITY_ENFORCED FOR UPDATE]){
            if(account.Contacts.size()==0 ){
                Contact con = new Contact();
                con.AccountId = account.Id;
                con.LastName = account.Last_Name__c;
                con.FirstName = account.First_Name__c;
                con.Hearing_Disability__c = 'Deaf';
                con.Email =account.Email__c;
                insertContactList.add(con);
            }
          }
    
            if(insertContactList.size()>0){
              //Insert insertContactList;
              SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Contact', insertContactList, 'insert', true,'NC_AccountTriggerHandler','updateIsVendorPortal');
              insert objectDecision.getRecords();
            }
          List<Id> contactstCommunityUser = new List<Id>();
          List<Contact> lContacts = [SELECT Id,AccountId FROM Contact WHERE AccountId IN :accountIdList WITH SECURITY_ENFORCED FOR UPDATE]; 
        for(User use :[SELECT Id,Contact.Id,Name,Email FROM User WHERE ContactId IN :lContacts]){
            contactstCommunityUser.add(use.Contact.Id);
           }
        //if(contactstCommunityUser)
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='NDBEDP Assessor' Limit 1];
        List<User> InsertUserList = new List<User>();
        for(Contact con :[SELECT Id,AccountId,LastName,FirstName,Email FROM Contact WHERE AccountId IN :accountIdList WITH SECURITY_ENFORCED FOR UPDATE]){
            if(!contactstCommunityUser.contains(con.Id)){
                User user1 = new User(
                    UserName = con.Email+Integer.valueOf(Math.random()*100),
                    FirstName = con.FirstName,
                    LastName = con.LastName,
                    Alias = Integer.valueOf(Math.random()*100)+'',
                    email = con.Email,
                     ContactId = con.Id,
                     ProfileId = portalProfile.Id,
                     EmailEncodingKey = 'UTF-8',
                     CommunityNickname =  con.FirstName+con.LastName+Integer.valueOf(Math.random()*100)+'',
                     TimeZoneSidKey = 'America/Los_Angeles',
                     LocaleSidKey = 'en_US',
                     LanguageLocaleKey = 'en_US'
                );
                InsertUserList.add(user1);
            }
        }
        if(InsertUserList.size()>0){
           //Insert InsertUserList;
           SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('User', InsertUserList, 'insert', true,'NC_AccountTriggerHandler','updateIsVendorPortal');
           insert objectDecision.getRecords();
        }    
    }

    /*
    *********************************************************
    @Method Name    : updateStatusFieldForActive
    @description    : Update status to Approved if record is Active
    @param          : List<Account> newList, Map<Id, Account> oldMap
    @return         : void
    ********************************************************
    */
        public static void updateStatusFieldForActive(List<Account> newList, Map<Id, Account> oldMap){
        Id accountAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'Assessor');
        for(Account acc:newList){
            if(acc.Active__c==true && acc.Active__c != oldMap.get(acc.Id).Active__c && acc.RecordTypeId == accountAssessorRecordTypeId){
                acc.Status__c = 'Approved';
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : validateNDBEDPTrainer
    @description    : Perform NDBEDBP trainer validations
    @param          : List<Account> newList, Map<Id, Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateNDBEDPTrainer(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accountSet = new Set<Id>();
        for(Account accRecord: newList){
            if(accRecord.recordTypeId == accountTrainerRecordTypeId
            && oldMap.get(accRecord.id).Status__c == 'Pending Documents'
            && accRecord.Status__c == 'Pending Approval') {
                accountSet.add(accRecord.id);
            }
        }
        if(accountSet.size() > 0) {
            List<User> ndbedpUserList = [SELECT id FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND IsActive = true];
            for(Account accRecord: newList){
                if(accountSet.contains(accRecord.id)) {
                    if(!ndbedpUserList.isEmpty()) {
                        accRecord.NDBEDP_Admin__c = ndbedpUserList[0].id;
                    } else {
                        accRecord.addError('No active NDBEDP Administrator is found');
                    }
                }
            }
        }
    }

    // public static void updateTheEmailField(List<Account> newList, Map<Id, Account> oldMap){
    //     Id accountTrainerRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'NDBEDP_Trainer');
    //     Id accountAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'Assessor');
    //     for(Account acc:newList){
    //         if((acc.RecordTypeId == accountAssessorRecordTypeId || acc.RecordTypeId == accountTrainerRecordTypeId ) && acc.Email__c == null && acc.Is_Vendor_on_Portal__c ){
    //             trigger.newmap.get(acc.Id).addError('Please Provide the Email Adddress');
    //         }
    //     }
    // }
    /*
    *********************************************************
    @Method Name    : validateVendorStatus
    @description    : Validate Vendor status so that end user should be able change to valid status
    @param          : List<Account> newList, Map<Id, Account> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateVendorStatus(List<Account> newList, Map<Id, Account> oldMap) {
        List<String> accountIds = new List<String>();
        Id vendorTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        Id ndbedpTrainerTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NDBEDP_Trainer').getRecordTypeId();
        
        for(Account accRecord: newList) {
            if((accRecord.recordTypeId == vendorTypeId || accRecord.recordTypeId == ndbedpTrainerTypeId)
               && accRecord.Status__c != oldMap.get(accRecord.id).Status__c) {
                accountIds.add(accRecord.id);
            }
            if(accRecord.recordTypeId == vendorTypeId
               && accRecord.Equipment_Provider__c == false
               && accRecord.Status__c != oldMap.get(accRecord.id).Status__c
               && oldMap.get(accRecord.id).Status__c == null
               && accRecord.Status__c != 'Pending Documents') {
                //accRecord.addError('Invalid Status. Change status to Pending Documents to proceed.');
            }
            if(accRecord.recordTypeId == ndbedpTrainerTypeId
               && accRecord.Status__c != oldMap.get(accRecord.id).Status__c
               && oldMap.get(accRecord.id).Status__c == 'New'
               && accRecord.Status__c != 'Pending Documents') {
                accRecord.addError('Invalid Status. Change status to Pending Documents to proceed.');
            }
            if((accRecord.recordTypeId == vendorTypeId || accRecord.recordTypeId == ndbedpTrainerTypeId)
               && accRecord.Equipment_Provider__c == false
               && accRecord.Status__c != 'Pending Documents'
               && accRecord.Status__c != oldMap.get(accRecord.id).Status__c
               && (oldMap.get(accRecord.id).Status__c == 'Pending Documents' || oldMap.get(accRecord.id).Status__c == null)
               && accRecord.Submit_for_Approval__c == false) {
                accRecord.addError('Click Submit for Approval to proceed');
            }
            if((accRecord.recordTypeId == vendorTypeId || accRecord.recordTypeId == ndbedpTrainerTypeId)
               && accRecord.Status__c != oldMap.get(accRecord.id).Status__c
               && oldMap.get(accRecord.id).Status__c == 'Pending Approval'
               && accRecord.Submit_for_Approval__c == true) {
                accRecord.Submit_for_Approval__c = false;
            }
        }
        if(accountIds.size() > 0) {
            List<ProcessInstance> processInstanceList = [Select Id From ProcessInstance WHERE TargetObjectId IN:accountIds AND Status = 'Pending'];
            if(!processInstanceList.isEmpty()) {
                Trigger.newMap.get(accountIds[0]).addError('Click Approve or Reject to proceed');
            }
        }
    }
}