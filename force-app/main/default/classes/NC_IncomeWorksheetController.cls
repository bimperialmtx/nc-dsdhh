/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_IncomeWorksheetController {
    
    /*
    *********************************************************
    @Method Name    : fetchContactData
    @description    : Fetch contact and family details data
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> fetchContactData(Id recordId){
        //recordId is Of Request
        Boolean showErroMessage = false;
        Boolean alreadyFilled = false;
        Map<String, Object> result = new Map<String, Object>();
        Set<String> docSet = new Set<String>{'Work First','Medicaid','SSI',
            'CSHS (Children\'s’ Special Health Services)','Health Choice for Children',
            'Section 8 Housing Choice Vouchers','Food Stamps'}; 
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        Case caseRecord = [SELECT id, RecordTypeId, contactId,Status, Proof_of_Income_Provided_By__c, Equipment_Types__c FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED];
        Contact contactRecord = [SELECT id, Marital_Status__c, Proof_of_Income_Provided_By__c FROM Contact WHERE Id =: caseRecord.contactId WITH SECURITY_ENFORCED];
        List<Family_Details__c> familyDetailsList = [SELECT Id, Contact__c, Request__c, Name__c, Age__c, Relationship__c, Alimony__c, AmeriCorps_Stipends__c, Annuities__c, Armed_Forces_pay__c, Cherokee_Tribal_per_captia_Income_paid_t__c, Child_support__c, Gross_salary_and_wages__c, On_the_Job_training__c, Rental_Income__c, Retirement_Pension__c, Social_Security__c, Tobacco_buy_out_payments__c, Unemployment__c, Veteran_Administration_Benefits__c, Work_Release_Payments__c, Worker_s_Compensation_payments__c, Adjustments__c FROM Family_Details__c WHERE Request__c =: recordId WITH SECURITY_ENFORCED];
        List<FamilyDetailsWrapper> FamilyDetailsWrapperList = new  List<FamilyDetailsWrapper>();
        String maritalStatus = contactRecord.Marital_Status__c != NULL ? contactRecord.Marital_Status__c : '-None-';
        String proofOfIncomeProvidedBy = contactRecord.Proof_of_Income_Provided_By__c != NULL ? contactRecord.Proof_of_Income_Provided_By__c : '-None-';
        /*
        if(FamilyDetailsWrapperList.size()>0){
           alreadyFilled = true; 
        }else if((caseRecord.status != 'Submitted' && caseRecord.status != 'In Progress'
                  && caseRecord.status != 'Pending Documents' && caseRecord.status != 'Pending Condition of Acceptance') 
                  || caseRecord.Equipment_Types__c == 'Weather Radio'
                  || caseRecord.Proof_of_Income_Provided_By__c == 'Work First' || caseRecord.Proof_of_Income_Provided_By__c == 'Medicaid'  
                  || caseRecord.Proof_of_Income_Provided_By__c == 'SSI' || caseRecord.Proof_of_Income_Provided_By__c == 'CSHS (Children\'s’ Special Health Services)'
                  || caseRecord.Proof_of_Income_Provided_By__c == 'Health Choice for Children' || caseRecord.Proof_of_Income_Provided_By__c == 'Section 8 Housing Choice Vouchers'
                  || caseRecord.Proof_of_Income_Provided_By__c == 'Food Stamps' ){
           showErroMessage = true;
        }*/
        if(FamilyDetailsWrapperList.size()>0){
           alreadyFilled = true; 
        }else if(caseRecord.recordTypeId != ndbedpRecordTypeId && (caseRecord.status != 'Submitted' && caseRecord.status != 'In Progress'
                  && caseRecord.status != 'Pending Documents' && caseRecord.status != 'Pending Condition of Acceptance' && caseRecord.status != 'Denied') 
                  || caseRecord.Equipment_Types__c == 'Weather Radio'
                  || docSet.contains(caseRecord.Proof_of_Income_Provided_By__c) ){
           showErroMessage = true;
        }else if(caseRecord.recordTypeId == ndbedpRecordTypeId && (caseRecord.status != 'Submitted' && caseRecord.status != 'In Progress'
        && caseRecord.status != 'Pending Documents' && caseRecord.status != 'Documents Review' && caseRecord.status != 'Denied') 
                  || caseRecord.Proof_of_Income_Provided_By__c == null
                  || docSet.contains(caseRecord.Proof_of_Income_Provided_By__c)) {
            showErroMessage = true;
        }
        
        List<FamilyDetailsWrapper> wrapList = new  List<FamilyDetailsWrapper>();
        if(!familyDetailsList.isEmpty()) {
            for(Family_Details__c family: familyDetailsList) {
             	FamilyDetailsWrapper wrap = new FamilyDetailsWrapper();
                wrap.name = family.Name__c;
                wrap.age = family.Age__c;
                wrap.relationship = family.Relationship__c;
                wrap.incomeType.Alimony = family.Alimony__c;
                wrap.incomeType.AmeriCorps_Stipends = family.AmeriCorps_Stipends__c;
                wrap.incomeType.Annuities = family.Annuities__c;
                wrap.incomeType.Armed_Forces_pay = family.Armed_Forces_pay__c;
                wrap.incomeType.Cherokee = family.Cherokee_Tribal_per_captia_Income_paid_t__c;
                wrap.incomeType.Child_support = family.Child_support__c;
                wrap.incomeType.Gross_Salary_and_Wages = family.Gross_salary_and_wages__c;
                wrap.incomeType.On_the_Job_training = family.On_the_Job_training__c;
                wrap.incomeType.Rental_Income = family.Rental_Income__c;
                wrap.incomeType.Retirement_Pension = family.Retirement_Pension__c;
                wrap.incomeType.Social_Security = family.Social_Security__c;
                wrap.incomeType.Tobacco_buy_out_payments = family.Tobacco_buy_out_payments__c;
                wrap.incomeType.Unemployment = family.Unemployment__c;
                wrap.incomeType.Veterans_Administration = family.Veteran_Administration_Benefits__c;
                wrap.incomeType.Work_Release_Payments = family.Work_Release_Payments__c;
                wrap.incomeType.Worker_Compensation_payments = family.Worker_s_Compensation_payments__c;
                wrap.incomeType.Adjustments = family.Adjustments__c;
                wrap.totalIncome = wrap.incomeType.Gross_Salary_and_Wages + wrap.incomeType.Unemployment + wrap.incomeType.Social_Security + wrap.incomeType.Veterans_Administration + wrap.incomeType.Retirement_Pension + wrap.incomeType.Worker_Compensation_payments + wrap.incomeType.Alimony + wrap.incomeType.Rental_Income + wrap.incomeType.Child_support + wrap.incomeType.On_the_Job_training + wrap.incomeType.AmeriCorps_Stipends + wrap.incomeType.Armed_Forces_pay + wrap.incomeType.Work_Release_Payments + wrap.incomeType.Tobacco_buy_out_payments + wrap.incomeType.Annuities + wrap.incomeType.Cherokee + wrap.incomeType.Adjustments;
                wrapList.add(wrap);
            }
        }
        
        result.put('alreadyFilled',alreadyFilled);
        result.put('showErroMessage',showErroMessage);
        result.put('maritalStatus',maritalStatus);
        result.put('proofOfIncomeProvidedBy',proofOfIncomeProvidedBy);
        result.put('familyWrapList',wrapList);
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : updateContactData
    @description    : update family details and case data
    @param          : String familyJsonData, Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> updateContactData(String familyJsonData, Id recordId){
        Map<String, Object> result = new Map<String, Object>();
        List<FamilyDetailsWrapper> FamilyDetails = (List<FamilyDetailsWrapper>) JSON.deserialize(familyJsonData, List<FamilyDetailsWrapper>.class);
        List<Family_Details__c> familyDetailsList = new List<Family_Details__c>(); 
        Decimal sumOfAllIncome = 0;
        Family_Details__c familyRecord ;
        String url = System.URL.getSalesforceBaseUrl().toExternalForm(); 
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        Case caseRecord = [SELECT Id,Status,ContactId, RecordTypeId FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED];
        
        //List<Family_Details__c> delFamilyDetailsList = [SELECT id FROM Family_Details__c WHERE Request__c =: recordId WITH SECURITY_ENFORCED];
        //if(!delFamilyDetailsList.isEmpty()) {
        //    delete delFamilyDetailsList;
        //}
        
        for(FamilyDetailsWrapper family : FamilyDetails){
            familyRecord = new Family_Details__c();
            familyRecord.Name__c = family.name;
            familyRecord.Age__c = family.age;
            familyRecord.Relationship__c = family.relationship;
            familyRecord.Contact__c = caseRecord.ContactId;
            familyRecord.Request__c = caseRecord.Id;
            familyRecord.Alimony__c = family.incomeType.Alimony;
            familyRecord.AmeriCorps_Stipends__c = family.incomeType.AmeriCorps_Stipends;
            familyRecord.Annuities__c = family.incomeType.Annuities;
            familyRecord.Armed_Forces_pay__c = family.incomeType.Armed_Forces_pay;
            familyRecord.Cherokee_Tribal_per_captia_Income_paid_t__c = family.incomeType.Cherokee;
            familyRecord.Child_support__c = family.incomeType.Child_support;
            familyRecord.Gross_salary_and_wages__c = family.incomeType.Gross_Salary_and_Wages;
            familyRecord.On_the_Job_training__c = family.incomeType.On_the_Job_training;
            familyRecord.Rental_Income__c = family.incomeType.Rental_Income;
            familyRecord.Retirement_Pension__c = family.incomeType.Retirement_Pension;
            familyRecord.Social_Security__c= family.incomeType.Social_Security;
            familyRecord.Tobacco_buy_out_payments__c= family.incomeType.Tobacco_buy_out_payments;
            //familyRecord.Total_Income__c = family.incomeType.
            familyRecord.Unemployment__c= family.incomeType.Unemployment;
            familyRecord.Veteran_Administration_Benefits__c =family.incomeType.Veterans_Administration;
            familyRecord.Work_Release_Payments__c= family.incomeType.Work_Release_Payments;
            familyRecord.Worker_s_Compensation_payments__c = family.incomeType.Worker_Compensation_payments;
            familyRecord.Adjustments__c = family.incomeType.Adjustments;
            sumOfAllIncome += family.totalIncome;
            familyDetailsList.add(familyRecord); 
        }
        Integer currenYear = Integer.valueOf(Date.Today().year());
        
        Map<Integer,Income_Worksheet__mdt> numberOfMemberToIncomeWorkSheet = new  Map<Integer,Income_Worksheet__mdt>();
        for(Income_Worksheet__mdt incomeWorkSheet : [SELECT Id, Number_of_Members__c, Amount__c, Year__c 
                                                     FROM Income_Worksheet__mdt 
                                                     WHERE Number_of_Members__c =: familyDetailsList.size() WITH SECURITY_ENFORCED
                                                     ORDER By Year__c ASC]){
                                                     //AND Year__c =: currenYear]){
               numberOfMemberToIncomeWorkSheet.put(Integer.valueOf(incomeWorkSheet.Number_of_Members__c), incomeWorkSheet);
        }
        //if(familyDetailsList.size()>0){
        //    SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Family_Details__c', familyDetailsList, 'insert', true, 'NC_IncomeWorksheetController','updateContactData');
        //    insert decision.getRecords();
        //    familyDetailsList = decision.getRecords();
        //}
        Decimal sumOfAllIncomePercentage = sumOfAllIncome ;  //2.50 * sumOfAllIncome;
        if(ndbedpRecordTypeId != caseRecord.recordTypeId && numberOfMemberToIncomeWorkSheet.containskey(familyDetailsList.size()) &&  numberOfMemberToIncomeWorkSheet.get(familyDetailsList.size()).Amount__c*2.50 < sumOfAllIncomePercentage){ 
            if(caseRecord.Status != 'Denied'){
                familyDetailsList = insertFamilyDetails(familyDetailsList);
                deleteFamilyDetails(recordId, familyDetailsList);
                caseRecord.Income_more_than_250_percent__c = true;
                caseRecord.Status = 'Denied';
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', new List<Case>{caseRecord}, 'update', true,'NC_IncomeWorksheetController','updateContactData');
                update decision.getRecords();
            }  else {
                result.put('error','Total Family Income is more than 250 percent of the allowed income.');
                return result;
            }
        }  else if(ndbedpRecordTypeId != caseRecord.recordTypeId && caseRecord.Status == 'Denied') {
            //caseRecord.Status = 'Pending Condition of Acceptance';
            caseRecord.Income_more_than_250_percent__c = false;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', new List<Case>{caseRecord}, 'update', true,'NC_IncomeWorksheetController','updateContactData');
            update decision.getRecords();
            familyDetailsList = insertFamilyDetails(familyDetailsList);
            deleteFamilyDetails(recordId, familyDetailsList);
        } else if(ndbedpRecordTypeId != caseRecord.recordTypeId) {
            if(familyDetailsList.size()>0){
                familyDetailsList = insertFamilyDetails(familyDetailsList);
                deleteFamilyDetails(recordId, familyDetailsList);
            }
        }

        //NDBEDP
        Map<Integer, NDBEDP_Income_Worksheet__mdt> memberToWorkSheetNDBEDP = new Map<Integer, NDBEDP_Income_Worksheet__mdt>();
        for(NDBEDP_Income_Worksheet__mdt metadata: NDBEDP_Income_Worksheet__mdt.getAll().values()) {
            memberToWorkSheetNDBEDP.put(Integer.valueOf(metadata.Number_of_Members__c), metadata);
        }
        if(ndbedpRecordTypeId == caseRecord.recordTypeId && memberToWorkSheetNDBEDP.containskey(familyDetailsList.size()) &&  memberToWorkSheetNDBEDP.get(familyDetailsList.size()).Amount__c*4 < sumOfAllIncomePercentage){ 
            if(caseRecord.Status != 'Denied'){
                familyDetailsList = insertFamilyDetails(familyDetailsList);
                deleteFamilyDetails(recordId, familyDetailsList);
                caseRecord.Income_more_than_400_percent__c = true;
                caseRecord.Status = 'Denied';
                caseRecord.Income_Worksheet_Adjusted__c = false;
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', new List<Case>{caseRecord}, 'update', true,'NC_IncomeWorksheetController','updateContactData');
                update decision.getRecords();
            } else {
                result.put('error','Total Family Income is more than 400 percent of the allowed income.');
                return result;
            }
        } else if (ndbedpRecordTypeId == caseRecord.recordTypeId && caseRecord.Status == 'Denied') {
            String caseStatus = '';
            for(CaseHistory history: [SELECT OldValue, NewValue FROM CaseHistory WHERE CaseId =: caseRecord.Id AND Field = 'Status' order by createdDate DESC]) {
                if(history.NewValue == 'Denied' && history.OldValue != 'Denied') {
                    caseStatus = String.valueOf(history.OldValue);
                    break;
                }
            }
            if(caseStatus == 'Submitted' || caseStatus == 'Pending Documents') {
                caseRecord.Status = caseStatus;
                caseRecord.Income_Worksheet_Adjusted__c = true;
            }
            caseRecord.Approve_or_Reject__c = true;
            caseRecord.Income_more_than_400_percent__c = false;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', new List<Case>{caseRecord}, 'update', true,'NC_IncomeWorksheetController','updateContactData');
            update decision.getRecords();
            familyDetailsList = insertFamilyDetails(familyDetailsList);
            deleteFamilyDetails(recordId, familyDetailsList);
        } else if(ndbedpRecordTypeId == caseRecord.recordTypeId) {
         	if(familyDetailsList.size()>0){
                familyDetailsList = insertFamilyDetails(familyDetailsList);
                deleteFamilyDetails(recordId, familyDetailsList);
                //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Family_Details__c', familyDetailsList, 'insert', true, 'NC_IncomeWorksheetController','updateContactData');
                //insert decision.getRecords();
                //familyDetailsList = decision.getRecords();
                //List<Family_Details__c> delFamilyDetailsList = [SELECT id FROM Family_Details__c WHERE Request__c =: recordId AND ID NOT IN: familyDetailsList WITH SECURITY_ENFORCED];
                //if(!delFamilyDetailsList.isEmpty()) {
                //    delete delFamilyDetailsList;
                //}
            }
        }
        url = url+'/lightning/r/case/' + caseRecord.Id+'/view';
        result.put('url',url);

        result.put('success','Family Members Added');
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : insertFamilyDetails
    @description    : insert family details data
    @param          : List<Family_Details__c> familyDetailsList
    @return         : List<Family_Details__c>
    ********************************************************
    */
    public static List<Family_Details__c> insertFamilyDetails(List<Family_Details__c> familyDetailsList) {
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Family_Details__c', familyDetailsList, 'insert', true, 'NC_IncomeWorksheetController','updateContactData');
        insert decision.getRecords();
        return decision.getRecords();
    }
    
    /*
    *********************************************************
    @Method Name    : deleteFamilyDetails
    @description    : delete family details data
    @param          : Id caseId, List<Family_Details__c> familyDetailsList
    @return         : void
    ********************************************************
    */
    public static void deleteFamilyDetails(Id caseId, List<Family_Details__c> familyDetailsList) {
		List<Family_Details__c> delFamilyDetailsList = [SELECT id FROM Family_Details__c WHERE Request__c =: caseId AND ID NOT IN: familyDetailsList WITH SECURITY_ENFORCED];
        if(!delFamilyDetailsList.isEmpty()) {
            delete delFamilyDetailsList;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : fetchPicklist
    @description    : Fetch Picklist Values
    @param          : String objectName, String fieldName
    @return         : List<SelectOptionWrapper>
    ********************************************************
    */
    @AuraEnabled
    public static List<SelectOptionWrapper> fetchPicklist(String objectName, String fieldName){
        List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>(); 
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        if(fields.containsKey(fieldName)){
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                optionList.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
            }
        }
        
        return optionList;
    }


    public class IncomeWorkSheet{
        List<FamilyDetailsWrapper> listOfFamilyDetailsWrapper;

        IncomeWorkSheet(){
            listOfFamilyDetailsWrapper = new List<FamilyDetailsWrapper> ();
        }
    }


    public class incomeType{
        @AuraEnabled public Decimal Alimony;
        @AuraEnabled public Decimal AmeriCorps_Stipends;
        @AuraEnabled public Decimal Annuities;
        @AuraEnabled public Decimal Armed_Forces_pay;
        @AuraEnabled public Decimal Cherokee;
        @AuraEnabled public Decimal Child_support;
        @AuraEnabled public Decimal Gross_Salary_and_Wages;
        @AuraEnabled public Decimal On_the_Job_training;
        @AuraEnabled public Decimal Rental_Income;
        @AuraEnabled public Decimal Retirement_Pension;
        @AuraEnabled public Decimal Social_Security;
        @AuraEnabled public Decimal Tobacco_buy_out_payments;
        @AuraEnabled public Decimal Unemployment;
        @AuraEnabled public Decimal Veterans_Administration;
        @AuraEnabled public Decimal Work_Release_Payments;
        @AuraEnabled public Decimal Worker_Compensation_payments;
        @AuraEnabled public Decimal Adjustments;

        public incomeType(){
            this.AmeriCorps_Stipends = 0.0;
            this.Annuities = 0.0;
            this.Armed_Forces_pay = 0.0;
            this.Cherokee = 0.0;
            this.Child_support = 0.0;
            this.Gross_Salary_and_Wages = 0.0;
            this.On_the_Job_training = 0.0;
            this.Rental_Income = 0.0;
            this.Retirement_Pension = 0.0;
            this.Social_Security = 0.0;
            this.Tobacco_buy_out_payments = 0.0;
            this.Unemployment = 0.0;
            this.Veterans_Administration = 0.0;
            this.Work_Release_Payments = 0.0;
            this.Alimony = 0.0;
            this.Worker_Compensation_payments = 0.0;  
            this.Adjustments = 0.0;
        }
    }

    public class FamilyDetailsWrapper{
        @AuraEnabled public Decimal totalIncome;
        @AuraEnabled public Decimal age;
        @AuraEnabled public String name;
        @AuraEnabled public String relationship;
        @AuraEnabled public incomeType incomeType;

        public FamilyDetailsWrapper(){
            this.age = Null;
            this.name = '';
            this.relationship = '';
            this.totalIncome = 0;
            this.incomeType = new incomeType();
        }
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