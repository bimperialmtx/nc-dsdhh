/*
*   Class Name: NC_UserTriggerHandler
*   Description: User Trigger Handler -- Logics on insert, update and delete
*
*   Date            New/Modified         User                 Identifier                Description
*   27/04/2020         New         Shubham Dadhich(mtx)
*/
public with sharing class NC_UserTriggerHandler {

    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before insert' trigger event
    @param          : List<User> userNewList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<User> userNewList) {
        validateRegionalCenter(userNewList);
        updateSecondaryRegionalCenter(userNewList);
        updateCounty(userNewList,null);
    }

    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before update' trigger event
    @param          : List<User> userNewList, Map<Id,User> userOldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<User> userNewList, Map<Id,User> userOldMap) {
        validateRegionalCenter(userNewList);
        updateSecondaryRegionalCenterupdate(userNewList,userOldMap);
        updateCounty(userNewList,userOldMap);
    }

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<User> userNewList, Map<Id,User> userOldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<User> userNewList, Map<Id,User> userOldMap) {
        validateAndUpdateGroupMember(userNewList, userOldMap);
        assignPermissions(userNewList,userOldMap);
        validateInternalAssessor(userNewList,userOldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'after Insert' trigger event
    @param          : List<User> userNewList
    @return         : void
    ********************************************************
    */
        public static void afterInsert(List<User> userNewList) {
            addUserToGroup(userNewList);
            shareAccountWithUser(userNewList);
            assignPermissions(userNewList,null);

            List<Id> accList=new List<Id>();
            List<Account> accountList=new List<Account>();
            List<Id> conList=new List<Id>();
            if (!userNewList.isEmpty()) {
                List<User> lUsers = [
                    SELECT Id, ContactId, Name, Contact.AccountId, Email 
                    FROM User 
                    WHERE 
                  //Profile.Name = 'Vendor Community User Profile' 
                    //	AND
                         ID IN :userNewList AND ContactId != null ];
                
                if(!lUsers.isEmpty())
                {
                    for(User u:lUsers){
                        accList.add(u.contact.AccountId);
                    }
                    accountIsVendoronPortalUpdate(accList);
                }
            }
    }

    /*
    *********************************************************
    @Method Name    : accountIsVendoronPortalUpdate
    @description    : method to update Is_Vendor_on_Portal__c field on Agency;
    @param          : List<Id> Account
    @return         : void
    ********************************************************
    */
        @future
        public static void accountIsVendoronPortalUpdate(List<Id> AccountId){
            List<Account> accountList=new List<Account>();
            
            if(!AccountId.isEmpty())
            {
                for(Account a:[SELECT Id,Is_Vendor_on_Portal__c,X1099_Code__c FROM Account WHERE Id IN :AccountId AND Is_Vendor_on_Portal__c = false WITH SECURITY_ENFORCED]){
                    a.Is_Vendor_on_Portal__c=true;
                    accountList.add(a);
                }
            }
            
            if(!accountList.isEmpty())
            {
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Account', accountList, 'update', true,'NC_UserTriggerHandler','accountIsVendoronPortalUpdate');
                update decision.getRecords();
            }

        }
    
    /*
    *********************************************************
    @Method Name    : assignPermissions
    @description    : method to assign default permissions
    @param          : List<User> userNewList, Map<Id,User> userOldMap
    @return         : void
    ********************************************************
    */
    private static void assignPermissions(List<User> userNewList, Map<Id,User> userOldMap) {
        Map<String,String> mapRoleAndPermissionSet = NC_Constant.mapRoleAndPermissionSet;
        List<PermissionSetLicenseAssign> assignPSLicenseAssingnmentList = new List<PermissionSetLicenseAssign>();
        List<PermissionSetAssignment> assignPSAssingnmentList = new List<PermissionSetAssignment>();
        List<PermissionSetLicense> permissionLicenseList = [SELECT Id, DeveloperName FROM PermissionSetLicense WHERE DeveloperName = 'LightningConsole' OR DeveloperName = 'CompanyCommunityPsl' WITH SECURITY_ENFORCED];
        
        Map<String,String> userRoleIdAndNameMap = new Map<String,String>();
        Set<String> userRoleIdSet = new Set<String>();
        Set<String> userIdSet = new Set<String>();
        Set<String> permissionSetNameSet = new Set<String>();
        for(User selectedUser : userNewList) {
            if((userOldMap == null || (userOldMap != null && selectedUser.UserRoleId != userOldMap.get(selectedUser.Id).UserRoleId))) {
                userRoleIdSet.add(selectedUser.UserRoleId);
                if(userOldMap != null && userOldMap.get(selectedUser.Id).UserRoleId != null) {
                    userRoleIdSet.add(userOldMap.get(selectedUser.Id).UserRoleId);
                    userIdSet.add(selectedUser.Id);
                }
            }
        }
        if(userRoleIdSet.size() > 0) {
            for(UserRole role : [SELECT Id, Name FROM UserRole WHERE Id IN: userRoleIdSet  ] ) {
                userRoleIdAndNameMap.put(role.Id,role.Name);
            }
            for(User selectedUser : userNewList) {
                if((userOldMap == null || (userOldMap != null && selectedUser.UserRoleId != userOldMap.get(selectedUser.Id).UserRoleId))) {
                    permissionSetNameSet.add(mapRoleAndPermissionSet.get(userRoleIdAndNameMap.get(selectedUser.UserRoleId)));
                    if(userOldMap != null && userOldMap.get(selectedUser.Id).UserRoleId != null ) {
                        permissionSetNameSet.add(mapRoleAndPermissionSet.get(userRoleIdAndNameMap.get(userOldMap.get(selectedUser.Id).UserRoleId)));
                    }
                }
            }
            Map<String,String> permissionSetNameAndIdMap = new Map<String,String>();
            for(PermissionSet permissionSet : [SELECT Id,Name, label FROM PermissionSet WHERE Name IN: permissionSetNameSet]) {
                permissionSetNameAndIdMap.put(permissionSet.Name,permissionSet.Id);
            }
            for(User selectedUser : userNewList) {
                if(mapRoleAndPermissionSet.containsKey(userRoleIdAndNameMap.get(selectedUser.UserRoleId))) {
                    for(PermissionSetLicense selectedPermissionSetLicense : permissionLicenseList) {
                        PermissionSetLicenseAssign psLicense = new PermissionSetLicenseAssign();
                        psLicense.AssigneeId = selectedUser.Id;
                        psLicense.PermissionSetLicenseId = selectedPermissionSetLicense.Id;
                        assignPSLicenseAssingnmentList.add(psLicense); 
                    }
                }
            }
            if(!assignPSLicenseAssingnmentList.isEmpty()){
                Database.insert(assignPSLicenseAssingnmentList,false);
            } 
            if(userIdSet.size() > 0) {
                List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN: userIdSet AND PermissionSet.Name IN: mapRoleAndPermissionSet.values() WITH SECURITY_ENFORCED];
                
                if(PermissionSetAssignment.sObjectType.getDescribe().isDeletable()){
                    delete permissionSetAssignmentList;
                }
            }
            for(User selectedUser : userNewList){
                if((userOldMap == null || (userOldMap != null && selectedUser.UserRoleId != userOldMap.get(selectedUser.Id).UserRoleId)) && mapRoleAndPermissionSet.containsKey(userRoleIdAndNameMap.get(selectedUser.UserRoleId))) {
                    PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                    psAssignment.PermissionSetId = permissionSetNameAndIdMap.get(mapRoleAndPermissionSet.get(userRoleIdAndNameMap.get(selectedUser.UserRoleId)));
                    psAssignment.AssigneeId = selectedUser.Id;
                    assignPSAssingnmentList.add(psAssignment);
                }
            }
            if(!assignPSAssingnmentList.isEmpty()){
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('PermissionSetAssignment', assignPSAssingnmentList, 'insert', true,'NC_UserTriggerHandler','assignPermissions');
                insert decision.getRecords();
            }      
        }
    }

    /*
    *********************************************************
    @Method Name    : validateRegionalCenter
    @description    : method to validate regional center is changed
    @param          : List<User> userNewList
    @return         : void
    ********************************************************
    */
    private static void validateRegionalCenter(List<User> userNewList) {
        for(User selectedUser : userNewList) {
            if(selectedUser.Regional_Center__c != null && selectedUser.Secondary_Regional_Centers__c != null) {
                if(selectedUser.Secondary_Regional_Centers__c.contains(selectedUser.Regional_Center__c)) {
                    selectedUser.addError(selectedUser.Regional_Center__c + ' can not be selected as secondary regional center as it is selected as primary regional center.');
                }
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateInternalAssessor
    @description    : Regional center validation for internal assessor
    @param          : List<User> newList, Map<Id,User> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateInternalAssessor(List<User> newList, Map<Id,User> oldMap) {
        Map<Id,User> userIdMap=new  Map<Id,User>();
        for(User u:newList){
            if(u.Regional_Center__c!=NULL&& u.Regional_Center__c != oldMap.get(u.Id).Regional_Center__c){
                userIdMap.put(u.Id,u);
            }
            
        }
       for(Case cas : [SELECT Id,MatReqStatus__c,Internal_Assessor__c,Status FROM Case WHERE Internal_Assessor__c IN :userIdMap.keySet() WITH SECURITY_ENFORCED]){
             if(cas.Status!='Denied'||cas.MatReqStatus__c!='Closed'){
                userIdMap.get(cas.Internal_Assessor__c).addError('Regional Center Cannot be updated as the Assessor is part of an Open Request.');
             }
        }
     }
     
    /*
    *********************************************************
    @Method Name    : validateAndUpdateGroupMember
    @description    : method to validate regional center is changed - if changed then update Group
    @param          : List<User> userNewList, Map<Id,User> userOldMap
    @return         : void
    ********************************************************
    */
    private static void validateAndUpdateGroupMember(List<User> userNewList, Map<Id,User> userOldMap) {
        Map<String,String> mapRegionalCenterGroups = NC_Constant.mapRegionalCenterGroups;
        Map<String,String> mapRegionalCenterGroupsAA2 = NC_Constant.mapRegionalCenterGroupsAA2;
        Map<String,String> mapRegionalCenterManagerGroup = NC_Constant.mapRegionalCenterManagerGroup;
        Map<String,String> mapRegionalCenterCommunicationAccessManagerGroup = NC_Constant.mapRegionalCenterCommunicationAccessManagerGroup;
        List<User> userToBeAddedToGroup = new List<User>();
        //Validating User Changed its Regional Center
        for(User user : userNewList) {
            if(user.Regional_Center__c != userOldMap.get(user.Id).Regional_Center__c || user.Secondary_Regional_Centers__c != userOldMap.get(user.Id).Secondary_Regional_Centers__c || user.UserRoleId != userOldMap.get(user.Id).UserRoleId) {
                userToBeAddedToGroup.add(user);
            }
        }

        if(!userToBeAddedToGroup.isEmpty()) {
            //Calling add User in group
            List<GroupMember> groupMemberList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE 
                                                    (Group.DeveloperName IN: mapRegionalCenterGroupsAA2.values() OR 
                                                    Group.DeveloperName IN: mapRegionalCenterManagerGroup.values() OR 
                                                    Group.DeveloperName IN: mapRegionalCenterGroups.values() OR 
                                                    Group.DeveloperName IN: mapRegionalCenterCommunicationAccessManagerGroup.values())  
                                                AND UserOrGroupId IN: userToBeAddedToGroup WITH SECURITY_ENFORCED];
            
            if(GroupMember.sObjectType.getDescribe().isDeletable()){
                delete groupMemberList;
            }
            addUserToGroup(userToBeAddedToGroup);
        }
    }
    
    /*
    *********************************************************
    @Method Name    : addUserToGroup
    @description    : method to add user in group
    @param          : List<User> userList
    @return         : void
    ********************************************************
    */
    private static void addUserToGroup(List<User> userList) {
        Map<String,String> mapRegionalCenterGroups = NC_Constant.mapRegionalCenterGroups;
        Map<String,String> mapRegionalCenterGroupsAA2 = NC_Constant.mapRegionalCenterGroupsAA2;
        Map<String,String> mapRegionalCenterManagerGroup = NC_Constant.mapRegionalCenterManagerGroup;
        Map<String,String> mapRegionalCenterCommunicationAccessManagerGroup = NC_Constant.mapRegionalCenterCommunicationAccessManagerGroup;
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Map<String,Id> groupNameAndIdMap = new Map<String,Id>();
        Map<String,String> userRoleIdAndNameMap = new Map<String,String>();
        for(UserRole role : [SELECT Id, Name FROM UserRole WHERE Name = 'Receptionist AA2' OR Name = 'Regional Center Manager' OR Name = 'Communication Access Manager'] ) {
            userRoleIdAndNameMap.put(role.Id,role.Name);
        }
        Map<Id,Profile> profileMap = new Map<Id,Profile>([SELECT Id, Name FROM Profile WHERE Name =: NC_Constant.VENDOR_USER  OR Name =: NC_Constant.PLATFORM_USER]);
        
        //Fethcing Group Name and Id
        for(Group publicGroup : [SELECT Id, Name, DeveloperName FROM Group WHERE Type =: NC_Constant.PUBLIC_GROUP_TYPE AND ( DeveloperName IN: NC_Constant.mapRegionalCenterGroups.values() OR DeveloperName IN: mapRegionalCenterGroupsAA2.values() OR DeveloperName IN: mapRegionalCenterManagerGroup.values() OR DeveloperName = 'Vendors_Group')]) {
            groupNameAndIdMap.put(publicGroup.DeveloperName,publicGroup.Id);
        }
        
        //Adding user to Group Member List
        for(User user : userList) {
            if(user.Regional_Center__c != null) {
                if(mapRegionalCenterGroups.containsKey(user.Regional_Center__c) && groupNameAndIdMap.containsKey(mapRegionalCenterGroups.get(user.Regional_Center__c))) {
                    groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterGroups.get(user.Regional_Center__c)), UserOrGroupId = user.Id));
                    if(userRoleIdAndNameMap.containsKey(user.UserRoleId)) {
                        if(userRoleIdAndNameMap.get(user.UserRoleId) == 'Regional Center Manager') {
                            if(mapRegionalCenterGroupsAA2.containsKey(user.Regional_Center__c)) {
                                groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterGroupsAA2.get(user.Regional_Center__c)), UserOrGroupId = user.Id));
                            }
                            if(mapRegionalCenterManagerGroup.containsKey(user.Regional_Center__c)) {
                                groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterManagerGroup.get(user.Regional_Center__c)), UserOrGroupId = user.Id));
                            }
                        } else if(userRoleIdAndNameMap.get(user.UserRoleId) == 'Receptionist AA2' && mapRegionalCenterGroupsAA2.containsKey(user.Regional_Center__c)) {
                            groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterGroupsAA2.get(user.Regional_Center__c)), UserOrGroupId = user.Id));
                        } else if(userRoleIdAndNameMap.get(user.UserRoleId) == 'Communication Access Manager' && mapRegionalCenterCommunicationAccessManagerGroup.containsKey(user.Regional_Center__c)) {
                            groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterCommunicationAccessManagerGroup.get(user.Regional_Center__c)), UserOrGroupId = user.Id));
                        } 
                    }
                }
            }
            if(user.Secondary_Regional_Centers__c != null) {
                List<String> secondaryRegionalCentersSet = user.Secondary_Regional_Centers__c.split(';');
                for(String regionalCenter : secondaryRegionalCentersSet) {
                    if(mapRegionalCenterGroups.containsKey(regionalCenter) && groupNameAndIdMap.containsKey(mapRegionalCenterGroups.get(regionalCenter))) {
                        groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterGroups.get(regionalCenter)), UserOrGroupId = user.Id));
                        if(userRoleIdAndNameMap.containsKey(user.UserRoleId)) {
                            if(userRoleIdAndNameMap.get(user.UserRoleId) == 'Regional Center Manager') {
                                if(mapRegionalCenterGroupsAA2.containsKey(regionalCenter)) {
                                    groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterGroupsAA2.get(regionalCenter)), UserOrGroupId = user.Id));
                                }
                                if(mapRegionalCenterManagerGroup.containsKey(regionalCenter)) {
                                    groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterManagerGroup.get(regionalCenter)), UserOrGroupId = user.Id));
                                }
                            } else if(userRoleIdAndNameMap.get(user.UserRoleId) == 'Receptionist AA2' && mapRegionalCenterGroupsAA2.containsKey(regionalCenter)) {
                                groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterGroupsAA2.get(regionalCenter)), UserOrGroupId = user.Id));
                            } else if(userRoleIdAndNameMap.get(user.UserRoleId) == 'Communication Access Manager' && mapRegionalCenterCommunicationAccessManagerGroup.containsKey(regionalCenter)) {
                                groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterCommunicationAccessManagerGroup.get(regionalCenter)), UserOrGroupId = user.Id));
                            } 
                        }
                    }
                }
            }
            if(mapRegionalCenterGroups.containsKey('Vendors_Group') && profileMap.containsKey(user.ProfileId)) {
                groupMemberList.add(new GroupMember(GroupId = groupNameAndIdMap.get(mapRegionalCenterGroups.get('Vendors_Group')), UserOrGroupId = user.Id));
            }
        }
        
        //Insert Group Member List
        if(groupMemberList.size() > 0) {
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('GroupMember', groupMemberList, 'insert', true,'NC_UserTriggerHandler','addUserToGroup');
            insert decision.getRecords();
        }
    }
    
    /*
    *********************************************************
    @Method Name    : shareAccountWithUser
    @description    : method to Share Account with User
    @param          : List<User> userList
    @return         : void
    ********************************************************
    */
    public static void shareAccountWithUser(List<User> userList){
        Set<Id> userIdSet = new  Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Profile> communityProfileList = [Select Id,Name from Profile where Name =: NC_Constant.VENDOR_USER WITH SECURITY_ENFORCED];
        if(communityProfileList.size()>0)
            for(User selectedUser : userList){
                if( selectedUser.ProfileId == communityProfileList[0].Id && selectedUser.AccountId != NULL){
                    userIdSet.add(selectedUser.Id);
                    accountIdSet.add(selectedUser.AccountId);
                   }
            }  
        
        if( userIdSet.size() > 0 ){
           insertSharedAccount(userIdSet, accountIdSet);
        }
    }
    
    /*
    *********************************************************
    @Method Name    : insertSharedAccount
    @description    : create Account share record
    @param          : Set<Id> userId, Set<Id> accountIdSet
    @return         : void
    ********************************************************
    */
    @future
    private static void insertSharedAccount(Set<Id> userId, Set<Id> accountIdSet){
        List<AccountShare> accountShareList = new  List<AccountShare>();
        Map<Id,List<Id>> accountParentIdToAccountIdMap = new Map<Id,List<Id>>();
        for(Account accountRecord : [SELECT Id,parentId FROM Account Where Id IN: accountIdSet AND parentId != NULL WITH SECURITY_ENFORCED]){
            if(!accountParentIdToAccountIdMap.containsKey(accountRecord.ParentId)){
                accountParentIdToAccountIdMap.put(accountRecord.ParentId, new List<Id>());
            }
            accountParentIdToAccountIdMap.get(accountRecord.ParentId).add(accountRecord.Id);
        }
        for(User selectedUser : [SELECT Id,AccountId FROM USER WHERE Id IN: userId OR AccountId IN: accountParentIdToAccountIdMap.KeySet()]){
            if(!accountParentIdToAccountIdMap.KeySet().contains(selectedUser.AccountId) ){
                AccountShare accountShareRecord = new AccountShare();
                accountShareRecord.UserOrGroupID = selectedUser.Id;
                accountShareRecord.AccountID = selectedUser.AccountId;
                accountShareRecord.AccountaccessLevel = NC_Constant.EDIT_ACCESS;
                accountShareRecord.OpportunityAccessLevel = NC_Constant.READ_ACCESS;
                accountShareRecord.rowCause = 'Manual';
                accountShareList.add(accountShareRecord);
            }else{
                for(Id accountId : accountParentIdToAccountIdMap.get(selectedUser.AccountId)){
                    AccountShare accountShareRecord = new AccountShare();
                    accountShareRecord.UserOrGroupID = selectedUser.Id;
                    accountShareRecord.AccountID = accountId;
                    accountShareRecord.AccountaccessLevel =  'Read';
                    accountShareRecord.OpportunityAccessLevel = 'Read';
                    accountShareRecord.rowCause = 'Manual';
                    accountShareList.add(accountShareRecord);
                }
                
            }
        }
       
        if( accountShareList.size()>0 ){
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('AccountShare', accountShareList, 'insert', true,'NC_UserTriggerHandler','insertSharedAccount');
            insert decision.getRecords();
        } 
    }

    /*
    *********************************************************
    @Method Name    : updateSecondaryRegionalCenter
    @description    : update secondary regional center
    @param          : List<User> userList
    @return         : void
    ********************************************************
    */
    public static void updateSecondaryRegionalCenter(List<User> userList){
        for(User use:userList){
            if(use.Secondary_Regional_Centers__c!=null){
                use.Secondary_Regional_Center__c = use.Secondary_Regional_Centers__c;
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateSecondaryRegionalCenterupdate
    @description    : update secondary regional center id changed
    @param          : List<User> userNewList, Map<Id,User> userOldMap
    @return         : void
    ********************************************************
    */
        public static void updateSecondaryRegionalCenterupdate(List<User> userNewList, Map<Id,User> userOldMap){
        for(User use:userNewList){
            if(use.Secondary_Regional_Centers__c != userOldMap.get(use.Id).Secondary_Regional_Centers__c){
                use.Secondary_Regional_Center__c = use.Secondary_Regional_Centers__c;
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateCounty
    @description    : update county and regional center
    @param          : List<User> userNewList, Map<Id,User> userOldMap
    @return         : void
    ********************************************************
    */
    public static void updateCounty(List<User> userNewList, Map<Id,User> userOldMap) {
        List<User> userList = new List<User>();
        Set<String> zipCodeSet = new Set<String>();
        Set<String> citySet = new Set<String>();
        Set<String> userRoleSet = new Set<String>{'Deaf_Services_Specialist', 'Deaf_Blind_Services_Specialist'};
        
        for(User userRecord: userNewList) {
            if(userRoleSet.contains(userRecord.Role__c)){
                //&& (userOldMap.get(userRecord.id).City != userRecord.City || userOldMap.get(userRecord.id).PostalCode != userRecord.PostalCode)) {
                userList.add(userRecord);
                zipCodeSet.add(userRecord.PostalCode);
                citySet.add(userRecord.City);
            }
        }
        if(userList.size() > 0) {
            for(Regional_Center_And_County__mdt regionalCenterCountyRecord : [SELECT Id, Regional_Center__c, County__c, City__c, Zip_Code__c, Region__c FROM Regional_Center_And_County__mdt WHERE Zip_Code__c IN: zipCodeSet AND City__c IN: citySet]){
                for(User userRecord : userList) {
                    if(regionalCenterCountyRecord.City__c == userRecord.City && regionalCenterCountyRecord.Zip_Code__c == userRecord.PostalCode) {
                        userRecord.County__c = regionalCenterCountyRecord.County__c;
                        userRecord.Regional_Center__c = regionalCenterCountyRecord.Regional_Center__c;
                    }
                }
            }
        }
    }
}