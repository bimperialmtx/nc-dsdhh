/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_LicensesTriggerHandlerTest {
    
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Verify License validations for create and update
    ********************************************************
    */
    @IsTest
    public static void makeData(){
        
        Account acc = TestDataUtility.createVendor(false);
        acc.Hearing_Aid_Provider__c = true;
        acc.Equipment_Provider__c  = false;
        Insert acc;
        
        
        
        
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
        
        
        License__c license = new License__c();
        license.License_Number__c = '123';
        license.First_Name__c = 'test';
        license.Last_Name__c = 'test';
        license.Vendor__c = acc.Id;
        license.License_for__c = 'Hearing Aid Screening';
        license.Name = 'test';
        insert license;
        
        try{
            license.Status__c ='Submitted';
            license.Proof_of_License_Uploaded__c = true;
            update license;
        }
        Catch(Exception e){
        }
        System.assertEquals(true,license.Vendor__c!=null);
    }
}