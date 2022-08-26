/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_InformationReferralTriggerHandlerTest {

    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Verify Information & Referrals validations on create and update
    ********************************************************
    */
        @IsTest
    public static void makeData(){
        
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Generic');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.Name='Test';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        insert acc;
        
        id recordId1 = NC_Utility.RecordTypeUtilityMethod('Account','Regional_Center');
        Account acc1=new Account();
        acc1.RecordTypeId=recordId1;
        acc1.Email__c='test@gmail.com';
        acc1.Name='Test';
        acc1.BillingCity='city';
        acc1.BillingCountry='United States';
        acc1.BillingState='Alabama';
        acc1.BillingPostalCode='12345';
        acc1.BillingStreet='123 Street';
        acc1.Active__c=true;
        insert acc1;
        
        
        Contact con=new Contact();   
        con.FirstName = 'test';
        con.LastName='TestCon';
        con.Race__c = 'White;Asian';
        con.Birthdate = Date.newInstance(1986, 12, 9);
        con.Cnds_Identifier__c = '956343031K';
        con.MiddleName = 'test';
        con.Suffix = 'Mr';
        con.Gender__c = 'Male';
        con.Ethnicity__c = 'Not Hispanic/Latino';
        con.Hispanic_Ethnicity__c = 'Cuban';
        con.Primary_Language__c = 'Thai';
        con.Status_Code__c = 'T';
        insert con;
        
        Account regAcc = TestDataUtility.createRegionalCenter(true);
        
                
        Information_Type_Count__c infoType = new Information_Type_Count__c();
        infoType.Name = 'DSDHH Regional Centers';
        infoType.Regional_Center__c = regAcc.Id;
        infoType.Count__c = 10;
        insert infoType;
        
		Information_Referral__c information = new Information_Referral__c();
        information.Consumer__c = con.Id;
        information.Regional_Center__c = regAcc.Id;
      // information.Type_of_Information_Given__c = 'DSDHH Regional Centers';
        Insert information;
        
        try{
        Information_Referral__c information1 = new Information_Referral__c();
        information1.Agency__c = acc.Id;
        information1.Type_of_Information_Given__c = 'DSDHH Regional Centers';
        information1.Regional_Center__c = acc1.Id;
        Insert information1;
        

        
        information1.Type_of_Information_Given__c = 'DSDHH Regional Centers;Ruth Eastering Library';
        update information1;
            List <Information_Referral__c > informationList = [SELECT Id FROM Information_Referral__c];
            System.assertNotEquals(0, informationList.size());
        }
        catch(Exception e){
        }

        
     }
}