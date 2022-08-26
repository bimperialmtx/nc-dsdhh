/**
 * Created by ashishpandey on 25/05/21.
 */

public  class SendCustomNotification {

    /*
    *********************************************************
    @Method Name    : sendNotifications
    @description    : Send custom notification generic method
    @param          : String strBody, String strSenderId, String strTargetId, String strTitle, String strNotificationId, set<String> setUserIds
    @return         : void
    ********************************************************
    */
    public static void sendNotifications(String strBody, String strSenderId, String strTargetId, String strTitle, String strNotificationId, set<String> setUserIds) {

        Messaging.CustomNotification obj = new Messaging.CustomNotification();

        // Custom notification type Id
        obj.setNotificationTypeId(strNotificationId);

        // when we click on the notification it will redirect to the specified targetId
        obj.setTargetId(strTargetId);

        // Notification Title
        obj.setTitle(strTitle);

        // Notification Body
        obj.setBody(strBody);

        try{
            // send used to send the notification, pass the set of user ids , Group or Queue member
            obj.send(setUserIds); 
        }catch (Exception e) {
        }

    }

}