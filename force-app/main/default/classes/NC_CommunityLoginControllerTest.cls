/**
* @description       : Test class for NC_CommunityLoginController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CommunityLoginControllerTest {

    /*
    *********************************************************
    @Method Name    : isContactExistTest
    @description    : Verify if contact already exist in system else register and create new contact
    ********************************************************
    */
    static testmethod void isContactExistTest() {
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Email__c = 'test@gmail.com';
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(false);
        con.AccountId = vendor.id;
        insert con;
        
        NC_CommunityLoginController.ContactWrapper wrap = new NC_CommunityLoginController.ContactWrapper();
        wrap.ssn = '1234';
        wrap.dob = Date.valueOf('2000-11-20');
        wrap.email = 'test@gmail.com';
        wrap.firstName = 'Test';
        wrap.middleName = '';
        wrap.lastName = 'Test';
        wrap.userName = 'test@gmail.com';
        wrap.password = 'test';
        wrap.confirmPassword = 'test';

		Test.startTest();  
        NC_CommunityLoginController.ContactInfoWrapper result1 = NC_CommunityLoginController.isContactExist(JSON.serialize(wrap));
        System.assertNotEquals(null, result1);
        
        NC_CommunityLoginController.ContactInfoWrapper result2 = NC_CommunityLoginController.registerUser(JSON.serialize(wrap));
        System.assertNotEquals(null, result2);
        
        NC_CommunityLoginController.ContactInfoWrapper result3 = NC_CommunityLoginController.logInUser(JSON.serialize(wrap));
        System.assertNotEquals(null, result3);
        
        String result4 = NC_CommunityLoginController.forgotPassword(JSON.serialize(wrap));
        System.assertNotEquals(null, result4);
        Test.stopTest();
    }
}