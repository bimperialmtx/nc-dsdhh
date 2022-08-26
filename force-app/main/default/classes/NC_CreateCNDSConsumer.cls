/**
 * Created by ashishpandey on 10/05/21.
 * Create Consumer in CNDS
 */

public class NC_CreateCNDSConsumer implements Queueable,Database.AllowsCallouts {

    public List<Contact> contacts;
    public NC_CreateCNDSConsumer(List<Contact> conList){
        contacts = conList ;

    }
    public void execute(QueueableContext qc){

        NC_CNDSWrapper.PersonCreateRequest requestBody = new NC_CNDSWrapper.PersonCreateRequest();
        Http h = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse res;
        String api_key = String.valueOf(Label.CNDS_Key);
        String endPoint = String.valueOf(Label.CNDS_Person_Create);
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
        requestBody.LAST_NAME= contacts[0].LastName!=null?contacts[0].LastName.toUpperCase():null;
        requestBody.FIRST_NAME= contacts[0].FirstName!=null?contacts[0].FirstName.toUpperCase():null;
        requestBody.MIDDLE_INITIAL= contacts[0].MiddleName!=null?contacts[0].MiddleName.left(1).toUpperCase():null;
        requestBody.NAME_SUFFIX= contacts[0].Suffix!=null?contacts[0].Suffix.left(3).toUpperCase():null;
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
        try{
            res = h.send(httpReq);
        }catch (Exception e){
            contacts[0].Allow_Resync__c=true;
            update contacts;
            NC_CNDSUtility.insertErrorRecord(endPoint,body,e.getMessage(),e.getMessage(),'503',contacts[0]);
        }
        if (res!=null) {
          
            NC_CNDSWrapper.PersonCreateResponse responseWrapper = (NC_CNDSWrapper.PersonCreateResponse)JSON.deserialize(res.getBody(),NC_CNDSWrapper.PersonCreateResponse.class);

            if(res.getStatusCode() == 200) {
                if(responseWrapper.STATUS!='500'){
                    contacts[0].Cnds_Identifier__c=responseWrapper.IDENTIFIER+responseWrapper.CHECK_DIGIT;
                    contacts[0].Allow_Resync__c=false;
                    update contacts;
                }else {
                    contacts[0].Allow_Resync__c=true;
                    update contacts;
                    NC_CNDSUtility.insertErrorRecord(endPoint,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,responseWrapper.STATUS,contacts[0]);
                }

            }else{
                contacts[0].Allow_Resync__c=true;
                update contacts;
                NC_CNDSUtility.insertErrorRecord(endPoint,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,responseWrapper.STATUS,contacts[0]);
            }
        }
    }
}