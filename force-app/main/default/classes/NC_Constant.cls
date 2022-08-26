/*
*   Class Name: NC_Constant
*   Description: Constants Varibale to use in complete customization 
*
*   Date            New/Modified         User                 Identifier                Description
*   27/04/2020         New         Shubham Dadhich(mtx)
*/

public with sharing class NC_Constant {
    
    public static String RegionalCenter_Asheville_Regional_Center = 'Asheville Regional Center';
    public static String RegionalCenter_Charlotte_Regional_Center = 'Charlotte Regional Center';
    public static String RegionalCenter_Greensboro_Regional_Center ='Greensboro Regional Center';
    public static String RegionalCenter_Morganton_Regional_Center = 'Morganton Regional Center';
    public static String RegionalCenter_Raleigh_Regional_Center = 'Raleigh Regional Center';
    public static String RegionalCenter_Wilmington_Regional_Center ='Wilmington Regional Center';
    public static String RegionalCenter_Wilson_Regional_Center = 'Wilson Regional Center';
    public static String Request_Status_Pending_Condition_of_Acceptance = 'Pending Condition of Acceptance';
    public static String Profile_StandardUser = 'Standard User';
    public static String Account_Regional_Center_RecordType = 'Regional_Center';
    public static String Account_Vendor_RecordType = 'Vendor';
    public static String Case_Equipment_RecordType = 'Equipment';
    public static String CASE_STATUS_APPROVED = 'Approved';
    public static String COMMUNICATION_ACCESS_STATUS_APPROVED = 'Approved';
    public static String Equipment_Justification_Error_Message = Label.Equipment_Justification_Error_Message;
    public static String EQUIPMENT_TYPE_HEARING_AID = 'Hearing Aid';
    public static String VENDOR_COMMUNITY_PROFILE = 'Vendor Profile';
    public static String ASSET_GENERIC_RECORD_TYPE = 'Generic_Asset';
    public static String ASSET_REPLACEMENT_RECORD_TYPE = 'Replacement_Asset';
    public static String ASSET_STATUS_EQUIPMENT_DEFECTIVE = 'Equipment Defective';
    public static String ASSET_STATUS_EQUIPMENT_UNAVAILABLE = 'Equipment Unavailable';
    public static String ASSET_RECORD_VALIDATION_ERROR = 'Replacement Asset only be created for Defective or Unavailable Asset';
    public static String Duplicate_Equipment_Error_Message = 'Duplicate Equipment.';
    public static String ACCOUNT_PENDING_APPROVAL = 'Pending Approval';
    public static String CASE_REGIONAL_CENTER_AUDIT_STATUS = 'Regional Center Audit';
    public static String CASE_TRIGGER_ERROR_CONDITION_ACCECPTANCE = 'Condition of Acceptance needs to be uploaded.';
    public static String CASE_PENDING_EDS_PROGRAM_COORDINATOR_STATUS = 'Pending EDS Program Coordinator';
    public static String CASE_PENDING_EDS_PROGRAM_ASSISTANT_ERROR_MESSAGE = 'EDS Program Assistant Audit Recommendations and Comments are required.'; 
    public static String PUBLIC_GROUP_TYPE = 'Regular';    
    public static String CUSTOMER_COMMUNITY_PLUS_USER = 'Customer Community Plus User';
    public static String VENDOR_USER = 'Vendor Community User Profile';
    public static String PLATFORM_USER = 'Platform User';
    public static String EDIT_ACCESS = 'Edit';
    public static String READ_ACCESS = 'Read';
    public static String SHARING_ROW_COUSE = 'ImplicitPerson';
    public static String APPROVED = 'Approved';
    public static String APPOINTMENT_EXIST_ERROR_MESSAGE = 'Appointment already exist for this Authorization.';
    public static String AUTHORIZATION_SHIP_TO_NOT_APPLICABLE = 'Not Applicable';
    public static String EQUIPMENT_TYPE_WEATHER_RADIO = 'Weather Radio';
    public static String EMAIL_PPREFERRED_CONTACT = 'Email';
    public static String VENDOR_SUBJECT_AUTHORIZATION = 'Authorization for (Equipment)';
    public static String CONSUMER_SUBJECT_AUTHORIZATION = 'Your (equipment) has been approved!';
    public static String VENDOR_BODY_AUTHORIZATION = 'Dear Vendor, Attached is the official authorization for (equipment) for (client name).  Please contact your (local) regional center for any questions about this authorization.';
    public static String CONSUMER_BODY_AUTHORIZATION = 'Your application for (equipment(s)) have been approved.  Your approval letter is attached.  Please keep it for your files.  Please contact your (local) regional center if you have any questions or concerns and use this letter as reference.';
    public static String STATUS_INITIAL_REQUEST_APPROVED = 'Initial Request Approved';
    public static String STATUS_PENDING_PUBLIC_COMMUNICATION_REVIEW = 'Pending Public Communication Review';
    public static String STATUS_INITIAL_REQUEST_REVIEW = 'Initial Request Review';
    public static String OUTREACH_REQUEST_TRIGGER_ERROR_STATUS = 'Status should be Initial Request Approved.';
    public static String OUTREACH_REQUEST_TRIGGER_ERROR_PA2FORM = 'PA2 Form should be checked.';
    public static String OUTREACH_REQUEST_TRIGGER_ERROR_JUSTIFICATION_NOT_NULL = 'Event Date less than 45 days so please provide justification for Event Approval.';
    public static String OUTREACH_REQUEST_TRIGGER_ERROR_PUBLIC_COMMUNICATION_UPLOAD = 'Public Communication Document Should Be Uploaded.';
    public static String STATUS_PENDING_EVENT_APPROVAL = 'Pending Events Approval Committee Review';
    public static String STATUS_PUBLIC_COMMUNICATION_DIRECTOR_REVIEW ='Pending Public Communication Director Review';
    public static String CASE_STATUS_DENIED = 'Denied';
    public static String REQUEST_DENIED_EMAIL_BODY = 'Request is denied please contact to system admin and find attachment.';
    public static String REQUEST_DENIED_EMAIL_SUBJECT = 'Your Request is Denied';
    public static String ASSET_STATUS_CANCELED = 'Cancelled';
    public static String AUTHORIZATION_STATUS_CANCELED = 'Cancelled'; 
    public static String EVENT_ATTRIBUTE_STATUS_CREATED = 'Created';
    public static String EVENT_ATTRIBUTE_STATUS_REGIONAL_CENTER_REVIEW = 'Pending Approval';
    public static String EVENT_ATTRIBUTE_TRIGGER_ERROR_PUBLIC_COMMUNICATION_UPLOAD = 'Public Communication Document Should Be Uploaded.';
    public static String EVENT_ATTRIBUTE_TRIGGER_ERROR_PA2_FORM = 'PA2 Form Should Be Uploaded';
    public static String INVOICE_STATUS_CREATED = 'Created';
    public static String INVOICE_NDBEDP_ASSESSMENT = 'Assessment';
    public static String INVOICE_NDBEDP_ASSESSOR_TRAINING = 'Assessor_Training_Installation';
    public static String INVOICE_NDBEDP_EQUIPMENT = 'Equipment';
    public static String INVOICE_NDBEDP_TRAINING = 'NDBEDP_Training';
    public static String INVOICE_NDBEDP_FOLLOWUP = 'NDBEDP_Follow_Up';
    public static String INVOICE_NDBEDP_PICK_UP = 'NDBEDP_Pick_up';
    public static String INVOICE_NDBEDP_DELIVERY = 'NDBEDP_Delivey';
    public static String INVOICE_NDBEDP_ADDITIONAL_TRAINING = 'NDBEDP_Additional_Training';
	public static String INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_COORDINATOR_COMMENT = 'Please provide the NDBEDP Administrator comment before approval';
    public static String INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_TRP_MANAGER_COMMENT = 'Please provide the NDBEDP TRP manager comment before approval';
    public static String INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_COMMENT_REJECT = 'Please provide the NDBEDP Administrator comment before Reject';
    public static String INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_TRP_MANAGER_COMMENT_REJECT = 'Please provide the TRP Manager comment before Reject';
    public static String INVOICE_TRIGGER_ERROR_MANUFACTURE_INVOICE_UPLOADED = 'Manufacture Invoice document should be uploaded.';
    public static String INVOICE_TRIGGER_ERROR_VENDOR_INVOICE_UPLOADED = 'Vendor Invoice document should be uploaded.';
    public static String NDBEDP_TRIGGER_ERROR_NDBEDP_TRAINER_UPLOADED = 'NDBEDP Trainer document should be uploaded.';
    public static String INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT = 'Pending EDS Program Assistant';
    public static String CONSUMER_STATUS_PENDING_APPROVAL = 'Pending Approval';
    public static String CONSUMER_STATUS_PENDING_DOCUMENT = 'Pending Documents';
    public static String INVOICE_RECORDTYPE_WEATHER_RADIO = 'Weather_Radio';
    public static String INVOICE_RECORDTYPE_HEARING_AID = 'Hearing_AID';
    public static String INVOICE_RECORDTYPE_EDS_INVOICE = 'EDS';
    public static String INVOICE_RECORDTYPE_SUB_HEARING_AID = 'Sub_Hearing_AID';
    public static String AUTHORIZATION_RECORDTYPE_CAPTEL = 'CAPTEL';
    public static String AUTHORIZATION_RECORDTYPE_WEATHER_RADIO = 'Weather_Radio';
    public static String AUTHORIZATION_RECORDTYPE_HEARING_AID = 'Hearing_AID';
    public static String AUTHORIZATION_RECORDTYPE_EDS_INVOICE = 'EDS';
    public static String AUTHORIZATION_RECORDTYPE_EQUIPMENT_INVOICE = 'Equipment';
    public static String AUTHORIZATION_RECORDTYPE_SUB_HEARING_AID = 'Sub_Hearing_AID';
    public static String AUTHORIZATION_RECORDTYPE_COMMUNICATION = 'Communication_Access_Request';
    public static String AUTHORIZATION_RECORDTYPE_ASSESSOR = 'Assessment';
    public static String AUTHORIZATION_RECORDTYPE_ASSESSOR_TRAINING = 'Assessor_Training_Installation';
    public static String AUTHORIZATION_RECORDTYPE_EQUIPMENT = 'Equipment';
    public static String AUTHORIZATION_RECORDTYPE_NDBEDP_TRAINING = 'NDBEDP_Training';
    public static String AUTHORIZATION_RECORDTYPE_NDBEDP_PICK_UP = 'NDBEDP_Pick_up';
    public static String AUTHORIZATION_RECORDTYPE_NDBEDP_DELIVERY = 'NDBEDP_Delivey';
    public static String COMMUNICATION_ACCESS_REQUEST = 'Communication_Access_Request';
    public static String INVOICE_RECORDTYPE_COMMUNICATION = 'Communication_Access_Request';
    public static String INVOICE_TRIGGER_ERROR_TRACKING_NUMBER = 'Tracking number is required';
    public static Integer APPROVAL_DAYS_FOR_HEARING_AID_INVOICE = 61;
    public static Integer APPROVAL_DAYS_FOR_WEATHER_RADIO_INVOICE = 31;
    public static Integer APPROVAL_DAYS_FOR_OTHERS_INVOICE = 46;
    public static Integer APPROVAL_DAYS_FOR_RETURN_WEATHER = 30;
    public static Integer APPROVAL_DAYS_FOR_RETURN_OTHERS = 45;
    public static String INVOICE_TRIGGER_ERROR_SUBMIT_APPROVAL_DAYS = 'Please submit invoice on ';
    public static String AUTHORIZATION_STATUS_RETURNED = 'Returned';
    public static String INVOICE_STATUS_RETURNED = 'Returned';
    public static String ASSET_STATUS_RETURNED = 'Returned';
    public static String AUTHORIZATION_TRIGGER_ERROR_RETURN_DAYS_OTHERS = 'You can not return Authorization after 45 Days of Signed.';
    public static String AUTHORIZATION_TRIGGER_ERROR_RETURN_DAYS_WEATHER = 'You can not return Authorization after 30 Days of Signed.';
    public static String INVOICE_TRIGGER_ERROR_CONSUMER_SIGNED_DATE = 'Consumer Signed Date on Should Be Populated On Related Authorization Record.';
    public static String INVOICE_TRIGGER_ERROR_CONSUMER_SIGNED_DATE_HA = 'Consumer signed date is required before submitting invoice for approval.';
    public static String HEARING_AID_SUB_ITEM_CUSTOM_EAR_MOLD_IMPERSSION = 'Custom Ear Mold Impression';
    public static String HEARING_AID_SUB_ITEM_CUSTOM_DISPENSING_FEE = 'Dispensing Fee';
    public static String EVENT_ATTRIBUTE_STAFF_ATTENDING = 'Staff_Attending';
    public static String EVENT_ATTRIBUTE_NO_ATTENDEE_ERROR_MESSAGE = 'At least one attendee needs to be added before submitting for approval.';
    public static String ASSET_STATUS_EQUIPMENT_UNAVAIBALE = 'Equipment Unavailable';
    public static String VENDOR_TYPE_INTERPRETOR = 'Interpreters';
    public static String VENDOR_TYPE_NDBEDP_INTERPRETOR = 'NDBEDP Interpreters';
    public static String VENDOR_TYPE_SSP = 'SSP';
    public static String VENDOR_TYPE_NDBEDP_SSP = 'NDBEDP SSP';
    public static String VENDOR_TYPE_CART = 'CART';
    public static String VENDOR_TYPE_NDBEDP_CART = 'NDBEDP CART';
    public static String COMMUNICATION_REQUEST_SSP_EXIST_TRIGGER = 'SSP already exist on the Outreach, You can create only one SSP record under this Outreach.';
    public static String COMMUNICATION_REQUEST_INTERPRETER_EXIST_TRIGGER = 'Interpreter already exist on the Outreach, You can create only one Interpreter record under this Outreach.';
    public static String COMMUNICATION_REQUEST_CART_EXIST_TRIGGER = 'CART already exist on the Outreach, You can create only one CART record under this Outreach.';
    public static String STANDARD_PROFILE_NAME = 'Platform User';
    public static String AUTHORIZATION_STATUS_HOLD = 'Hold';
    public static String INVOICE_STATUS_HOLD = 'Hold';
    public static String HEARING_AID_BUDGET = 'Hearing Aid Budget';
    public static String CAPTEL ='CAPTEL Budget';
    public static String WEATHER_RADIO_BUDGET = 'Weather Radio Budget';
    public static String NDBEDP_BUDGET = 'NDBEDP Budget';
    public static String OTHERS_RADIO_BUDGET = 'Telecommunication Budget';
    public static String SSP_BUDGET = 'SSP Budget';
    public static String CART_BUDGET = 'CART Budget';
    public static String INTERPRETERS_BUDGET = 'Interpreters Budget';
    public static String TRAININGVENDOR_BUDGET = 'Training Vendor Budget';
    public static String INVOICE_PAID_STATUS = 'Paid';
    public static String BUDGET_NOTIFIER_BODY = 'Your budget is approching to the 10% or lower please upgrade your budget to procced furtur with Authorization. <br/> Here is your link: ';
    public static String BUDGET_UPDATED_NOTIFIER_BODY = 'Your budget is approching to the 10% or lower please upgrade your budget to procced furtur with Authorization. <br/> Here is your link: ';
    public static String COMMUNICATION_ACCESS_NON_DHH_OUTREACH = 'Request_for_Non_DHH_Outreach';
    public static String STAFF_USER_REQUEST_STATUS_APPROVED = 'Staff Approved';
    public static String STAFF_REQUEST_RECORD_TYPE_EXTERNAL = 'External_Staff';
    public static String EXTERNAL_AUTHORIZATION_SUBJECT = 'Authorization created for you!';
    public static String EXTERNAL_AUTHORIZATION_BODY = 'Find an attached document.';
    public static String INTERPRETER_TYPE_INDIVIDUAL = 'Individual';
    public static String INTERPRETER_TYPE_AGENCY = 'Agency';
    public static String AMOUNT_AUTHORIZED_TYPE_INSTATE = 'In State';
    public static String AMOUNT_AUTHORIZED_TYPE_OUTSTATE = 'Out State';
    public static String INVOICE_LINE_ITEM_HOTELS = 'Hotels';
    public static String INVOICE_LINE_ITEM_BREAKFAST = 'Breakfast';
    public static String INVOICE_LINE_ITEM_DINNER = 'Dinner';
    public static String INVOICE_LINE_ITEM_LUNCH = 'Lunch';
    public static String INVOICE_LINE_ITEM_MILEAGE = 'Mileage';
    public static String INVOICE_LINE_ITEM_PARKING = 'Parking';
    public static String INVOICE_LINE_ITEM_EXCESS_HOTEL = 'Excess Hotel Cost';
    public static String INVOICE_LINE_ITEM_STANDARD_RATE = 'Standard Rate';
    public static String RESOUCE_FIELD_CATEGORY = 'Category__c';
    public static String RESOUCE_FIELD_REGIONAL_CENTER = 'Regional_Center__c';
    public static String RESOURCE_BARCODE_NOT_VALID = 'Not a valid resource barcode number.';
    public static String RETURN_RESOURCE_STATUS_UNAVAILABLE = 'Unavailable';
    public static String RETURN_RESOURCE_STATUS_INACTIVE = 'Inactive';
    public static String RESOURCE_SHOULD_BE_OF_SAME_REGIONAL_CENTER = 'Resource needs to be of same regional center as it is on resource loan request.';
    public static String RESOURCE_STATE_CHECKEDOUT = 'Checked-Out';
    public static String RESOURCE_STATE_CHECKEDIN = 'Checked-In';
    public static String RESOURCE_NOT_CHECKOUT = 'You can not check-in a resource if it is not checked out.';
    public static String RETURN_RESOURCE_STATUS_GOOD = 'Good';
    public static String RETURN_RESOURCE_STATUS_AVAILABLE = 'Available';
    public static String STAFFING_USER_REQUEST_INTERNAL = 'Internal_Staffing_User_Request';
    public static String STAFFING_USER_REQUEST_EXTERNAL = 'External_Staffing_User_Request';
    public static String STAFFING_REQUEST_INTERNAL = 'Internal_Staff';
    public static String STAFFING_USER_REQUEST_STATUS_VENDOR_APPROVED = 'Vendor Approved';
    public static String COMMUNICATION_ACCESS_RECORD_TYPE_DHH = 'Generic_Request';
    public static String CANCEL_STATUS_AUTTHORIZATION_BY_DHH = 'Cancelled by DSDHH (More than 24hrs)';
    public static String CANCEL_STATUS_AUTTHORIZATION_WEATHER = 'Cancelled due to Weather';
    public static String CANCEL_STATUS_AUTTHORIZATION_CANCELLED = 'Cancelled within 24 hrs';
    public static String CANCEL_STATUS_AUTTHORIZATION_ASSIGNMENT = 'Assignment Cancelled (In route/Arrived)';
    public static String CANCELED_CART_ERROR_MESSAGE = 'Can not create Invoice if Authorization is Canceled';
    public static String CANCELED_INTERPRETER_ERROR_MESSAGE_DHH = 'Can not create Invoice if Authorization is Canceled';
    public static String METADATA_ALL_INCLUSIVE_FLAT_FEE = 'All Inclusive Flat Fee';
    public static String STANDARD_RATE_AGENCY = 'Standard Rate';
    public static String ENHANCED_RATE_AGENCY = 'Enhanced Rate';
    public static String INVOICE_STATUS_PENDING_APPROVAL = 'Pending Approval';
    public static String INVOICE_LINE_ITEM_ENHANCED_RATE = 'Enhanced Rate';
    public static String INVOICE_CART_CANT_BE_CREATED_AFTER_THIRTY_DAYES = 'CART cannot invoice if the Service End date was 30 days ago.';
    public static String INVOICE_ALREADY_PRESENT = 'Invoice Already Present.'; 
    public static String EQUIPMENT_TYPE_SUB_HEARING_AID = 'Sub Hearing AID';
    public static String AUTHORIZATION_NO_COSt_RECORDTYPE = 'No_Cost';
    public static String AUTHORIZATION_EQUIPMENT_RECORDTYPE = 'Equipment';
    public static String STATUS_ASSET_EQUIPMENT_REASSIGNMENT = 'Available For Reassignment';
    public static String USER_IS_INACTIVE = 'This is user is inactive or not exist pklease contact to System Admin for more Help';
    public static String SITE_BASE_URL = System.Label.Site_Base_URL;
    public static String AFTER_LOGIN_URL = '/s';
    public static String NCDHHS_ACCOUNT_ID = System.Label.NCDHHS_ACCOUNTA_ID;
    public static String USER_ALREADY_EXISTS = 'Username Already Exist, please try another one!';
    public static String RESOURCE_LOAN_STATUS = 'Waitlist';
    public static String HIGH_PRIORITY = 'High';
    public static String RESOURCE_CATEGORY_MATERIAL = 'Material/Media';
    public static String STATUS_PENDING_SHIPMENT = 'Pending Shipment';
    public static string VENDOR_TYPE_TRAINING_VENDOR = 'Training Vendor';
    public static string INVOICE_UPDATE_IN_PROGRESS = Label.Vendor_Update_in_Progress;
    public static string STAFFREQUEST_UPDATE_IN_PROGRESS = 'Staffing User Request is locked as Vendor update in progress';


    public static map<String,String> mapRoleAndPermissionSet
    {
        get
        {
            if (mapRoleAndPermissionSet == null)
            {
                mapRoleAndPermissionSet = new map<String,string>();
                mapRoleAndPermissionSet.put('Receptionist AA1','Receptionist_AA1');
                mapRoleAndPermissionSet.put('Receptionist AA2','Receptionist_AA2');
                mapRoleAndPermissionSet.put('Receptionist Front Desk Home Office','Receptionist_Front_Desk_Home_Office');
                mapRoleAndPermissionSet.put('Deaf Services Specialist','Deaf_Services_Specialist');
                mapRoleAndPermissionSet.put('Deaf-Blind Services Specialist','Deaf_Blind_Services_Specialist');
                mapRoleAndPermissionSet.put('Hard of Hearing Service Specialist','Hard_of_Hearing_Service_Specialist');
                mapRoleAndPermissionSet.put('Interpreter Services Specialist','Interpreter_Services_Specialist');
                mapRoleAndPermissionSet.put('Telecom Consultant','Telecom_Consultant');
                mapRoleAndPermissionSet.put('Community Access Specialist','Community_Access_Consultant');
                mapRoleAndPermissionSet.put('Regional Center Manager','Regional_Center_Manager');
                mapRoleAndPermissionSet.put('Community Resources Program Manager','Community_Resources_Program_Manager');
                mapRoleAndPermissionSet.put('CRPM Assistant','CRPM_Assistant');
                mapRoleAndPermissionSet.put('Communication Access Manager','Communication_Access_Manager');
                mapRoleAndPermissionSet.put('CAM Assistant','CAM_Assistant');
                mapRoleAndPermissionSet.put('Budget Manager','Budget_Manager');
                mapRoleAndPermissionSet.put('Program Planner Evaluator','Program_Planner_Evaluator');
                mapRoleAndPermissionSet.put('Telecom Access Program Manager','Telecom_Access_Program_Manager');
                mapRoleAndPermissionSet.put('Emergency Preparedness Coordinator','Emergency_Preparedness_Coordinator');
                mapRoleAndPermissionSet.put('Deaf/Deaf-Blind Services Coordinator','Deaf_Deaf_Blind_Services_Coordinator');
                mapRoleAndPermissionSet.put('Hard of Hearing Coordinator','Hard_of_Hearing_Coordinator');
                mapRoleAndPermissionSet.put('Accessibility Coordinator','Accessibility_Coordinator');
                mapRoleAndPermissionSet.put('EDS Program Coordinator','EDS_Program_Coordinator');
                mapRoleAndPermissionSet.put('EDS Program Assistant','EDS_Program_Assistant');
                mapRoleAndPermissionSet.put('NDBEDP Administrator','NDBEDP_Administrator');
                mapRoleAndPermissionSet.put('Home office Staff Interpreters','Home_office_Staff_Interpreters');
                mapRoleAndPermissionSet.put('Technology Resource Coordinator','Technology_Resource_Coordinator');
                mapRoleAndPermissionSet.put('Outreach and Education Coordinator','Outreach_And_Education_Coordinator');
                mapRoleAndPermissionSet.put('Director','Director');
                mapRoleAndPermissionSet.put('Assistant Director','Assistant_Director');
                mapRoleAndPermissionSet.put('Directors Assistant','Director_Assistant');
                mapRoleAndPermissionSet.put('Veterans Affair Liaison','Veterans_Affair_Liaison');
                mapRoleAndPermissionSet.put('IT Support','IT_Support');
                mapRoleAndPermissionSet.put('Business Office Support','Business_Office_Support');
                mapRoleAndPermissionSet.put('Controllers Office','Controllers_Office');
            }
            return mapRoleAndPermissionSet;
        }
        set;
    }


    //Map Of Regional Center Group With User Picklist Values
    public static map<String,String> mapRegionalCenterGroups
    {
        get
        {
            if (mapRegionalCenterGroups == null)
            {
                mapRegionalCenterGroups = new map<String,string>();
                mapRegionalCenterGroups.put('Asheville Regional Center','Asheville_Regional_Center_User_Group');
                mapRegionalCenterGroups.put('Charlotte Regional Center','Charlotte_Regional_Center_User_Group');
                mapRegionalCenterGroups.put('Greensboro Regional Center','Greensboro_Regional_Center_User_Group');
                mapRegionalCenterGroups.put('Morganton Regional Center','Morganton_Regional_Center_User_Group');
                mapRegionalCenterGroups.put('Raleigh Regional Center','Raleigh_Regional_Center_User_Group');
                mapRegionalCenterGroups.put('Wilmington Regional Center','Wilmington_Regional_Center_User_Group');
                mapRegionalCenterGroups.put('Wilson Regional Center','Wilson_Regional_Center_User_Group');
                mapRegionalCenterGroups.put('Home Office','Home_Office_Group');
                mapRegionalCenterGroups.put('Vendors_Group','Vendors_Group');
            }
            return mapRegionalCenterGroups;
        }
        set;
    }

    public static map<String,String> mapRegionalCenterGroupsAA2
    {
        get
        {
            if (mapRegionalCenterGroupsAA2 == null)
            {
                mapRegionalCenterGroupsAA2 = new map<String,string>();
                mapRegionalCenterGroupsAA2.put('Asheville Regional Center','Asheville_Regional_Center_Manager_AA2');
                mapRegionalCenterGroupsAA2.put('Charlotte Regional Center','Charlotte_Regional_Center_Manager_AA2');
                mapRegionalCenterGroupsAA2.put('Greensboro Regional Center','Greensboro_Regional_Center_Manager_AA2');
                mapRegionalCenterGroupsAA2.put('Morganton Regional Center','Morganton_Regional_Center_Manager_AA2');
                mapRegionalCenterGroupsAA2.put('Raleigh Regional Center','Raleigh_Regional_Center_Manager_AA2');
                mapRegionalCenterGroupsAA2.put('Wilmington Regional Center','Wilmington_Regional_Center_Manager_AA2');
                mapRegionalCenterGroupsAA2.put('Wilson Regional Center','Wilson_Regional_Center_Manager_AA2');
            }
            return mapRegionalCenterGroupsAA2;
        }
        set;
    }

    public static map<String,String> mapRegionalCenterManagerGroup
    {
        get
        {
            if (mapRegionalCenterManagerGroup == null)
            {
                mapRegionalCenterManagerGroup = new map<String,string>();
                mapRegionalCenterManagerGroup.put('Asheville Regional Center','Asheville_Regional_Center_Manager');
                mapRegionalCenterManagerGroup.put('Charlotte Regional Center','Charlotte_Regional_Center_Manager');
                mapRegionalCenterManagerGroup.put('Greensboro Regional Center','Greensboro_Regional_Center_Manager');
                mapRegionalCenterManagerGroup.put('Morganton Regional Center','Morganton_Regional_Center_Manager');
                mapRegionalCenterManagerGroup.put('Raleigh Regional Center','Raleigh_Regional_Center_Manager');
                mapRegionalCenterManagerGroup.put('Wilmington Regional Center','Wilmington_Regional_Center_Manager');
                mapRegionalCenterManagerGroup.put('Wilson Regional Center','Wilson_Regional_Center_Manager');
            }
            return mapRegionalCenterManagerGroup;
        }
        set;
    }
    
    public static map<String,String> mapRegionalCenterCommunicationAccessManagerGroup
    {
        get
        {
            if (mapRegionalCenterCommunicationAccessManagerGroup == null)
            {
                mapRegionalCenterCommunicationAccessManagerGroup = new map<String,string>();
                mapRegionalCenterCommunicationAccessManagerGroup.put('Asheville Regional Center','Asheville_Communication_Access_Manager');
                mapRegionalCenterCommunicationAccessManagerGroup.put('Charlotte Regional Center','Charlotte_Communication_Access_Manager');
                mapRegionalCenterCommunicationAccessManagerGroup.put('Greensboro Regional Center','Greensboro_Communication_Access_Manager');
                mapRegionalCenterCommunicationAccessManagerGroup.put('Morganton Regional Center','Morganton_Communication_Access_Manager');
                mapRegionalCenterCommunicationAccessManagerGroup.put('Raleigh Regional Center','Raleigh_Communication_Access_Manager');
                mapRegionalCenterCommunicationAccessManagerGroup.put('Wilmington Regional Center','Wilmington_Communication_Access_Manager');
                mapRegionalCenterCommunicationAccessManagerGroup.put('Wilson Regional Center','Wilson_Communication_Access_Manager');
            }
            return mapRegionalCenterCommunicationAccessManagerGroup;
        }
        set;
    }

    
    
    //Map Of Vendor Service to Contract Admin Group
    public static map<String,String> contractorGroupNameMap
    {
        get
        {
            if (contractorGroupNameMap == null)
            {
                contractorGroupNameMap = new map<String,string>();
                contractorGroupNameMap.put('CART__c','CART_Contract_Administrator');
                contractorGroupNameMap.put('Hearing_Aid_Provider__c','Hearing_Aid_Provider_Contract_Admin');
                contractorGroupNameMap.put('Equipment_Provider__c','Equipment_Provider_Contract_Administrato');
                contractorGroupNameMap.put('SSP__c','SSP_Contract_Administrator');
                contractorGroupNameMap.put('Interpreter__c','Interpreter_Contract_Administrator');
                contractorGroupNameMap.put('Training_Vendor__c','SSP_Contract_Administrator');
            }
            return contractorGroupNameMap;
        }
        set;
    }
    
    //Map Of Vendor Service to Contract Admin Group
    public static map<String,String> invoiceRecordTypeToBudgetAmountType
    {
        get
        {
            if (invoiceRecordTypeToBudgetAmountType == null)
            {
                invoiceRecordTypeToBudgetAmountType = new map<String,string>();
                invoiceRecordTypeToBudgetAmountType.put('Hearing_AID','Hearing Aid Budget');
                invoiceRecordTypeToBudgetAmountType.put('EDS','Other');
                invoiceRecordTypeToBudgetAmountType.put('Weather_Radio','Weather Radio Budget');
            }
            return invoiceRecordTypeToBudgetAmountType;
        }
        set;
    }

    //List Of Equipment Budgte Type
    public static List<String> listOfBudgetTypeForEquipment{
        get{
            if(listOfBudgetTypeForEquipment == null){
                listOfBudgetTypeForEquipment = new List<String>();
                listOfBudgetTypeForEquipment.add(HEARING_AID_BUDGET);
                listOfBudgetTypeForEquipment.add(WEATHER_RADIO_BUDGET);
                listOfBudgetTypeForEquipment.add(OTHERS_RADIO_BUDGET);
                listOfBudgetTypeForEquipment.add(CAPTEL);
                listOfBudgetTypeForEquipment.add(NDBEDP_BUDGET);
            }
            return listOfBudgetTypeForEquipment;
        }
        set;
    }

    //Map Of Vendor Type To Vendor Field API name
    public static map<String,String> vendorTypeToVendorFieldApiName
    {
        get
        {
            if (vendorTypeToVendorFieldApiName == null)
            {
               vendorTypeToVendorFieldApiName = new map<String,string>();
               vendorTypeToVendorFieldApiName.put('Interpreters','Approved_Interpreter__c');
               vendorTypeToVendorFieldApiName.put('CART','Approved_CART__c');
               vendorTypeToVendorFieldApiName.put('SSP','Approved_SSP__c');
               vendorTypeToVendorFieldApiName.put('NDBEDP Interpreters','Approved_Interpreter__c');
               vendorTypeToVendorFieldApiName.put('NDBEDP CART','Approved_CART__c');
               vendorTypeToVendorFieldApiName.put('NDBEDP SSP','Approved_SSP__c');
               vendorTypeToVendorFieldApiName.put('Training Vendor','Approved_Training_Vendor__c');
            }
            return vendorTypeToVendorFieldApiName;
        }
        set;
    }
    
    
    //Map Of field To label
    public static map<String,String> fieldToLabelMap
    {
        get
        {
            if (fieldToLabelMap == null)
            {
               fieldToLabelMap = new map<String,string>();
               fieldToLabelMap.put('Breakfast__c','Breakfast');
               fieldToLabelMap.put('Lunch__c','Lunch');
               fieldToLabelMap.put('Dinner__c','Dinner');
                fieldToLabelMap.put('Mileage__c','Mileage');
                fieldToLabelMap.put('Hotels__c','Hotels');
                fieldToLabelMap.put('Excess_Hotel_Cost__c','Excess Hotel Cost');
                fieldToLabelMap.put('Parking__c','Parking');
            }
            return fieldToLabelMap;
        }
        set;
    }
    
     //Map Of field To label
    public static map<String,String> labelToFieldMaping
    {
        get
        {
            if (fieldToLabelMap == null)
            {
               fieldToLabelMap = new map<String,string>();
               fieldToLabelMap.put('Breakfast','Breakfast__c');
               fieldToLabelMap.put('Lunch','Lunch__c');
               fieldToLabelMap.put('Dinner','Dinner__c');
                fieldToLabelMap.put('Mileage','Mileage__c');
                fieldToLabelMap.put('Hotels','Hotels__c');
                fieldToLabelMap.put('Excess Hotel Cost','Excess_Hotel_Cost__c');
                fieldToLabelMap.put('Parking','Parking__c');
            }
            return fieldToLabelMap;
        }
        set;
    }
    
    
    //Map Of Regional Center to Regional Center Number Map(For Barcode)
    public static map<String,String> regionalCenterToNumberMap
    {
        get
        {
            if (regionalCenterToNumberMap == null)
            {
                regionalCenterToNumberMap = new map<String,string>();
                regionalCenterToNumberMap.put('Asheville Regional Center','1');
                regionalCenterToNumberMap.put('Charlotte Regional Center','2');
                regionalCenterToNumberMap.put('Greensboro Regional Center','3');
                regionalCenterToNumberMap.put('Morganton Regional Center','4');
                regionalCenterToNumberMap.put('Raleigh Regional Center','5');
                regionalCenterToNumberMap.put('Wilmington Regional Center','6');
                regionalCenterToNumberMap.put('Wilson Regional Center','7');
                regionalCenterToNumberMap.put('Home Office','9');
                regionalCenterToNumberMap.put('DSDHH Central Office','10');
            }
            return regionalCenterToNumberMap;
        }
        set;
    }
    
     //Map Of Category To Code Map (For Barcode)
    public static map<String,String> categoryToCodeMap
    {
        get
        {
            if (categoryToCodeMap == null)
            {
                categoryToCodeMap = new map<String,string>();
                categoryToCodeMap.put('Equipment/Media State Asset','SE.');
                categoryToCodeMap.put('Demo Equipment','DE.');
                categoryToCodeMap.put('Equipment','EQ.');
                categoryToCodeMap.put('Material/Media','ML.');
            }
            return categoryToCodeMap;
        }
        set;
    }


    //List Of Staffing Budgte Type
    public static List<String> listOfBudgetTypeForStaffing{
        get{
            if(listOfBudgetTypeForStaffing == null){
                listOfBudgetTypeForStaffing = new List<String>();
                listOfBudgetTypeForStaffing.add(SSP_BUDGET);
                listOfBudgetTypeForStaffing.add(CART_BUDGET);
                listOfBudgetTypeForStaffing.add(INTERPRETERS_BUDGET);
                listOfBudgetTypeForStaffing.add(TRAININGVENDOR_BUDGET);
                listOfBudgetTypeForStaffing.add(CAPTEL);
                
            }
            return listOfBudgetTypeForStaffing;
        }
        set;
    }

    @AuraEnabled
    public static Map<String, Boolean> getRecordTypeForInvoice(String recordId){
        //List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c WHERE Id =: recordId AND RecordType.DeveloperName =: INVOICE_RECORDTYPE_COMMUNICATION WITH SECURITY_ENFORCED];
        //return !invoiceList.isEmpty();
        Map<String, Boolean> resultMap = new Map<String, Boolean>();
        resultMap.put('isAccessible', false);
        resultMap.put('isCommunicationAccess', false);
        Id assessorTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_ASSESSMENT);
        Id assessorTrainingTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_ASSESSOR_TRAINING);
        Id ndbedpFollowUpTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_FOLLOWUP);
        Id ndbedpPickupTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_PICK_UP);
        Id ndbedpDeliveryTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_DELIVERY);
        Set<Id> excludeRecordTypeIds = new Set<Id>{assessorTypeId, assessorTrainingTypeId, ndbedpFollowUpTypeId, ndbedpPickupTypeId, ndbedpDeliveryTypeId};
        
        List<Invoice__c> invoiceList = [SELECT recordTypeId, recordType.DeveloperName FROM Invoice__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        if(!invoiceList.isEmpty() && !excludeRecordTypeIds.contains(invoiceList[0].recordTypeId)) {
            resultMap.put('isAccessible', true);
        }
        if(!invoiceList.isEmpty() && invoiceList[0].recordType.DeveloperName == INVOICE_RECORDTYPE_COMMUNICATION) {
            resultMap.put('isCommunicationAccess', true);
        }
        return resultMap;
    }
   
    
    public static List<String> groupCodeList {
        get {
            if(groupCodeList == null) {
                groupCodeList = new List<String>();
                groupCodeList.add('00');
                groupCodeList.add('01');
                groupCodeList.add('02');
                groupCodeList.add('03');
                groupCodeList.add('04');
                groupCodeList.add('05');
                groupCodeList.add('06');
                groupCodeList.add('07');
                groupCodeList.add('08');
                groupCodeList.add('09');
                groupCodeList.add('0A');
                groupCodeList.add('0B');
                groupCodeList.add('0C');
                groupCodeList.add('0D');
                groupCodeList.add('0E');
                groupCodeList.add('0F');
                groupCodeList.add('10');
                groupCodeList.add('11');
                groupCodeList.add('12');
                groupCodeList.add('13');
                groupCodeList.add('14');
                groupCodeList.add('15');
                groupCodeList.add('16');
                groupCodeList.add('17');
                groupCodeList.add('18');
                groupCodeList.add('19');
                groupCodeList.add('1A');
                groupCodeList.add('1B');
                groupCodeList.add('1C');
                groupCodeList.add('1D');
                groupCodeList.add('1E');
                groupCodeList.add('1F');
                groupCodeList.add('20');
                groupCodeList.add('21');
                groupCodeList.add('22');
                groupCodeList.add('23');
                groupCodeList.add('24');
                groupCodeList.add('25');
                groupCodeList.add('26');
                groupCodeList.add('27');
                groupCodeList.add('28');
                groupCodeList.add('29');
                groupCodeList.add('2A');
                groupCodeList.add('2B');
                groupCodeList.add('2C');
                groupCodeList.add('2D');
                groupCodeList.add('2E');
                groupCodeList.add('2F');
                groupCodeList.add('30');
                groupCodeList.add('31');
                groupCodeList.add('32');
                groupCodeList.add('33');
                groupCodeList.add('34');
                groupCodeList.add('35');
                groupCodeList.add('36');
                groupCodeList.add('37');
                groupCodeList.add('38');
                groupCodeList.add('39');
                groupCodeList.add('3A');
                groupCodeList.add('3B');
                groupCodeList.add('3C');
                groupCodeList.add('3D');
                groupCodeList.add('3E');
                groupCodeList.add('3F');
                groupCodeList.add('40');
                groupCodeList.add('41');
                groupCodeList.add('42');
                groupCodeList.add('43');
                groupCodeList.add('44');
                groupCodeList.add('45');
                groupCodeList.add('46');
                groupCodeList.add('47');
                groupCodeList.add('48');
                groupCodeList.add('49');
                groupCodeList.add('4A');
                groupCodeList.add('4B');
                groupCodeList.add('4C');
                groupCodeList.add('4D');
                groupCodeList.add('4E');
                groupCodeList.add('4F');
                groupCodeList.add('50');
                groupCodeList.add('51');
                groupCodeList.add('52');
                groupCodeList.add('53');
                groupCodeList.add('54');
                groupCodeList.add('55');
                groupCodeList.add('56');
                groupCodeList.add('57');
                groupCodeList.add('58');
                groupCodeList.add('59');
                groupCodeList.add('5A');
                groupCodeList.add('5B');
                groupCodeList.add('5C');
                groupCodeList.add('5D');
                groupCodeList.add('5E');
                groupCodeList.add('5F');
                groupCodeList.add('60');
                groupCodeList.add('61');
                groupCodeList.add('62');
                groupCodeList.add('63');
                groupCodeList.add('64');
                groupCodeList.add('65');
                groupCodeList.add('66');
                groupCodeList.add('67');
                groupCodeList.add('68');
                groupCodeList.add('69');
                groupCodeList.add('6A');
                groupCodeList.add('6B');
                groupCodeList.add('6C');
                groupCodeList.add('6D');
                groupCodeList.add('6E');
                groupCodeList.add('6F');
                groupCodeList.add('70');
                groupCodeList.add('71');
                groupCodeList.add('72');
                groupCodeList.add('73');
                groupCodeList.add('74');
                groupCodeList.add('75');
                groupCodeList.add('76');
                groupCodeList.add('77');
                groupCodeList.add('78');
                groupCodeList.add('79');
                groupCodeList.add('7A');
                groupCodeList.add('7B');
                groupCodeList.add('7C');
                groupCodeList.add('7D');
                groupCodeList.add('7E');
                groupCodeList.add('7F');
                groupCodeList.add('80');
                groupCodeList.add('81');
                groupCodeList.add('82');
                groupCodeList.add('83');
                groupCodeList.add('84');
                groupCodeList.add('85');
                groupCodeList.add('86');
                groupCodeList.add('87');
                groupCodeList.add('88');
                groupCodeList.add('89');
                groupCodeList.add('8A');
                groupCodeList.add('8B');
                groupCodeList.add('8C');
                groupCodeList.add('8D');
                groupCodeList.add('8E');
                groupCodeList.add('8F');
                groupCodeList.add('90');
                groupCodeList.add('91');
                groupCodeList.add('92');
                groupCodeList.add('93');
                groupCodeList.add('94');
                groupCodeList.add('95');
                groupCodeList.add('96');
                groupCodeList.add('97');
                groupCodeList.add('98');
                groupCodeList.add('99');
                groupCodeList.add('9A');
                groupCodeList.add('9B');
                groupCodeList.add('9C');
                groupCodeList.add('9D');
                groupCodeList.add('9E');
                groupCodeList.add('9F');
                groupCodeList.add('A0');
                groupCodeList.add('A1');
                groupCodeList.add('A2');
                groupCodeList.add('A3');
                groupCodeList.add('A4');
                groupCodeList.add('A5');
                groupCodeList.add('A6');
                groupCodeList.add('A7');
                groupCodeList.add('A8');
                groupCodeList.add('A9');
                groupCodeList.add('AA');
                groupCodeList.add('AB');
                groupCodeList.add('AC');
                groupCodeList.add('AD');
                groupCodeList.add('AE');
                groupCodeList.add('AF');
                groupCodeList.add('B0');
                groupCodeList.add('B1');
                groupCodeList.add('B2');
                groupCodeList.add('B3');
                groupCodeList.add('B4');
                groupCodeList.add('B5');
                groupCodeList.add('B6');
                groupCodeList.add('B7');
                groupCodeList.add('B8');
                groupCodeList.add('B9');
                groupCodeList.add('BA');
                groupCodeList.add('BB');
                groupCodeList.add('BC');
                groupCodeList.add('BD');
                groupCodeList.add('BE');
                groupCodeList.add('BF');
                groupCodeList.add('C0');
                groupCodeList.add('C1');
                groupCodeList.add('C2');
                groupCodeList.add('C3');
                groupCodeList.add('C4');
                groupCodeList.add('C5');
                groupCodeList.add('C6');
                groupCodeList.add('C7');
                groupCodeList.add('C8');
                groupCodeList.add('C9');
                groupCodeList.add('CA');
                groupCodeList.add('CB');
                groupCodeList.add('CC');
                groupCodeList.add('CD');
                groupCodeList.add('CE');
                groupCodeList.add('CF');
                groupCodeList.add('D0');
                groupCodeList.add('D1');
                groupCodeList.add('D2');
                groupCodeList.add('D3');
                groupCodeList.add('D4');
                groupCodeList.add('D5');
                groupCodeList.add('D6');
                groupCodeList.add('D7');
                groupCodeList.add('D8');
                groupCodeList.add('D9');
                groupCodeList.add('DA');
                groupCodeList.add('DB');
                groupCodeList.add('DC');
                groupCodeList.add('DD');
                groupCodeList.add('DE');
                groupCodeList.add('DF');
                groupCodeList.add('E0');
                groupCodeList.add('E1');
                groupCodeList.add('E2');
                groupCodeList.add('E3');
                groupCodeList.add('E4');
                groupCodeList.add('E5');
                groupCodeList.add('E6');
                groupCodeList.add('E7');
                groupCodeList.add('E8');
                groupCodeList.add('E9');
                groupCodeList.add('EA');
                groupCodeList.add('EB');
                groupCodeList.add('EC');
                groupCodeList.add('ED');
                groupCodeList.add('EE');
                groupCodeList.add('EF');
                groupCodeList.add('F0');
                groupCodeList.add('F1');
                groupCodeList.add('F2');
                groupCodeList.add('F3');
                groupCodeList.add('F4');
                groupCodeList.add('F5');
                groupCodeList.add('F6');
                groupCodeList.add('F7');
                groupCodeList.add('F8');
                groupCodeList.add('F9');
                groupCodeList.add('FA');
                groupCodeList.add('FB');
                groupCodeList.add('FC');
                groupCodeList.add('FD');
                groupCodeList.add('FE');
                groupCodeList.add('FF');
            }
            return groupCodeList; 
        }
        set;
    }
     
}