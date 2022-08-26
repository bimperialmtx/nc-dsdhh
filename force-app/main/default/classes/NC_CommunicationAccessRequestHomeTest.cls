/**
* @description       : Test class for NC_CommunicationAccessRequestHome
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CommunicationAccessRequestHomeTest {

    /*
    *********************************************************
    @Method Name    : checkPermissionsTest
    @description    : Verify Communication access request and resource loan create permission and record types
    ********************************************************
    */
    Static testmethod void checkPermissionsTest() {
                Map<String, Boolean> resultMap = NC_CommunicationAccessRequestHomeCtrl.checkPermissions();

        System.assertEquals(true, resultMap.get('isCommunicationCretable'));
        System.assertEquals(true, resultMap.get('isResourceLoanCretable'));
        
        String result = NC_CommunicationAccessRequestHomeCtrl.returnRecordTypeId();
        System.assertNotEquals(null, result);
        
        String result2 = NC_CommunicationAccessRequestHomeCtrl.getResourceLoanRecordTypeId();
        System.assertNotEquals(null, result2);
    
    }
}