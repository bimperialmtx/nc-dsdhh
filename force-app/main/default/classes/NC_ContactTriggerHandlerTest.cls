/**
* @description       : Test class for NC_ContactTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_ContactTriggerHandlerTest {

    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Create data to be used in this class and verify contact validations
    ********************************************************
    */
    	    @IsTest
    public static void makeData(){
    
         Contact con1 = TestDataUtility.createConsumer(false);
         con1.FirstName = 'testing';
         con1.LastName = 'testing';
         con1.County__c = 'Anson';
         Insert con1;
        
        Contact con = TestDataUtility.createConsumer(false);
        con.Cnds_Identifier__c ='956343031K';
        con.Social_Security_Number__c = '1234';
        Insert con;
        con.Name_Change_Document__c = true;
        con.DOB_Document__c = true;
        con.Cnds_Identifier__c = '956343031K';
        con.Ethnicity__c = 'Not Hispanic/Latino';
        con.Alt_Phone_Number__c = '+1 (222) 111-2211';
        con.Cell_Phone_Number__c = '+1 (222) 111-2211';
        con.Captel__c = '+1 (222) 111-2211';
        con.HomePhone = '+1 (222) 111-2211';
        con.MobilePhone = '+1 (222) 111-2211';
        con.TTY__c = '+1 (222) 111-2211';
        con.Video_Phone_Number__c = '+1 (222) 111-2211';
        con.Work_Phone_Number__c = '+1 (222) 111-2211';
        con.Birthdate = Date.valueOf('1981-11-20');
        con.LastName = 'test';
        con.Primary_Alternative_Contact__c = con1.Id;
        con.Relationship_Type__c = 'Parent';
        con.Same_as_Physical__c = true;
        con.Social_Security_Number__c = '4567';
        update con;
        
        con.Birthdate = Date.valueOf('1911-11-20');
        update con;
        con.Birthdate = Date.today();
        con.Relationship_Type__c = 'Friend';
        con.OtherCountry='United States';
        con.OtherCity='city';
        con.Same_as_Physical__c=true;
        update con;
        System.assertEquals(false, con.Is_Name_Updated__c);
    }
}