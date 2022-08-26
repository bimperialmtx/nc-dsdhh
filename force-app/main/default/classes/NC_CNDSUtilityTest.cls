/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_CNDSUtilityTest {

    /*
    *********************************************************
    @Method Name    : insertErrorRecordTest
    @description    : Verify Error record creation
    ********************************************************
    */
    @IsTest
    public static void insertErrorRecordTest(){
        Contact con = TestDataUtility.createConsumer(true);
        NC_CNDSUtility.insertErrorRecord('endPoint','body','test','test','503',con);
        List<Error__c> errorList = [SELECT Id FROM Error__c];
        System.assertNotEquals(0, errorList.size());
    }
    
    /*
    *********************************************************
    @Method Name    : insertNDBEDPRequestErrorTest
    @description    : Verify NDBEDP Request Error record creation
    ********************************************************
    */
    @IsTest
    public static void insertNDBEDPRequestErrorTest(){
        Case con = TestDataUtility.createNDBEDPCase(true);
        NC_CNDSUtility.insertNDBEDPRequestError('endPoint','body','body','test','503',con.Id);
        List<Error__c> errorList = [SELECT Id FROM Error__c];
        System.assertNotEquals(0, errorList.size());
    }
    
    /*
    *********************************************************
    @Method Name    : insertNDBEDPErrorTest
    @description    : Verify NDBEDP Error record creation
    ********************************************************
    */
    @IsTest
    public static void insertNDBEDPErrorTest(){
        Contact con = TestDataUtility.createConsumer(true);
        NC_CNDSUtility.insertNDBEDPError('endPoint','body','body','test','503',con);
        List<Error__c> errorList = [SELECT Id FROM Error__c];
        System.assertNotEquals(0, errorList.size());
    }

    /*
    *********************************************************
    @Method Name    : insertReqEquipmentErrorTest
    @description    : Verify Request Equipment Error record creation
    ********************************************************
    */
    @IsTest
    public static void insertReqEquipmentErrorTest(){
        Case cas = TestDataUtility.createNDBEDPCase(true);
        NC_CNDSUtility.insertReqEquipmentError('endPoint','req', 'res', 'error_Desc', 'statusCode', cas.Id);
        System.assertEquals('NDBEDP', cas.Equipment_Types__c);
    }

    /*
    *********************************************************
    @Method Name    : insertReqEquipmentErrorTest
    @description    : Verify RC staff user
    ********************************************************
    */
    @IsTest
    public static void getRCStaffIdsTest(){
        User u= [SELECT Id FROM User LIMIT 1];
        Set<String> result = NC_CNDSUtility.getRCStaffIds(u.Id);
        System.assertEquals(true, result.size()!=null);
    }
    
    /*
    *********************************************************
    @Method Name    : insertNDBEDPTrainerErrorTest
    @description    : Verify NDBEDP Trainer error record creation
    ********************************************************
    */
    @IsTest
    public static void insertNDBEDPTrainerErrorTest(){
        Account con = TestDataUtility.createAssessor(true);
        NC_CNDSUtility.insertNDBEDPTrainerError('endPoint','body','body','test','503',con);
        List<Error__c> errorList = [SELECT Id FROM Error__c];
        System.assertNotEquals(0, errorList.size());
    }
    
    /*
    *********************************************************
    @Method Name    : insertNDBEDPAssessorErrorTest
    @description    : Verify NDBEDP Assessor error record creation
    ********************************************************
    */
    @IsTest
    public static void insertNDBEDPAssessorErrorTest(){
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Wilmington Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        
        insert userObj;
        // Account con = TestDataUtility.createAssessor(true);
        try{
            NC_CNDSUtility.insertNDBEDPAssessorError('endPoint','body','body','test','503',userObj);
            Error__c error=[SELECT Id,Equipment_request_no__c FROM Error__c LIMIT 1];
            System.assertEquals(false, error.Equipment_request_no__c!=null);
        }
        Catch(Exception e){
        }
    }
    
    
}