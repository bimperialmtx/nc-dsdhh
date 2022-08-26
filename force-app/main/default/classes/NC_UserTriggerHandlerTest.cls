/**
* @description       : Test class for NC_UserTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_UserTriggerHandlerTest {
    
    /*
    *********************************************************
    @Method Name    : setupData
    @description    : Create data to be used in this class
    ********************************************************
    */
    @testSetup static void setupData() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Email__c = 'test@gmail.com';
        vendor.Last_Name__c = 'lastname';
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        contact con = TestDataUtility.createConsumer(false);
        con.AccountId = vendor.id;
        insert con;
    }
	
    /*
    *********************************************************
    @Method Name    : validateRegionalCenterTest
    @description    : Verify regional center and secondary regional center for user
    ********************************************************
    */
    static testmethod void validateRegionalCenterTest() {
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Asheville Regional Center';
		userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        try{
            test.startTest();
         	insert userObj;
            test.stopTest();
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    /*
    *********************************************************
    @Method Name    : accountIsVendoronPortalUpdateTest
    @description    : Verify account is on portal
    ********************************************************
    */
    static testmethod void accountIsVendoronPortalUpdateTest() {
        
        Account vendor = [SELECT name FROM Account LIMIT 1 FOR UPDATE];
        Contact con = [SELECT name FROM Contact LIMIT 1 FOR UPDATE];
        Contact contact = [SELECT name FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Vendor Community User Profile' ];
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'Customer User' Limit 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, null);
        userObj.Regional_Center__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.ContactId = contact.Id;
        //userObj.UserRoleId=portalRole.Id;
        test.startTest();
        insert userObj;
        test.stopTest();
        Account account = [SELECT Is_Vendor_on_Portal__c FROM Account LIMIT 1];
        System.assertEquals(true, account.Is_Vendor_on_Portal__c);
    }
    
    /*
    *********************************************************
    @Method Name    : assignPermissionSetTest
    @description    : Verify permission set assignment to user
    ********************************************************
    */
    static testmethod void assignPermissionSetTest() {
        
        Account vendor = [SELECT name FROM Account LIMIT 1];
        Contact con = [SELECT name FROM Contact LIMIT 1];
        
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Manager'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Regional_Center_Manager' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Charlotte Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        insert userObj;
        
        test.startTest();
        userObj.PostalCode = '28371';
        update userObj;
        test.stopTest();
        List<PermissionSetAssignment> ps = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.id =: userObj.id];
		System.assertNotEquals(0, ps.size());
    }
}