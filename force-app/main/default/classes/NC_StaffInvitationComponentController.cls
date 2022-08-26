/*
*   Class Name: NC_StaffInvitationComponentController
*   Description: Staff Request Invitation Controller to send mail to the users
*
*   Date            New/Modified         User                 Identifier                Description
*   04/06/2020         New         Shubham Dadhich(mtx)
*   05/06/2020         New         Hiten Aggarwal(mtx)
*/
public with sharing class NC_StaffInvitationComponentController {
    
    /*
    *********************************************************
    @Method Name    : fetchUserList
    @description    : Fetch internal or external users for sending invitation
    @param          : List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> fetchUserList(String recordId, String regionalCenter, String County, String licenseType,String speciality){
        List<UsersWrapper> listOfUserWrapper = new List<UsersWrapper>();
        //List<UsersWrapper> listOfVendorWrapper = new List<UsersWrapper>();
        Id vendorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', NC_Constant.Account_Vendor_RecordType);
        Id ndbedpTrainerRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Account', 'NDBEDP_Trainer');
        Id internalRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c', 'Internal_Staff');
        Map<String, Object> result = new Map<String, Object>();
        Map<String, String> vendorTypeToVendorFieldApiName = NC_Constant.vendorTypeToVendorFieldApiName;
        Boolean isInterpreter = false;
        Decimal numberOfmembersNeeded = 0;
        Set<String> internalUserRoles = new Set<String>{'Communication_Access_Manager','Home_office_Staff_Interpreters', 'Interpreter_Services_Specialist'};

        Staffing_Request__c staffingRequestRecord  = [SELECT Id, RecordTypeId, Vendor_Type__c, Number_of_Vendors_Needed__c, Number_of_Interpreters_Needed__c FROM Staffing_Request__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        Id accountRecordTypeId = staffingRequestRecord.Vendor_Type__c == 'NDBEDP Training' ? ndbedpTrainerRecordTypeId : vendorRecordTypeId;
        Boolean isNDBEDPTraining = staffingRequestRecord.Vendor_Type__c == 'NDBEDP Training' ? true : false;
        
        if(internalRecordTypeId == staffingRequestRecord.RecordTypeId){
            numberOfmembersNeeded = staffingRequestRecord.Number_of_Interpreters_Needed__c != NULL ? Integer.valueOf(staffingRequestRecord.Number_of_Interpreters_Needed__c) : 0;
            //Id platformUserProfileId = [SELECT Id, Name FROM Profile WHERE Name =: NC_Constant.STANDARD_PROFILE_NAME LIMIT 1].Id;
            //for(User userRecord : [SELECT Id, Name, Email FROM User WHERE ProfileId =: platformUserProfileId AND IsActive = true]){
            for(User userRecord : [SELECT Id, Name, Email FROM User WHERE UserRole.DeveloperName IN: internalUserRoles AND IsActive = true]){
                UsersWrapper userWrapperRecord = new UsersWrapper();
                userWrapperRecord.userName = userRecord.Name;
                userWrapperRecord.userId = userRecord.Id;
                userWrapperRecord.emailId = userRecord.Email;
                listOfUserWrapper.add(userWrapperRecord);
            }
            result.put('isExternalRecord', false);
        }else{
            //vendor Records
            numberOfmembersNeeded = staffingRequestRecord.Number_of_Vendors_Needed__c != NULL ? Integer.valueOf(staffingRequestRecord.Number_of_Vendors_Needed__c) : 0;
            Set<Id> activeVendorPortalAccount = new Set<Id>();
            for(User userSelected: [SELECT Id,AccountId FROM User WHERE isActive = true AND account.IsCustomerPortal = true]){
                activeVendorPortalAccount.add(userSelected.AccountId);
            } 
            String accountStatus = 'Approved';
            String query = 'SELECT Id, Name, Email__c, CART__c, Interpreter__c, SSP__c, Individual__c, IsCustomerPortal ,Training_Vendor__c, ';
            query += ' Approved_Interpreter__c,Approved_CART__c,Approved_SSP__c,Approved_Training_Vendor__c,Regional_Center__r.Name,County__c,  ';
            query += ' License_Type__c, Specialty__c ';
            query += ' FROM Account ';
            query += ' WHERE RecordTypeId =: accountRecordTypeId AND ( IsCustomerPortal = False OR ID IN: activeVendorPortalAccount) AND (Status__c =:accountStatus)  AND (Active__c = true)';
            // query += ' WHERE Active__c = true';
            if(regionalCenter != 'All'){
                //query += ' AND Regional_Center__r.Name = \'' + regionalCenter +'\'';
                query += ' AND Regional_Center__r.Name = :regionalCenter';
            }
            if(County != 'All'){
                //query += ' AND County__c = \'' + County +'\'';
                query += ' AND County__c = :County';
            }
            // if(County != 'All'){
            //     query += ' AND County__c = \'' + County +'\''; 
            // }
            if(!isNDBEDPTraining && licenseType != 'All'){
                //query += ' AND License_Type__c	 = \'' + licenseType +'\'';
                query += ' AND License_Type__c = :licenseType';
            }
            if(!isNDBEDPTraining && speciality != 'All'){
                query += ' AND Specialty__c	 includes (\'' + speciality +'\')';
            }
            for(Account account : Database.query(query)){ //AND IsCustomerPortal = True
                if(isNDBEDPTraining || (vendorTypeToVendorFieldApiName.containsKey(staffingRequestRecord.Vendor_Type__c) && account.get(vendorTypeToVendorFieldApiName.get(staffingRequestRecord.Vendor_Type__c)) == true)){
                    UsersWrapper userWrapperRecord = new UsersWrapper();
                    userWrapperRecord.userName = account.Name;
                    userWrapperRecord.userId = account.Id;
                    userWrapperRecord.emailId = account.Email__c;
                    userWrapperRecord.isIndividual = account.Individual__c;
                    userWrapperRecord.IsVendorPortalUser = account.IsCustomerPortal;
                    userWrapperRecord.vendorType = staffingRequestRecord.Vendor_Type__c;
                    userWrapperRecord.accountRecord = account;
                    isInterpreter = staffingRequestRecord.Vendor_Type__c == 'Interpreters' ? true : false;
                    listOfUserWrapper.add(userWrapperRecord);
                }
            }
            result.put('isInterpreter',isInterpreter);
            result.put('isExternalRecord', true);
        }
        
        if(listOfUserWrapper.size()>0){
            result.put('result', listOfUserWrapper);
            result.put('numberOfVendorsNeeded',numberOfmembersNeeded);
        }else{
            result.put('error', 'No user found.');
        }
        return result;
    }

    /*
    *********************************************************
    @Method Name    : sendEmailInviation
    @description    : Send Email to all selected Users
    @param          : String userdata, String recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> sendEmailInviation(String userdata, String recordId){
        Map<String, Object> result= new Map<String, Object>();
        Boolean isSelected = false;
        Id internalRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c', 'Internal_Staff');
        Id inernalStaffingUserRequestId = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c', 'Internal_Staffing_User_Request');
        Id externalStaffingUserRequestId = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c', 'External_Staffing_User_Request');
        Id trainingVendorStaffingUserRequestId = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c', 'Training_Vendor_Staffing_User_Request');
        
        List<Id> accountIdOrUserIdSet = new List<Id>();
        Decimal numberOfmembersNeeded = 0;
        
        Staffing_Request__c staffingRequestRecord  = [SELECT Id, RecordTypeId, Vendor_Type__c, Number_of_Vendors_Needed__c ,Number_of_Interpreters_Needed__c , Total_Members_Attending__c, Regional_Center__c FROM Staffing_Request__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        if(staffingRequestRecord.RecordTypeId == internalRecordTypeId){
            numberOfmembersNeeded = Integer.valueOf(staffingRequestRecord.Number_of_Interpreters_Needed__c);
        }else{
            numberOfmembersNeeded = Integer.valueOf(staffingRequestRecord.Number_of_Vendors_Needed__c);
        }
        
        if(staffingRequestRecord.Total_Members_Attending__c >= numberOfmembersNeeded){
            String  message = 'Slots Already Filled.';
            result.put('warning', message);
            return result;
        }
        
        Set<String> staffUserReqStatusSet = new Set<String>{'Rejected'};
        for(Staffing_User_Request__c staffingUserRequest : [SELECT Id, User__c, Account__c FROM Staffing_User_Request__c WHERE Staffing_Request__c =: recordId AND Status__c NOT IN:staffUserReqStatusSet WITH SECURITY_ENFORCED]){
            if(staffingUserRequest.User__c != NULL){
                accountIdOrUserIdSet.add(staffingUserRequest.User__c);
            }else if(staffingUserRequest.Account__c != NULL){
                accountIdOrUserIdSet.add(staffingUserRequest.Account__c);
            }
        }
        
        //List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        Set<Id> accountIds = new Set<Id>();
        List<Staffing_User_Request__c> staffUserRequestList = new List<Staffing_User_Request__c>();
        List<UsersWrapper> userWrapperList = (List<UsersWrapper>) JSON.deserialize(userdata, List<UsersWrapper>.class);
        Integer count = 0;
        for(UsersWrapper userWrapperRecord : userWrapperList){
            if(userWrapperRecord.isSelected){
                isSelected = true;
                if(!accountIdOrUserIdSet.contains(userWrapperRecord.userId)){
                    if(staffingRequestRecord.RecordTypeId == internalRecordTypeId){
                        Staffing_User_Request__c staffingUser = new Staffing_User_Request__c();
                        staffingUser.Staffing_Request__c = recordId;
                        staffingUser.Number_of_Members_Providing__c = 1;
                        staffingUser.Approved_Number_of_Members__c = 1;
                        staffingUser.User__c = userWrapperRecord.userId;     // UserId Contains UserId
                        staffingUser.RecordTypeId = inernalStaffingUserRequestId;
                        staffingUser.Regional_Center__c = staffingRequestRecord.Regional_Center__c != NULL ? staffingRequestRecord.Regional_Center__c : NULL;
                        staffingUser.Email__c = userWrapperRecord.emailId;
                        staffUserRequestList.add(staffingUser);
                        count++;
                    }else{
                        Staffing_User_Request__c staffingUser = new Staffing_User_Request__c();
                        staffingUser.Staffing_Request__c = recordId;
                        if(userWrapperRecord.isIndividual){
                            userWrapperRecord.numberOfMembersProving = 1;
                        }
                        staffingUser.Number_of_Members_Providing__c = userWrapperRecord.numberOfMembersProving;
                        staffingUser.Approved_Number_of_Members__c = userWrapperRecord.numberOfMembersProving;
                        staffingUser.Account__c = userWrapperRecord.userId;  // UserId Contains AccountId
                        accountIds.add(staffingUser.Account__c);
                        if(userWrapperRecord.vendorType == 'Training Vendor' || userWrapperRecord.vendorType == 'NDBEDP Training'){
                          staffingUser.RecordTypeId = trainingVendorStaffingUserRequestId;
                        }else{
                            staffingUser.RecordTypeId = externalStaffingUserRequestId;
                        }
                        staffingUser.Email__c = userWrapperRecord.emailId;
                        staffingUser.Is_Vendor_Portal_User__c = userWrapperRecord.IsVendorPortalUser;
                        staffingUser.Regional_Center__c = staffingRequestRecord.Regional_Center__c != NULL ? staffingRequestRecord.Regional_Center__c : NULL;
                        staffUserRequestList.add(staffingUser);
                        count = count + userWrapperRecord.numberOfMembersProving;
                    }
                }
               /* Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
                singleEmailMessage.setSubject('You are inviated in event');
                if(internalRecordTypeId == staffingRequestRecord.RecordTypeId){
                    String htmlBody = 'Please click on button to accecpt the invitation <br/><br/><br/> <table cellspacing="0" cellpadding="0"> <tr> <td align="center" width="300" height="40" bgcolor="#000091" style="-webkit-border-radius: 5px; -moz-border-radius: 5px; border-radius: 5px; color: #ffffff; display: block;"> <a href="https://mtxdev-ncdsdhh.cs32.force.com/invitation/NC_StaffingUserInvitation?id='+recordId+'&userid='+userWrapperRecord.userId + '" style="font-size:16px; font-weight: bold; font-family: Helvetica, Arial, sans-serif; text-decoration: none; line-height:40px; width:100%; display:inline-block"><span style="color: #FFFFFF">Accept</span></a> </td> </tr> </table>';
                    singleEmailMessage.setHtmlBody(htmlBody);
                    singleEmailMessage.setTargetObjectId(Id.valueOf(userWrapperRecord.userId));
                }else{
                    String htmlBody = 'Please click on button to accecpt the invitation <br/><br/><br/> <table cellspacing="0" cellpadding="0"> <tr> <td align="center" width="300" height="40" bgcolor="#000091" style="-webkit-border-radius: 5px; -moz-border-radius: 5px; border-radius: 5px; color: #ffffff; display: block;"> <a href="https://mtxdev-ncdsdhh.cs32.force.com/invitation/NC_StaffingUserInvitationExternal?id='+recordId+'&emailid='+userWrapperRecord.userId + '" style="font-size:16px; font-weight: bold; font-family: Helvetica, Arial, sans-serif; text-decoration: none; line-height:40px; width:100%; display:inline-block"><span style="color: #FFFFFF">Accept</span></a> </td> </tr> </table>';
                    singleEmailMessage.setHtmlBody(htmlBody);
                    singleEmailMessage.setToAddresses(new List<String>{userWrapperRecord.userId} );
                }
                
                singleEmailMessage.setSaveAsActivity(false);
                singleEmailMessageList.add(singleEmailMessage);*/
            }
        }

        if(count < (numberOfmembersNeeded - staffingRequestRecord.Total_Members_Attending__c) && staffUserRequestList.Size() > 0){
            String  message = 'Please add atleast '+ (numberOfmembersNeeded - staffingRequestRecord.Total_Members_Attending__c) +' members.';
            result.put('error', message);
            return result;
        }else if(staffUserRequestList.Size()>0){
            try{
                if(staffingRequestRecord.Vendor_Type__c == 'NDBEDP Training' && staffingRequestRecord.RecordTypeId == Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId()) {
                Map<Id, Id> portalAccountMap = new Map<Id, Id>();
                for(User user : [Select id,Contact.Account.Id from user Where Contact.Account.Id IN: accountIds AND Contact.Account.IsCustomerPortal = True]){
                    portalAccountMap.put(user.Contact.Account.Id, user.id);
                }
                List<User> userList = [SELECT id FROM User WHERE IsActive = true AND UserRole.DeveloperName = 'NDBEDP_Coordinator' LIMIT 1];
                List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
                for(Staffing_User_Request__c staffRequest: staffUserRequestList) {
                    if(portalAccountMap.containsKey(staffRequest.Account__c)) {
                        staffRequest.Trainer_Administrator_User__c = portalAccountMap.get(staffRequest.Account__c);
                    } else {
                        staffRequest.Trainer_Administrator_User__c = !userList.isEmpty() ? userList[0].id : null;
                    }
                }
                //Create Portal User from Trainer
                checkTrinerOnPortal(new Set<Id>{staffUserRequestList[0].Account__c});
                }
            	SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Staffing_User_Request__c', staffUserRequestList, 'insert', true,'NC_StaffInvitationComponentController','sendEmailInviation');
            	insert decision.getRecords();   
            } catch(Exception e) {
                Map<String, String> errorMsgMap = new Map<String, String>();
                for(Integer i=0;i<e.getNumDml();i++) {
                    errorMsgMap.put(e.getDmlMessage(i), e.getDmlMessage(i));
                }
                String errorMsg = '';
                for(String error: errorMsgMap.keySet()) {
                    errorMsg += error;
                }
                result.put('error', errorMsg);
            	return result;
            }
            String  message = 'Invitation send successfully.';
            result.put('success', message);
            return result;
        }else if(isSelected){
            String  message = 'User Already Invited.';
            result.put('warning', message);
            return result;
        }else{
            String  message = 'Please select a user.';
            result.put('error', message);
            return result;
        }
        
      /*if(!singleEmailMessageList.isEmpty()){
            Messaging.SendEmailResult [] resultEmail = Messaging.sendEmail(singleEmailMessageList);
            String  message = 'Email sent succesfully.';
            result.put('success', message);
            return result;
        }else{
            String  message = 'Please select a user.';
            result.put('error', message);
            return result;
        }*/
    }

    /*
    *********************************************************
    @Method Name    : checkTrinerOnPortal
    @description    : Check if Trainer is on portal else create new portal user
    @param          : Set<Id> accountIds
    @return         : void
    ********************************************************
    */
    public static void checkTrinerOnPortal(Set<Id> accountIds) {
        List<User> userList = new List<User>();
        List<Contact> contactList = new List<Contact>();
        for(Account accountRecord: [SELECT Id,First_Name__c,Last_Name__c ,Email__c,Is_Vendor_on_Portal__c,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIds AND Is_Vendor_on_Portal__c=true AND IsCustomerPortal = false WITH SECURITY_ENFORCED]){
            if(String.isNotBlank(accountRecord.Last_Name__c)){
                Contact con = new Contact();
                con.AccountId = accountRecord.Id;
                con.LastName = accountRecord.Last_Name__c;
                con.FirstName = accountRecord.First_Name__c;
                con.Hearing_Disability__c = 'Deaf';
                con.Email = accountRecord.Email__c;
                contactList.add(con);
            }
        }
        if(contactList.size() > 0) {
            //insert contactList;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Contact', contactList, 'insert', true,'NC_StaffInvitationComponentController','checkTrinerOnPortal');
            insert decision.getRecords();
        }
        List<Id> contactCommunityUser = new List<Id>();
        for(User userRecord :[SELECT Id,Contact.Id,Name,Email FROM User WHERE (Profile.Name = 'NDBEDP Assessor' OR Profile.Name = 'Vendor Community User Profile') AND Contact.AccountId IN :accountIds]){
            contactCommunityUser.add(userRecord.Contact.Id);
        }

        List<Profile> profileList = [SELECT Id FROM Profile WHERE Name='NDBEDP Assessor' Limit 1];
        List<User> InsertUserList = new List<User>();
        for(Contact con :[SELECT Id,AccountId,LastName,FirstName,Email FROM Contact WHERE AccountId IN :accountIds WITH SECURITY_ENFORCED]){
            if(!contactCommunityUser.contains(con.Id)){
                User user1 = new User(
                    UserName = con.Email+Integer.valueOf(Math.random()*1000),
                    FirstName = con.FirstName,
                    LastName = con.LastName,
                    Alias = Integer.valueOf(Math.random()*100)+'',
                    email = con.Email,
                    ContactId = con.Id,
                    ProfileId = profileList[0].Id,
                    EmailEncodingKey = 'UTF-8',
                    CommunityNickname =  con.FirstName+con.LastName+Integer.valueOf(Math.random()*1000)+'',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'
                );
                userList.add(user1);
            }
        }
        if(userList.size()>0){
            insert userList;
        } 
    }

    /*
    *********************************************************
    @Method Name    : fetchCountRegionalCenter
    @description    : Fetch Regional Center and county
    @param          : String recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> fetchCountRegionalCenter(String recordId){
        Map<String, Object> result= new Map<String, Object>();

        Staffing_Request__c staffingRequestRecord  = [SELECT Vendor_Type__c FROM Staffing_Request__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        Boolean isNDBEDPTraining = staffingRequestRecord.Vendor_Type__c == 'NDBEDP Training' ? true : false;

        List<SelectOptionWrapper> countyOptionList = new List<SelectOptionWrapper>();
        SelectOptionWrapper allOption = new SelectOptionWrapper('All','All','');
        countyOptionList.add(allOption);
        countyOptionList.addAll(fetchPicklist('Regional_Center_And_County__mdt', 'County__c'));
       
        List<SelectOptionWrapper> regionalCenterOptionList =   new List<SelectOptionWrapper>();
        regionalCenterOptionList.add(allOption);
        regionalCenterOptionList.addAll(fetchPicklist('Regional_Center_And_County__mdt', 'Regional_Center__c'));

        if(!isNDBEDPTraining) {
            List<SelectOptionWrapper> LicenceTypeList =   new List<SelectOptionWrapper>();
            LicenceTypeList.add(allOption);
            LicenceTypeList.addAll(fetchPicklist('Account', 'License_Type__c'));

            List<SelectOptionWrapper> SpecialityList =   new List<SelectOptionWrapper>();
            SpecialityList.add(allOption);
            SpecialityList.addAll(fetchPicklist('Account', 'Specialty__c'));

            result.put('SpecialityList',SpecialityList);
            result.put('LicenceTypeList',LicenceTypeList);
        }
        
        result.put('countyOptionList',countyOptionList);
        result.put('regionalCenterOptionList',regionalCenterOptionList);
        result.put('isNDBEDPTraining', isNDBEDPTraining);
        return result;

    }

    /*
    *********************************************************
    @Method Name    : fetchPicklist
    @description    : Fetch picklist based on objectname and fieldname
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
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            optionList.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
        }    
        return optionList;
    }

    public class SelectOptionWrapper{
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        @AuraEnabled public string developerName;
        public SelectOptionWrapper(string value, string label, string developerName){
            this.value = value;
            this.label = label;
            this.developerName = developerName;
        }
        public SelectOptionWrapper(string value, string label){
            this.value = value;
            this.label = label;
        }
    }
    
    @TestVisible
    class UsersWrapper{
        @AuraEnabled public String userName;
        @AuraEnabled public String userId;
        @AuraEnabled public String emailId;
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public Integer numberOfMembersProving;
        @AuraEnabled public Boolean isIndividual;
        @AuraEnabled public Boolean isInterpreter;
        @AuraEnabled public Boolean IsVendorPortalUser;
        @AuraEnabled public String vendorType;
        @AuraEnabled public Account accountRecord;
       
   
        public UsersWrapper(){
            this.userName = '';
            this.userId = '';
            this.emailId = '';
            this.isSelected = false;
            this.numberOfMembersProving = 0;
            this.isIndividual = true;
            this.isInterpreter = false;
            this.IsVendorPortalUser = false;
            this.vendorType = '';
            this.accountRecord = new Account();
           
        }
    }
}