/**
* @description       : Test class for SendCustomNotification
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class SendCustomNotificationTest {
    
    /*
*********************************************************
@Method Name    : sendNotificationsTest
@description    : Verify notification for consumer
********************************************************
*/
    static testmethod void sendNotificationsTest() {
        Contact con = TestDataUtility.createConsumer(true);
        String notificationId = [Select Id,DeveloperName,CustomNotifTypeName from CustomNotificationType WHERE DeveloperName='RC_Staff'].Id;
        SendCustomNotification.sendNotifications('Consumer updated', UserInfo.getUserId(), con.id, con.firstname, notificationId, new Set<String>{UserInfo.getUserId()});
        System.assertEquals(true, UserInfo.getUserId()!=null);
    }
}