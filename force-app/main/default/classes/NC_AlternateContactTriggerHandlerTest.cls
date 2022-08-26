/**
* @description       : Test class for NC_AlternateContactTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @group             : 
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_AlternateContactTriggerHandlerTest {
    
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Verify Alternate Contact validation
    ********************************************************
    */
    @isTest
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
        con.LastName='Test Con';
        insert con;
        con.Relationship_Type__c='Parent';
        con.Power_of_Attorney__c=false;
        con.Legal_Guardian__c=true;
        update con;
        
        Contact con2=new Contact();   
        con2.LastName='Testing';
        insert con2;
        con2.Relationship_Type__c='Friend';
        con2.Power_of_Attorney__c=false;
        con2.Legal_Guardian__c=false;
        update con2;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas;
        
        Attendees__c attendess = new Attendees__c();
        // attendess.Trainer_Result__c = acc.Id;
        Insert attendess;
        
        Alternate_Contact__c alt = new Alternate_Contact__c();
        alt.Primary_Alternate_Contact__c = false;
        alt.Consumer__c = con.Id;
        alt.Related_To__c = con2.Id;
        Insert alt;
        alt.Primary_Alternate_Contact__c = true;
        alt.Relationship_Type__c = 'Parent';
        update alt;
        Alternate_Contact__c altCont=[SELECT Id,Relationship_Type__c FROM Alternate_Contact__c];
        System.assertEquals('Parent', altCont.Relationship_Type__c);
        
        Alternate_Contact__c alt1 = new Alternate_Contact__c();
        alt1.Primary_Alternate_Contact__c = false;
        alt1.Consumer__c = con.Id;
        alt1.Related_To__c = con2.Id;
        Insert alt1;
        alt1.Primary_Alternate_Contact__c = true;
        alt1.Relationship_Type__c = 'Friend';
        update alt1;
        System.assertEquals(false, alt1.Email__c!=null);
    }
    
    
}