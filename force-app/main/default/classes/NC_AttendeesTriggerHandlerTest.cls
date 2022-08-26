/**
* @description       : Test class for NC_AttendeesTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_AttendeesTriggerHandlerTest {
    /*
*********************************************************
@Method Name    : makeData
@description    : Verify Attendees validation and related operations
********************************************************
*/
    @TestSetup
    public static void makeData(){
        
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.First_Name__c='Test';
        acc.Last_Name__c= 'first';
        acc.Name = 'few';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        acc.Hearing_Aid_Provider__c = true;
        acc.Is_Vendor_on_Portal__c = true;
        insert acc;
                
        Account vendorAccount = TestDataUtility.createNDBEDPTrainer(true);
        vendorAccount.First_Name__c='Trainer';
        update vendorAccount;
        
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
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas;
        
        
    }
    
    /*
*********************************************************
@Method Name    : insertUserMethod
@description    : Verify Attendees external user creation
********************************************************
*/
    @IsTest
    public static void insertUserMethod(){
      
        Account acc = [SELECT Id,Last_Name__c FROM Account LIMIT 1 FOR UPDATE];
        Contact con = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1 FOR UPDATE];
        Account account=[SELECT Id,First_Name__c FROM Account WHERE First_Name__c='Trainer'];
        
        Contact contact = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name ='NDBEDP Assessor'];

        //UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType ='' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, null);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.ContactId = contact.Id;
        userObj.IsActive = true;
        //userObj.UserRoleId=r.Id;
        
        test.startTest();
        insert userObj;
        test.stopTest();
        
    
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Id infoSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
            Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, infoSessionTypeId, System.now()+1, System.now()+2, 'title', 'test', null);
            
            Id outreachAttendessId = Schema.SObjectType.Attendees__c.getRecordTypeInfosByDeveloperName().get('Attendees_For_Outreach_Request').getRecordTypeId();
            Attendees__c attendees = TestDataUtility.createAttendees(true, outreachAttendessId, outreach.id, con.id, null, null);
            attendees.External_Assessor__c = acc.Id;
            update attendees;
            attendees.External_Assessor__c=null;
            attendees.NDBEDP_Trainer__c=account.Id;
            update attendees;
            System.assertEquals(true,attendees.Contact__c!=null);
        }
    }
      /*
*********************************************************
@Method Name    : insertUserMethodone
@description    : Verify Attendees external user validation
********************************************************
*/
    @IsTest
    public static void insertUserMethodone(){
        Account acc = [SELECT Id,Last_Name__c FROM Account LIMIT 1 FOR UPDATE];
        Contact con = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1 FOR UPDATE];
        
        List<User> internalAssessor=[SELECT Id,Profile.Name,userrole.DeveloperName FROM User WHERE Profile.Name='Specialist' AND userrole.DeveloperName='Deaf_Services_Specialist' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Id infoSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
            Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, infoSessionTypeId, System.now()+1, System.now()+2, 'title', 'test', null);
            
            Id outreachAttendessId = Schema.SObjectType.Attendees__c.getRecordTypeInfosByDeveloperName().get('Attendees_For_Outreach_Request').getRecordTypeId();
            Attendees__c attendees = TestDataUtility.createAttendees(true, outreachAttendessId, outreach.id, con.id, null, null);
            if(internalAssessor.size()>0){
            attendees.Internal_Assessor__c = internalAssessor[0].Id;
            }
            update attendees;
            System.assertEquals(true,attendees.Contact__c!=null);
        }
        
    }
    
    /*
*********************************************************
@Method Name    : insertUserMethod2
@description    : Verify Attendees external user validation
********************************************************
*/
    @IsTest
    public static void insertUserMethod2(){
        Account acc = [SELECT Id,Last_Name__c FROM Account LIMIT 1];
        Contact con = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'NDBEDP Assessor'];
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        // UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, null);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.ContactId = con.Id;
        userObj.IsActive = true;
        //userObj.UserRoleId=portalRole.Id;
        
        test.startTest();
        insert userObj;
        test.stopTest();
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Id infoSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
            Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, infoSessionTypeId, System.now()+1, System.now()+2, 'title', 'test', null);
            
            Id outreachAttendessId = Schema.SObjectType.Attendees__c.getRecordTypeInfosByDeveloperName().get('Attendees_For_NDBEP_Trainer').getRecordTypeId();
            Attendees__c attendees = TestDataUtility.createAttendees(false, outreachAttendessId, outreach.id, con.id, null, null);
            attendees.External_Assessor__c = acc.Id;
            insert attendees;
            System.assertEquals(true,attendees.Contact__c!=null);
        }
        
    }
    
    /*
*********************************************************
@Method Name    : insertUserMethod3
@description    : Verify Attendees external user response to the invitation
********************************************************
*/
    @IsTest
    public static void insertUserMethod3(){
        // Id accountrecordId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NDBEDP_Trainer').getRecordTypeId;
        Id accoutnRecordId = NC_Utility.RecordTypeUtilityMethod('Account','NDBEDP_Trainer');
        Account acc = [SELECT Id,Last_Name__c FROM Account WHERE recordtypeId =:accoutnRecordId LIMIT 1];
        Contact con = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'NDBEDP Assessor'];
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        // UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, null);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.ContactId = con.Id;
        userObj.IsActive = true;
        //userObj.UserRoleId=portalRole.Id;

        test.startTest();
        insert userObj;
        test.stopTest();
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Id infoSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
            Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, infoSessionTypeId, System.now()+1, System.now()+2, 'title', 'test', null);
            
            Id outreachAttendessId = Schema.SObjectType.Attendees__c.getRecordTypeInfosByDeveloperName().get('Attendees_For_NDBEP_Trainer').getRecordTypeId();
            Attendees__c attendees = TestDataUtility.createAttendees(false, outreachAttendessId, outreach.id, con.id, null, null);
            attendees.NDBEDP_Trainer__c = acc.Id;
            insert attendees;
            
            attendees.Trainer_Result__c = 'Accept';
            update attendees;
            
            attendees.Trainer_Result__c = 'Reject';
            update attendees;
            
            System.assertEquals(true,attendees.Contact__c!=null);
            
        }
        
    }
    
    /*
*********************************************************
@Method Name    : insertUserMethod4
@description    : Verify existing Attendees external user 
********************************************************
*/
    @IsTest
    public static void insertUserMethod4(){
        Account acc = [SELECT Id,Last_Name__c FROM Account LIMIT 1];
        Contact con = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        List<Profile> p = [SELECT id FROM Profile WHERE name = 'NDBEDP Assessor'];
        // UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p[0].id, null);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.ContactId = con.Id;
        userObj.IsActive = true;

        List<User> u = [SELECT Id,UserRole.DeveloperName FROM USER WHERE UserRole.DeveloperName='Deaf_Services_Specialist' LIMIT 1];
        
        test.startTest();
        insert userObj;
        test.stopTest();
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Id infoSessionTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Information_Session').getRecordTypeId();
            Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, infoSessionTypeId, System.now()+1, System.now()+2, 'title', 'test', null);
            
            Id outreachAttendessId = Schema.SObjectType.Attendees__c.getRecordTypeInfosByDeveloperName().get('Attendees_For_NDBEP_Trainer').getRecordTypeId();
            Attendees__c attendees = TestDataUtility.createAttendees(false, outreachAttendessId, outreach.id, con.id, null, null);
            if(u.size()>0){
            attendees.Internal_Assessor__c = u[0].Id;
            }
            insert attendees;
            System.assertEquals(true,attendees.Contact__c!=null);
            
        }
        
    }
    
    
}