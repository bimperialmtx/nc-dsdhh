/**
 * Created by ashishpandey on 07/06/21.
 */

public without sharing class NC_CNDSUtility {

    /*
    *********************************************************
    @Method Name    : insertErrorRecord
    @description    : insert api error record
    @param          : String endPoint,String req, String res, String error_Desc, String statusCode, Contact con
    @return         : void
    ********************************************************
    */
    public static void insertErrorRecord(String endPoint,String req, String res, String error_Desc, String statusCode, Contact con){
        Id cndsRT = Schema.SObjectType.Error__c.getRecordTypeInfosByName().get('CNDS Error').getRecordTypeId();
        Case obj;
        for(Case c:[SELECT Id, CaseNumber FROM Case WHERE ContactId =:con.Id AND Status ='Pending Documents' WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1]){
            obj=c;
        }
        Error__c error = new Error__c();
        error.Type__c='API Exception';
        error.Consumer__c=con.Id;
        error.Timestamp__c=System.now();
        error.Request__c=req;
        error.Equipment_request_no__c=obj!=null?obj.CaseNumber:null;
        error.Endpoint_URL__c=endPoint;
        error.Error_Description__c=error_Desc;
        error.Response__c=res;
        error.RecordTypeId=cndsRT;
        error.Status_Code__c=statusCode;
        insert error;
        //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Error__c', new List<Error__c>{error}, 'insert', true,'NC_CNDSUtility','insertErrorRecord');
        //insert decision.getRecords();
    }

    /*
    *********************************************************
    @Method Name    : insertNDBEDPError
    @description    : insert ndbedp api error record
    @param          : String endPoint,String req, String res, String error_Desc, String statusCode, Contact con
    @return         : void
    ********************************************************
    */
    public static void insertNDBEDPError(String endPoint,String req, String res, String error_Desc, String statusCode, Contact con){
        Id cndsRT = Schema.SObjectType.Error__c.getRecordTypeInfosByName().get('NDBEDP Error').getRecordTypeId();
        Case obj;
        for(Case c:[SELECT Id, CaseNumber FROM Case WHERE ContactId =:con.Id WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1]){
            obj=c;
        }
        Error__c error = new Error__c();
        error.Type__c='NDBEDP Exception';
        error.Consumer__c=con.Id;
        error.Timestamp__c=System.now();
        error.Request__c=req;
        error.Equipment_request_no__c=obj!=null?obj.CaseNumber:null;
        error.Endpoint_URL__c=endPoint;
        error.Error_Description__c=error_Desc;
        error.Response__c=res;
        error.RecordTypeId=cndsRT;
        error.Status_Code__c=statusCode;
        insert error;
        //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Error__c', new List<Error__c>{error}, 'insert', true,'NC_CNDSUtility','insertNDBEDPError');
        //insert decision.getRecords();
    }

    /*
    *********************************************************
    @Method Name    : insertNDBEDPRequestError
    @description    : insert ndbedp exception error record
    @param          : String endPoint,String req, String res, String error_Desc, String statusCode, Id caseId
    @return         : void
    ********************************************************
    */
    public static void insertNDBEDPRequestError(String endPoint,String req, String res, String error_Desc, String statusCode, Id caseId){
        Id cndsRT = Schema.SObjectType.Error__c.getRecordTypeInfosByName().get('NDBEDP Error').getRecordTypeId();
        Error__c error = new Error__c();
        error.Type__c='NDBEDP Exception';
        error.Timestamp__c=System.now();
        error.Request__c=req;
        error.Request_Record__c=caseId;
        error.Endpoint_URL__c=endPoint;
        error.Error_Description__c=error_Desc;
        error.Response__c=res;
        error.RecordTypeId=cndsRT;
        error.Status_Code__c=statusCode;
        insert error;
        //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Error__c', new List<Error__c>{error}, 'insert', true,'NC_CNDSUtility','insertNDBEDPRequestError');
        //insert decision.getRecords();
    }

    /*
    *********************************************************
    @Method Name    : insertNDBEDPTrainerError
    @description    : insert ndbedp trainer exception error record
    @param          : String endPoint,String req, String res, String error_Desc, String statusCode, Account acc
    @return         : void
    ********************************************************
    */
    public static void insertNDBEDPTrainerError(String endPoint,String req, String res, String error_Desc, String statusCode, Account acc){
        Id cndsRT = Schema.SObjectType.Error__c.getRecordTypeInfosByName().get('NDBEDP Error').getRecordTypeId();
        Case obj;
        for(Case c:[SELECT Id, CaseNumber FROM Case WHERE AccountId =:acc.Id WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1]){
            obj=c;
        }
        Error__c error = new Error__c();
        error.Type__c='NDBEDP Exception';
        error.Trainer_Assessor__c=acc.Id;
        error.Timestamp__c=System.now();
        error.Request__c=req;
        error.Equipment_request_no__c=obj!=null?obj.CaseNumber:null;
        error.Endpoint_URL__c=endPoint;
        error.Error_Description__c=error_Desc;
        error.Response__c=res;
        error.RecordTypeId=cndsRT;
        error.Status_Code__c=statusCode;
        insert error;
        //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Error__c', new List<Error__c>{error}, 'insert', true,'NC_CNDSUtility','insertNDBEDPTrainerError');
        //insert decision.getRecords();
    }

    /*
    *********************************************************
    @Method Name    : insertNDBEDPAssessorError
    @description    : insert ndbedp assessor exception error record
    @param          : String endPoint,String req, String res, String error_Desc, String statusCode, User user
    @return         : void
    ********************************************************
    */
    public static void insertNDBEDPAssessorError(String endPoint,String req, String res, String error_Desc, String statusCode, User user){
        Id cndsRT = Schema.SObjectType.Error__c.getRecordTypeInfosByName().get('NDBEDP Error').getRecordTypeId();
        Case obj;
        for(Case c:[SELECT Id, CaseNumber FROM Case WHERE Internal_Assessor__c =:user.Id WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1]){
            obj=c;
        }
        Error__c error = new Error__c();
        error.Type__c='NDBEDP Exception';
        error.Internal_Assessor__c =user.Id;
        error.Timestamp__c=System.now();
        error.Request__c=req;
        error.Equipment_request_no__c=obj!=null?obj.CaseNumber:null;
        error.Endpoint_URL__c=endPoint;
        error.Error_Description__c=error_Desc;
        error.Response__c=res;
        error.RecordTypeId=cndsRT;
        error.Status_Code__c=statusCode;
        insert error;
        //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Error__c', new List<Error__c>{error}, 'insert', true,'NC_CNDSUtility','insertNDBEDPAssessorError');
        //insert decision.getRecords();
    }

    /*
    *********************************************************
    @Method Name    : insertReqEquipmentError
    @description    : insert ndbedp exception error record
    @param          : String endPoint,String req, String res, String error_Desc, String statusCode, String caseId
    @return         : void
    ********************************************************
    */
    public static void insertReqEquipmentError(String endPoint,String req, String res, String error_Desc, String statusCode, String caseId){
        Id cndsRT = Schema.SObjectType.Error__c.getRecordTypeInfosByName().get('NDBEDP Error').getRecordTypeId();
        Case obj;

        Error__c error = new Error__c();
        error.Type__c='NDBEDP Exception';

        //insert error;
    }

    /*
    *********************************************************
    @Method Name    : getRCStaffIds
    @description    : Retrieve Regional Center staff user ids
    @param          : String userid
    @return         : Set<String>
    ********************************************************
    */
    public static Set<String> getRCStaffIds(String userid){
        Set<String> staffIds = new Set<String>();
        User user;
        for(User u:[SELECT Id, Regional_Center__c FROM User WHERE Id=:userid]){
            user=u;
        }
        for(User u:[SELECT Id, Regional_Center__c FROM User WHERE Regional_Center__c=:user.Regional_Center__c]){
            staffIds.add(String.valueOf(u.Id));
        }
        return staffIds;

    }

}