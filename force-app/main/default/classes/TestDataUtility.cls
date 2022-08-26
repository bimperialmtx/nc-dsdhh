/**
* @description       : Test class Utility to create SMS test records
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class TestDataUtility {

    public static Case createCase() {
		return null;
    }
    
    /*
    *********************************************************
    @Method Name    : createVendor
    @description    : Create vendor to be used in test classes
    @param          : Boolean isInsert
    @return         : Account
    ********************************************************
    */
    public static Account createVendor(Boolean isInsert) {
		Account accObj = new Account();
        accObj.name = 'Test Vendor';
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        accObj.Equipment_Provider__c = true;
        accObj.Vendor_Name__c = 'Test';
        accObj.Tax_Id_Number__c = '123456789';
        accObj.X1099_Payee_Name__c = 'Test';
        accObj.Remit_to_Addr_Ln_1__c = 'Test';
        accObj.Remit_to_State_Cd__c = 'NY';
        accObj.Remit_to_Postal_Cd__c = '12345';
        accObj.W9_Entity_Type__c = 'Corporation - Any';
        accObj.Electronic_Pay_Vendor__c = 'No';
        accObj.ShippingStreet = 'Test';
        accObj.ShippingCity = 'Test';
        accObj.ShippingStateCode = 'NY';
        accObj.ShippingCountryCode = 'US';
        accObj.ShippingPostalCode = '12345';
        accObj.BillingStreet = 'Test';
        accObj.BillingCity = 'Test';
        accObj.BillingStateCode = 'NY';
        accObj.BillingCountryCode = 'US';
        accObj.BillingPostalCode = '12345';
        if(isInsert) {
         	insert accObj;   
        }
        return accObj;
    }
    
    /*
    *********************************************************
    @Method Name    : createNDBEDPTrainer
    @description    : Create NDBEDP Trainer to be used in test classes
    @param          : Boolean isInsert
    @return         : Account
    ********************************************************
    */
    public static Account createNDBEDPTrainer(Boolean isInsert) {
		Account accObj = new Account();
        accObj.name = 'Test Vendor';
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NDBEDP_Trainer').getRecordTypeId();
        accObj.First_Name__c = 'Test';
        accObj.Last_Name__c = 'Test';
        accObj.Email__c = 'test@gmail.com';
        accObj.Vendor_Name__c = 'Test';
        accObj.Tax_Id_Number__c = '123456789';
        accObj.X1099_Payee_Name__c = 'Test';
        accObj.Remit_to_Addr_Ln_1__c = 'Test';
        accObj.Remit_to_State_Cd__c = 'NY';
        accObj.Remit_to_Postal_Cd__c = '12345';
        accObj.W9_Entity_Type__c = 'Corporation - Any';
        accObj.Electronic_Pay_Vendor__c = 'No';
        accObj.ShippingStreet = 'Test';
        accObj.ShippingCity = 'Test';
        accObj.ShippingStateCode = 'NY';
        accObj.ShippingCountryCode = 'US';
        accObj.ShippingPostalCode = '12345';
        accObj.BillingStreet = 'Test';
        accObj.BillingCity = 'Test';
        accObj.BillingStateCode = 'NY';
        accObj.BillingCountryCode = 'US';
        accObj.BillingPostalCode = '12345';
        accObj.Status__c = 'Approved';
        accObj.Active__c = true;
        if(isInsert) {
         	insert accObj;   
        }
        return accObj;
    } 
    
    /*
    *********************************************************
    @Method Name    : createAssessor
    @description    : Create Assessor to be used in test classes
    @param          : Boolean isInsert
    @return         : Account
    ********************************************************
    */
    public static Account createAssessor(Boolean isInsert) {
		Account accObj = new Account();
        accObj.name = 'Test Assesssor';
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Assessor').getRecordTypeId();
        accObj.Job_Title__c = 'test';
        accObj.First_Name__c = 'test';
        accObj.Last_Name__c = 'test';
        accObj.Preferred_Method_of_Contact__c = 'Cell Phone';
        accObj.Cell_Phone__c = '1234567890';
        accObj.BillingCity = 'Test';
        accObj.BillingCountry = 'United States';
        accObj.BillingPostalCode = '12345';
        accObj.BillingState = 'Alabama';
        accObj.BillingStreet = 'Test';
        if(isInsert) {
            insert accObj;
        }
        return accObj;
    }
    
    /*
    *********************************************************
    @Method Name    : createRegionalCenter
    @description    : Create Regional Center to be used in test classes
    @param          : Boolean isInsert
    @return         : Account
    ********************************************************
    */
    public static Account createRegionalCenter(Boolean isInsert) {
        Account rcObj = new Account();
        rcObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regional_Center').getRecordTypeId();
        rcObj.Name = 'Asheville Regional Center';
        rcObj.BillingCity = 'Test';
        rcObj.BillingCountry = 'United States';
        rcObj.BillingPostalCode = '12345';
        rcObj.BillingState = 'Alabama';
        rcObj.BillingStreet = 'Test';
        if(isInsert) {
            insert rcObj;
        }
        return rcObj;
    }
    
    /*
    *********************************************************
    @Method Name    : createConsumer
    @description    : Create Consumer to be used in test classes
    @param          : Boolean isInsert
    @return         : Contact
    ********************************************************
    */
    public static Contact createConsumer(Boolean isInsert) {
        Contact consumer = new Contact();
        consumer.firstName = 'Test';
        consumer.lastName = 'Test';
        consumer.Gender__c = 'Male';
        consumer.Birthdate = Date.valueOf('2000-11-20');
        consumer.Email = 'test@gmail.com';
        consumer.County__c = 'Ashe';
        consumer.Hearing_Disability__c = 'Deaf';
        consumer.MailingStreet = 'Test';
        consumer.MailingCity = 'Test';
        consumer.MailingStateCode = 'NY';
        consumer.MailingCountryCode = 'US';
        consumer.MailingPostalCode = '12345';
        consumer.OtherStreet = 'Test';
        consumer.OtherCity = 'Test';
        consumer.OtherStateCode = 'NY';
        consumer.OtherCountryCode = 'US';
        consumer.OtherPostalCode = '12345';
        consumer.Ethnicity__c = 'Hispanic/Latino';
        consumer.Hispanic_Ethnicity__c = 'Cuban';
        consumer.Social_Security_Number__c = '1234';
        consumer.Proof_of_Income_Uploaded__c = true;
        consumer.Proof_of_Income_Provided_By__c = 'Medicaid';
        consumer.Proof_Of_Residency_Uploaded__c = true;
        consumer.Proof_Of_Residency_Provided_By__c = 'Bank Statement';
        consumer.Income_Range__c = '$0 - $9999';
        consumer.Disability_Determination_form_Uploaded__c = true;
        consumer.Voter_Registration_Form_Uploaded__c = true;
        consumer.Attended_1_1_Consultation__c = true;
        consumer.Attended_Information_Session__c = true;
        consumer.Regional_Center_Office__c = createRegionalCenter(true).id;
        consumer.Race__c = 'White';
        
        if(isInsert){
            insert consumer;
        }
        return consumer;
    }
    
    /*
    *********************************************************
    @Method Name    : createCase
    @description    : Create Case to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id contactId, String requestType, String equipmentTypes
    @return         : Case
    ********************************************************
    */
    public static Case createCase(Boolean isInsert, Id recTypeId, Id contactId, String requestType, String equipmentTypes) {
        Case caseObj = new Case();
        caseObj.contactId = contactId;
        caseObj.RecordTypeId = recTypeId;
        caseObj.Request_Type__c = requestType;
        caseObj.Equipment_Types__c = equipmentTypes;
        caseObj.Status='Submitted';
        if(isInsert) {
            insert caseObj;
        }
        return caseObj;
    }
    
    /*
    *********************************************************
    @Method Name    : createNDBEDPCase
    @description    : Create NDBEDP Case to be used in test classes
    @param          : Boolean isInsert
    @return         : Case
    ********************************************************
    */
    public static Case createNDBEDPCase(Boolean isInsert) {
        Case caseObj = new Case();
        caseObj.contactId = createConsumer(true).id;
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        caseObj.Request_Audience__c = 'Consumer';
        caseObj.Request_Type__c = 'NDBEDP';
        caseObj.Equipment_Types__c = 'NDBEDP';
        caseObj.Audio_Gram__c = true;
        caseObj.Vision_Assessment__c = true;
        if(isInsert) {
            insert caseObj;
        }
        return caseObj;
    }
    
    /*
    *********************************************************
    @Method Name    : createNDBEDPCase
    @description    : Create NDBEDP Case to be used in test classes
    @param          : Boolean isInsert, String contactId
    @return         : Case
    ********************************************************
    */
    public static Case createNDBEDPCase(Boolean isInsert, String contactId) {
        Case caseObj = new Case();
        caseObj.contactId = contactId;
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        caseObj.Request_Audience__c = 'Consumer';
        caseObj.Request_Type__c = 'NDBEDP';
        caseObj.Equipment_Types__c = 'NDBEDP';
        caseObj.Audio_Gram__c = true;
        caseObj.Vision_Assessment__c = true;
        if(isInsert) {
            insert caseObj;
        }
        return caseObj;
    }
    
    /*
    *********************************************************
    @Method Name    : createEquipment
    @description    : Create equipment to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id vendorId, String name, String type, Decimal amount
    @return         : Equipment__c
    ********************************************************
    */
    public static Equipment__c createEquipment(Boolean isInsert, Id recTypeId, Id vendorId, String name, String type, Decimal amount) {
        Equipment__c eqp = new Equipment__c();
        eqp.RecordTypeId = recTypeId;
        eqp.Equipment_Name__c = name;
        eqp.Equipment_Type__c = type;
        eqp.Amount_Authorized__c = amount;
        eqp.Vendor__c = vendorId;
        eqp.IsActive__c = true;
        if(isInsert) {
            insert eqp;
        }
        return eqp;
    }
    
    /*
    *********************************************************
    @Method Name    : createNDBEDPEquipment
    @description    : Create NDBEDP equipment to be used in test classes
    @param          : Boolean isInsert
    @return         : Equipment__c
    ********************************************************
    */
    public static Equipment__c createNDBEDPEquipment(Boolean isInsert) {
        Equipment__c eqp = new Equipment__c();
        eqp.RecordTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        eqp.KlasID__c = 'Test';
        eqp.Equipment_Type__c = 'NDBEDP';
        eqp.Description__c = 'Test';
        eqp.Author__c = 'Test';
        eqp.BibRecObj__c = 'Test';
        eqp.Equipment_Category__c = 'Test';
        eqp.Amount_Authorized__c = 100;
        eqp.Equipment_Name__c = 'Test';
        eqp.ManPartNum__c = 'Test';
        if(isInsert) {
            insert eqp;
        }
        return eqp;
    }
    
    /*
    *********************************************************
    @Method Name    : createRequestEquipment
    @description    : Create request equipment to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id requestId, Id equipmentId
    @return         : Request_Equipment__c
    ********************************************************
    */
    public static Request_Equipment__c createRequestEquipment(Boolean isInsert, Id recTypeId, Id requestId, Id equipmentId) {
        Request_Equipment__c reqEqp = new Request_Equipment__c();
        reqEqp.recordTypeId = recTypeId;
        reqEqp.Equipment__c = equipmentId;
        reqEqp.Request__c = requestId;
        if(isInsert) {
            insert reqEqp;
        }
        return reqEqp;
    }
    
    /*
    *********************************************************
    @Method Name    : createAsset
    @description    : Create asset to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id authId, Id equipmentId, Id requestId
    @return         : Asset__c
    ********************************************************
    */
    public static Asset__c createAsset(Boolean isInsert, Id recTypeId, Id authId, Id equipmentId, Id requestId) {
        Asset__c asset = new Asset__c();
        asset.RecordTypeId = recTypeId;
        asset.Authorization__c = authId;
        asset.Equipment__c = equipmentId;
        asset.Request__c = requestId;
        if(isInsert) {
            insert asset;
        }
        return asset;
    }
    
    /*
    *********************************************************
    @Method Name    : createCheckStatement
    @description    : Create Check Statement to be used in test classes
    @param          : Boolean createVendor, String vendorId, Boolean isInsert
    @return         : C1_Check_Statement__c
    ********************************************************
    */
    public static C1_Check_Statement__c createCheckStatement(Boolean createVendor, String vendorId, Boolean isInsert) {
        if(createVendor) {
            vendorId = createVendor(true).id;
        }
        C1_Check_Statement__c checkStatement = new C1_Check_Statement__c();
        checkStatement.Vendor__c = vendorId;
        if(isInsert) {
         	insert checkStatement;   
        }
        return checkStatement;
    }
    
    /*
    *********************************************************
    @Method Name    : createContentVersion
    @description    : Create ContentVersion to be used in test classes
    @param          : Boolean checkStatement
    @return         : ContentVersion
    ********************************************************
    */
    public static ContentVersion createContentVersion(Boolean checkStatement) {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.Check_Statement__c = checkStatement;
        insert cv;
        return cv;
    }
    
    /*
    *********************************************************
    @Method Name    : createContentDocumentLink
    @description    : Create ContentDocumentLink to be used in test classes
    @param          : Id parentId, Boolean checkStatement
    @return         : void
    ********************************************************
    */
    public static void createContentDocumentLink(Id parentId, Boolean checkStatement) {
        ContentVersion cv = createContentVersion(checkStatement);
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        insert cdl;
    }
    
    /*
    *********************************************************
    @Method Name    : createAuthorization
    @description    : Create Authorization to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id requestId, Id vendorId, Id consumerId
    @return         : Authorization__c
    ********************************************************
    */
    public static Authorization__c createAuthorization(Boolean isInsert, Id recTypeId, Id requestId, Id vendorId, Id consumerId) {
        Authorization__c auth = new Authorization__c();
        auth.recordTypeId = recTypeId;
        auth.Request__c = requestId;
        auth.Vendor__c = vendorId;
        auth.Consumer__c = consumerId;
        if(isInsert) {
            insert auth;
        }
        return auth;
    }
    
    /*
    *********************************************************
    @Method Name    : createAuthorization
    @description    : Create Authorization to be used in test classes
    @param          : Boolean isInsert, Id recTypeId
    @return         : Authorization__c
    ********************************************************
    */
    public static Authorization__c createAuthorization(Boolean isInsert, Id recTypeId) {
        Authorization__c auth = new Authorization__c();
        auth.recordTypeId = recTypeId;
        if(isInsert) {
            insert auth;
        }
        return auth;
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoice
    @description    : Create Invoice to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id authId
    @return         : Invoice__c
    ********************************************************
    */
    public static Invoice__c createInvoice(Boolean isInsert, Id recTypeId, Id authId) {
        Invoice__c invoice = new Invoice__c();
		invoice.recordTypeId = recTypeId;
        invoice.Authorization__c = authId;
        if(isInsert) {
            insert invoice;
        }
        return invoice;
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceLineItem
    @description    : Create Invoice line item to be used in test classes
    @param          : Boolean isInsert, Id invoiceId
    @return         : Invoice_Line_Item__c
    ********************************************************
    */
    public static Invoice_Line_Item__c createInvoiceLineItem(Boolean isInsert, Id invoiceId) {
        Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
        invLineItem.Invoice__c = invoiceId;
        invLineItem.Equipment_Name__c = 'Test';
        invLineItem.Amount_Authorized__c = 1000;
        invLineItem.Amount_Billed__c = 800;
        invLineItem.Amount_to_Pay__c = 800;
        invLineItem.Sequence__c = 1;
        if(isInsert) {
            insert invLineItem;
        }
        return invLineItem;
    }
    
    /*
    *********************************************************
    @Method Name    : createCommunicationAcessRequest
    @description    : Create Communication Access Request to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, String serviceType, String regionalCenter
    @return         : Communication_Access_Request__c
    ********************************************************
    */
    public static Communication_Access_Request__c createCommunicationAcessRequest(Boolean isInsert, Id recTypeId, String serviceType, String regionalCenter) {
        Communication_Access_Request__c car = new Communication_Access_Request__c();
        car.RecordTypeId = recTypeId;
        car.Vendor_Type__c = serviceType;
        car.Regional_Center__c = regionalCenter;
        car.Start_Service_Date_Time__c = System.now() - 2;
        car.End_Service_Date_Time__c = System.now() - 1;
        car.City__c = 'Test';
        if(isInsert) {
            insert car;
        }
        return car;
    }
    
    /*
    *********************************************************
    @Method Name    : createStaffingRequest
    @description    : Create Staffing Request to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id commReqId, String vendorNo
    @return         : Staffing_Request__c
    ********************************************************
    */
    public static Staffing_Request__c createStaffingRequest(Boolean isInsert, Id recTypeId, Id commReqId, String vendorNo) {
        Staffing_Request__c staffRequest = new Staffing_Request__c();
        staffRequest.RecordTypeId = recTypeId;
        staffRequest.Communication_Access_Request__c = commReqId;
        staffRequest.Number_of_Vendors_Needed__c = vendorNo;
        if(isInsert) {
            insert staffRequest;
        }
        return staffRequest;
    }
    
    /*
    *********************************************************
    @Method Name    : createStaffingUserRequest
    @description    : Create Staffing User Request to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id staffRequestId
    @return         : Staffing_User_Request__c
    ********************************************************
    */
    public static Staffing_User_Request__c createStaffingUserRequest(Boolean isInsert, Id recTypeId, Id staffRequestId) {
     	Staffing_User_Request__c staffUserReq = new Staffing_User_Request__c();
        staffUserReq.recordTypeId = recTypeId;
        staffUserReq.Staffing_Request__c = staffRequestId;
        if(isInsert) {
            insert staffUserReq;
        }
        return staffUserReq;   
    }
    
    /*
    *********************************************************
    @Method Name    : createBudgetManagement
    @description    : Create Budget Managemtn to be used in test classes
    @param          : Boolean isInsert, String budgetType
    @return         : Budget_Management__c
    ********************************************************
    */
    public static Budget_Management__c createBudgetManagement(Boolean isInsert, String budgetType) {
        Budget_Management__c budget = new Budget_Management__c();
        budget.Budget_Type__c = budgetType;
        if(System.now().month() >= 7) {
         	budget.Budget_Year__c = System.now().year() + '';
        } else {
            budget.Budget_Year__c = (System.now().year() - 1) + '';
        }
        if(isInsert) {
            insert budget;
        }
        return budget;
    }
    
    /*
    *********************************************************
    @Method Name    : createBudgetAmount
    @description    : Create Budget Amount to be used in test classes
    @param          : Boolean isInsert, Id budgetId, Decimal amount
    @return         : Budget_Amount__c
    ********************************************************
    */
    public static Budget_Amount__c createBudgetAmount(Boolean isInsert, Id budgetId, Decimal amount) {
        Budget_Amount__c budgetAmount = new Budget_Amount__c();
        budgetAmount.Budget_Manager__c = budgetId;
        budgetAmount.Amount__c = amount;
        if(isInsert) {
            insert budgetAmount;
        }
        return budgetAmount;
    }
    
    /*
    *********************************************************
    @Method Name    : createResource
    @description    : Create Resource to be used in test classes
    @param          : Boolean isInsert, String name, String category, Id regionalCenter
    @return         : Resource__c
    ********************************************************
    */
    public static Resource__c createResource(Boolean isInsert, String name, String category, Id regionalCenter) {
        Resource__c resource = new Resource__c();
        resource.name = name;
        resource.Category__c = category;
        resource.Regional_Center__c = regionalCenter;
        resource.Barcode_Printed__c = true;
        resource.Barcode_Affixed__c = true;
        if(isInsert) {
            insert resource;
        }
        return resource;
    }
    
    /*
    *********************************************************
    @Method Name    : createResourceLoan
    @description    : Create Resource Loan to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, String category, Id staffId, Id regionalCenter, Id contactId
    @return         : Resource_Loan__c
    ********************************************************
    */
    public static Resource_Loan__c createResourceLoan(Boolean isInsert, Id recTypeId, String category, Id staffId, Id regionalCenter, Id contactId) {
        Resource_Loan__c resourceLoan = new Resource_Loan__c();
        resourceLoan.recordTypeId = recTypeId;
        resourceLoan.Category__c = category;
        resourceLoan.Staff__c = staffId;
        resourceLoan.Regional_Center__c = regionalCenter;
        resourceLoan.Consumer__c = contactId;
        if(isInsert) {
            insert resourceLoan;
        }
        return resourceLoan;
    }
    
    /*
    *********************************************************
    @Method Name    : createRequestedResoure
    @description    : Create Requested Resource to be used in test classes
    @param          : Boolean isInsert, Id resourceId, Id resourceLoanId, String condition, Date dueDate
    @return         : Requested_Resource__c
    ********************************************************
    */
    public static Requested_Resource__c createRequestedResoure(Boolean isInsert, Id resourceId, Id resourceLoanId, String condition, Date dueDate) {
        Requested_Resource__c reqResource = new Requested_Resource__c();
        reqResource.Resource__c = resourceId;
        reqResource.Resource_Loan__c = resourceLoanId;
        reqResource.Condition_of_Resource__c = condition;
        reqResource.Due_date__c = dueDate;
        if(isInsert) {
            insert reqResource;
        }
        return reqResource;
    }
    
    /*
    *********************************************************
    @Method Name    : createOutreachRequest
    @description    : Create Outreach Request to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, DateTime startTime, DateTime endTime, String title, String address, Id orgName
    @return         : Outreach_Request__c
    ********************************************************
    */
    public static Outreach_Request__c createOutreachRequest(Boolean isInsert, Id recTypeId, DateTime startTime, DateTime endTime, String title, String address, Id orgName) {
        Outreach_Request__c outreach = new Outreach_Request__c();
        outreach.recordTypeId = recTypeId;
        outreach.Start_Date_of_Event__c = startTime;
        outreach.End_Date_of_Event__c = endTime;
        outreach.Title_of_Event__c = title;
        outreach.Address_of_Event__c = address;
        outreach.Organization_Name__c = orgName;
        if(isInsert) {
            insert outreach;
        }
        return outreach;
    }
    
    /*
    *********************************************************
    @Method Name    : createAttendees
    @description    : Create Attendees to be used in test classes
    @param          : Boolean isInsert, Id recTypeId, Id outreachId, Id contactId, Id agencyId, Id vendorId
    @return         : Attendees__c
    ********************************************************
    */
    public static Attendees__c createAttendees(Boolean isInsert, Id recTypeId, Id outreachId, Id contactId, Id agencyId, Id vendorId) {
        Attendees__c attendees = new Attendees__c();
        attendees.recordTypeId = recTypeId;
        attendees.Outreach_Request__c = outreachId;
        attendees.Contact__c = contactId;
        attendees.Agencies__c = agencyId;
        attendees.Vendor__c = vendorId;
        if(isInsert) {
            insert attendees;
        }
        return attendees;
    }
    
    /*
    *********************************************************
    @Method Name    : createMentoringRequest
    @description    : Create Mentoring Request to be used in test classes
    @param          : Boolean isInsert, Id consumerId, Id requestId
    @return         : Mentoring_Request__c
    ********************************************************
    */
    public static Mentoring_Request__c createMentoringRequest(Boolean isInsert, Id consumerId, Id requestId) {
        Mentoring_Request__c mentoringReq = new Mentoring_Request__c();
        mentoringReq.Consumer__c = consumerId;
        mentoringReq.Request__c = requestId;
        if(isInsert) {
            insert mentoringReq;
        }
        return mentoringReq;
    }
    
    /*
    *********************************************************
    @Method Name    : createAttachment
    @description    : Create Attachment to be used in test classes
    @param          : Boolean isInsert, Id parentId, String body, String contentType, String name, String description
    @return         : Attachment
    ********************************************************
    */
    public static Attachment createAttachment(Boolean isInsert, Id parentId, String body, String contentType, String name, String description) {
        Attachment a = new Attachment();
        a.ParentId = parentId;
        a.Body = EncodingUtil.base64Decode(body);
        a.ContentType = contentType;
        a.Name = name;
        a.Description = description;
        if(isInsert) {
            insert a;
        }
        return a;
    }
    
    /*
    *********************************************************
    @Method Name    : createFile
    @description    : Create ContentDocumentLink to be used in test classes
    @param          : Id parentId, String pathOnClient, String title, String body
    @return         : ContentDocumentLink
    ********************************************************
    */
    public static ContentDocumentLink createFile(Id parentId, String pathOnClient, String title, String body) {
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = pathOnClient;
        conVer.Title = title;
        conVer.VersionData = EncodingUtil.base64Decode('body');
        insert conVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = parentId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;
        return conDocLink;
    }
    
    /*
    *********************************************************
    @Method Name    : createUser
    @description    : Create User to be used in test classes
    @param          : Boolean isInsert, String firstName, String lastName, String email, String username, String alias, Id profileId, Id roleId
    @return         : User
    ********************************************************
    */
    public static User createUser(Boolean isInsert, String firstName, String lastName, String email, String username, String alias, Id profileId, Id roleId) {
        User userObj = new User(
            ProfileId = profileId,
            UserRoleId = roleId,
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Username = username,
            CompanyName = 'TEST',
            Title = 'title',
            Alias = alias,
            TimeZoneSidKey = 'America/new_york',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        if(isInsert) {
            insert userObj;
        }
        return userObj;
    }
    
    /*
    *********************************************************
    @Method Name    : createGroup
    @description    : Create Group to be used in test classes
    @param          : Boolean isInsert, String name, String grpType
    @return         : Group
    ********************************************************
    */
    public static Group createGroup(Boolean isInsert, String name, String grpType){
        Group grp = new Group();
        grp.name = name;
        grp.Type = grpType;
        
        if(isInsert) {
        	insert grp;   
        }
        return grp;
    }
    
    /*
    *********************************************************
    @Method Name    : createGroupMember
    @description    : Create GroupMember to be used in test classes
    @param          : Boolean isInsert, Id userId, Id grpId
    @return         : GroupMember
    ********************************************************
    */
    public static GroupMember createGroupMember(Boolean isInsert, Id userId, Id grpId){
        GroupMember grpMem = new GroupMember();
        grpMem.UserOrGroupId = userId;
        grpMem.GroupId = grpId;
        if(isInsert) {
         	insert grpMem;   
        }
        return grpMem;
    }
    
    /*
    *********************************************************
    @Method Name    : createClientArchive
    @description    : Create client Archieve to be used in test classes
    @param          : Boolean isInsert, Id contactId
    @return         : Client_Archive__c
    ********************************************************
    */
    public static Client_Archive__c createClientArchive(Boolean isInsert, Id contactId) {
        Client_Archive__c ca = new Client_Archive__c();
        ca.Consumer__c = contactId;
        if(isInsert) {
            insert ca;
        }
        return ca;
    }
    
    /*
    *********************************************************
    @Method Name    : createInformationReferral
    @description    : Create Information Referral to be used in test classes
    @param          : Boolean isInsert, Id contactId
    @return         : Information_Referral__c
    ********************************************************
    */
    public static Information_Referral__c createInformationReferral(Boolean isInsert, Id contactId) {
        Information_Referral__c ir = new Information_Referral__c();
        ir.Consumer__c = contactId;
        if(isInsert) {
            insert ir;
        }
        return ir;
    }
    
    /*
    *********************************************************
    @Method Name    : createAlternateContact
    @description    : Create Alternate Contact to be used in test classes
    @param          : Boolean isInsert, Id contactId
    @return         : Alternate_Contact__c
    ********************************************************
    */
    public static Alternate_Contact__c createAlternateContact(Boolean isInsert, Id contactId) {
        Alternate_Contact__c ac = new Alternate_Contact__c();
        ac.Consumer__c = contactId;
        if(isInsert) {
            insert ac;
        }
        return ac;
    }
    
    /*
    *********************************************************
    @Method Name    : createError
    @description    : Create Error to be used in test classes
    @param          : Boolean isInsert, Id contactId
    @return         : Error__c
    ********************************************************
    */
    public static Error__c createError(Boolean isInsert, Id contactId) {
        Error__c error = new Error__c();
        error.Consumer__c = contactId;
        if(isInsert) {
            insert error;
        }
        return error;
    }
    
    /*
    *********************************************************
    @Method Name    : createFamilyDetails
    @description    : Create Family Details to be used in test classes
    @param          : Boolean isInsert, Id requestId
    @return         : Family_Details__c
    ********************************************************
    */
    public static Family_Details__c createFamilyDetails(Boolean isInsert, Id requestId, Id contactId) {
        Family_Details__c family = new Family_Details__c();
        family.Request__c = requestId;
        family.Contact__c = contactId;
        family.Name__c = 'test';
        family.Age__c = 25;
        family.Relationship__c = 'test';
        family.Alimony__c = 100;
        family.AmeriCorps_Stipends__c = 100;
        family.Annuities__c = 0;
        family.Armed_Forces_pay__c = 0;
        family.Cherokee_Tribal_per_captia_Income_paid_t__c = 0;
        family.Child_support__c = 0;
        family.Gross_salary_and_wages__c = 0;
        family.On_the_Job_training__c = 0;
        family.Rental_Income__c = 0;
        family.Retirement_Pension__c = 0;
        family.Social_Security__c = 0;
        family.Tobacco_buy_out_payments__c = 0;
        family.Unemployment__c = 0;
        family.Veteran_Administration_Benefits__c = 0;
        family.Work_Release_Payments__c = 0;
        family.Worker_s_Compensation_payments__c = 0;
        family.Adjustments__c = 0;
        if(isInsert) {
            insert family;
        }
        return family;
    }
}