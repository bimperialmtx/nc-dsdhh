/**
 * Created by ashishpandey on 12/05/21.
 */

/* Update SMS Consumer to CNDS Database*/
public class NC_UpdateCNDSConsumer implements Queueable,Database.AllowsCallouts {

    public List<Contact> contacts;
    public NC_UpdateCNDSConsumer(List<Contact> conList){
        contacts = conList ;

    }
    public void execute(QueueableContext qc){

        NC_CNDSWrapper.PersonUpdateRequest requestBody = new NC_CNDSWrapper.PersonUpdateRequest();
        String api_key = String.valueOf(Label.CNDS_Key);
        String endPoint = String.valueOf(Label.CNDS_Person_Update);
        Http h = new Http();
        HttpResponse res;
        HttpRequest httpReq = new HttpRequest();

        List<String> raceCodes = new List<String>();
        if(contacts[0].Race__c!=null){
            raceCodes.addAll(contacts[0].Race__c.split(';'));
        }

        //****Formatting birthdate to required format*****
        String birthdate;
        String dayString;
        String monthString;
        Integer day;
        if(contacts[0].BirthDate!=null){
            day = contacts[0].BirthDate.Day(); //get day
            if(String.valueOf(day).length()==1){
                dayString= String.valueOf(day).leftPad(2, '0');
            }else {
                dayString=String.valueof(day);
            }
            Integer month = contacts[0].BirthDate.Month(); //get month
            if(String.valueOf(month).length()==1){
                monthString= String.valueOf(month).leftPad(2, '0');
            }else {
                monthString=String.valueof(month);
            }
            Integer year = contacts[0].BirthDate.Year(); //get year
            birthdate = String.valueof(year)+ monthString + dayString;
        }

        //****Setting up the request param*****
        requestBody.CNDS_NUMBER=contacts[0].Cnds_Identifier__c!=null?contacts[0].Cnds_Identifier__c.left(9).toUpperCase():'';
        requestBody.CHECK_DIGIT=contacts[0].Cnds_Identifier__c!=null?contacts[0].Cnds_Identifier__c.right(1).toUpperCase():'';
        requestBody.LAST_NAME= contacts[0].LastName!=null?contacts[0].LastName.toUpperCase():null;
        requestBody.FIRST_NAME= contacts[0].FirstName!=null?contacts[0].FirstName.toUpperCase():null;
        requestBody.MIDDLE_INITIAL= contacts[0].MiddleName!=null?contacts[0].MiddleName.left(1).toUpperCase():null;
        requestBody.NAME_SUFFIX= contacts[0].Suffix!=null?contacts[0].Suffix.toUpperCase():null;
        requestBody.DATE_OF_BIRTH= contacts[0].BirthDate!=null?birthdate:null;
        requestBody.SEX_CODE= contacts[0].Gender__c!=null?contacts[0].Gender__c:null;
        requestBody.ETHNICITY= contacts[0].Hispanic_Ethnicity__c!=null?contacts[0].Hispanic_Ethnicity__c.toUpperCase():null;
        requestBody.LANGUAGE_PREFRENCE= contacts[0].Primary_Language__c!=null?contacts[0].Primary_Language__c.toUpperCase():null;
        requestBody.USER_ID= contacts[0].User_Id__c.toUpperCase();
        //requestBody.RACE_CODE1= contacts[0].Race__c!=null?contacts[0].Race__c.toUpperCase():null;

        if(raceCodes.size()>0){
            requestBody.RACE_CODE1=raceCodes[0];
            if(raceCodes.size()>1){
                requestBody.RACE_CODE2=raceCodes[1];
            }
            if(raceCodes.size()>2){
                requestBody.RACE_CODE3=raceCodes[2];
            }
            if(raceCodes.size()>3){
                requestBody.RACE_CODE4=raceCodes[3];
            }
            if(raceCodes.size()>4){
                requestBody.RACE_CODE5=raceCodes[4];
            }
        }


        String body= JSON.serialize(requestBody);

        httpReq.setMethod('POST');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint);
        httpReq.setBody(body);
        if(contacts[0].Cnds_Identifier__c!=null){
            try{
                res = h.send(httpReq);
            }catch (Exception e){
                contacts[0].Allow_CNDS_Update_Sync__c=true;
                update contacts;
                NC_CNDSUtility.insertErrorRecord(endPoint,body,e.getMessage(),e.getMessage(),'503',contacts[0]);
            }
            if(res!=null){

                //***Send Notification to all RC Staff
                String notificationId = [Select Id,DeveloperName,CustomNotifTypeName from CustomNotificationType WHERE DeveloperName='RC_Staff'].Id;

                if(contacts[0].Staff_Member_Name__c!=null){
                    Set<String> staffIds = new Set<String>();
                    staffIds = NC_CNDSUtility.getRCStaffIds(contacts[0].Staff_Member_Name__c);
                    SendCustomNotification.sendNotifications('Consumer updated', UserInfo.getUserId(), contacts[0].Id, contacts[0].FirstName, notificationId, staffIds);
                }
                //SendCustomNotification.sendNotifications('Consumer updated', UserInfo.getUserId(), contacts[0].Id, contacts[0].FirstName, notificationId, new set<String>{UserInfo.getUserId()});
            

                NC_CNDSWrapper.PersonUpdateResponse responseWrapper = (NC_CNDSWrapper.PersonUpdateResponse)JSON.deserialize(res.getBody(),NC_CNDSWrapper.PersonUpdateResponse.class);

                if(res.getStatusCode() == 200) {

                    if(responseWrapper.STATUS!='500'){
                        Contact con =[SELECT Id,DOB_Document__c,Name_Change_Document__c,Allow_CNDS_Update_Sync__c FROM Contact WHERE Id=:contacts[0].Id];
                        con.Allow_CNDS_Update_Sync__c=false;
                        con.Name_Change_Document__c=false;
                        con.DOB_Document__c=false;
                        update con;
                    }else {
                        Contact con =[SELECT Id,Allow_CNDS_Update_Sync__c FROM Contact WHERE Id=:contacts[0].Id];
                        con.Allow_CNDS_Update_Sync__c=true;
                        update con;
                        NC_CNDSUtility.insertErrorRecord(endPoint,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,responseWrapper.STATUS,contacts[0]);
                    }

                }else{
                    Contact con =[SELECT Id,Allow_CNDS_Update_Sync__c FROM Contact WHERE Id=:contacts[0].Id];
                    con.Allow_CNDS_Update_Sync__c=true;
                    update con;
                    NC_CNDSUtility.insertErrorRecord(endPoint,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,responseWrapper.STATUS,contacts[0]);
                }
            }

        }

    }
}