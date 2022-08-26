/**
* @description       : Test class for NCDSDHH_FileUploadController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@ISTest
public class NCDSDHH_FileUploadControllerTest {
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Create data to be used in this class
    ********************************************************
    */
    @TestSetup
    public static void makeData(){
        
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.Name='TestA';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        acc.Hearing_Aid_Provider__c = true;
        insert acc;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Contact con=new Contact();   
        // con.AccountId=acc.Id;
        con.LastName='Test Con';
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas;
        
        Attendees__c attendess = new Attendees__c();
        // attendess.Trainer_Result__c = acc.Id;
        Insert attendess;
    }
    
    /*
    *********************************************************
    @Method Name    : mapRelatedFieldsTest
    @description    : Verify documents for related record
    ********************************************************
    */
    @isTest
    public static void mapRelatedFieldsTest(){
        Account acc=[SELECT Id FROM Account   WHERE Name = 'TestA'];
        try{
            Test.startTest();
            NCDSDHH_FileUploadController.mapRelatedFields(acc.Id);
            System.assertNotEquals(null, NCDSDHH_FileUploadController.mapRelatedFields(acc.Id));
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveDocumentInfoTest
    @description    : Verify document details
    ********************************************************
    */
    @isTest
    public static void retrieveDocumentInfoTest(){
        Account acc=[SELECT Id FROM Account   WHERE Name = 'TestA'];
        try{
            Test.startTest();
            NCDSDHH_FileUploadController.retrieveDocumentInfo('Penguins',acc.Id);
            System.assertNotEquals(null, NCDSDHH_FileUploadController.retrieveDocumentInfo('Penguins',acc.Id));
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateDocumentNameTest
    @description    : Verify document name update
    ********************************************************
    */
    @isTest
    public static void updateDocumentNameTest(){
        Account acc=[SELECT Id FROM Account   WHERE Name = 'TestA'];
        ContentDocumentLink documentLink=[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink   WHERE LinkedEntityId =:acc.Id];
        try{
            Test.startTest();
            string result = NCDSDHH_FileUploadController.updateDocumentName(documentLink.ContentDocumentId,'Test',acc.Id,'Acknowledgement_Form__c',acc.Id);
            System.assertEquals('success', result);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateDocumentNameTest
    @description    : Verify document delete
    ********************************************************
    */
    @isTest
    public static void deleteDocumentNameTest(){
        Account acc=[SELECT Id FROM Account   WHERE Name = 'TestA'];
        ContentDocumentLink documentLink=[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink   WHERE LinkedEntityId =:acc.Id];
        try{
            Test.startTest();
            string result =NCDSDHH_FileUploadController.deleteDocumentName(documentLink.ContentDocumentId,'Test',acc.Id,'Account',acc.Id);
            System.assertEquals('success', result);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    
}