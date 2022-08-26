/**
 * Created by ashishpandey on 10/05/21.
 * Send Contact details to CNDS
 */

public class NC_LookupCNDS implements Queueable,Database.AllowsCallouts{

    public List<Contact> contacts;
    public NC_LookupCNDS(List<Contact> conList){
        contacts = conList ;

    }
    public void execute(QueueableContext qc){
        NC_CNDSWrapper.PersonaSearchRequest requestBody = new NC_CNDSWrapper.PersonaSearchRequest();
        Map<String, NC_CNDSWrapper.PersonaSearchResponse> mapCNDSKeyVsPerson = new Map<String, NC_CNDSWrapper.PersonaSearchResponse>();

        String api_key = String.valueOf(Label.CNDS_Key);
        String endPoint = String.valueOf(Label.CNDS_Person_Search);
        String ssn=contacts[0].Social_Security_Number__c!=null?contacts[0].Social_Security_Number__c.right(4):null;
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
        requestBody.FIRST_NAME= contacts[0].FirstName!=null?contacts[0].FirstName.toUpperCase():null;
        requestBody.LAST_NAME= contacts[0].LastName!=null?contacts[0].LastName.toUpperCase():null;
        requestBody.SEX_CODE= contacts[0].Gender__c!=null?contacts[0].Gender__c:null;
        requestBody.DATE_OF_BIRTH= contacts[0].BirthDate!=null?birthdate:null;

        String body= JSON.serialize(requestBody);

        Http h = new Http();
        HttpResponse res;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint);
        httpReq.setBody(body);

        if(contacts[0].Cnds_Identifier__c==null){
            try{
                res = h.send(httpReq);
            }catch (Exception e){
                contacts[0].Allow_Resync__c=true;
                update contacts;
                NC_CNDSUtility.insertErrorRecord(endPoint,body,e.getMessage(),e.getMessage(),'503',contacts[0]);
            }
            if(res!=null){
              

                NC_CNDSWrapper.PearsonSearchWrapper responseWrapper = (NC_CNDSWrapper.PearsonSearchWrapper)JSON.deserialize(res.getBody(),NC_CNDSWrapper.PearsonSearchWrapper.class);

                if(res.getStatusCode() == 200) {
                    String CNDSIdentifier='';
                    if(responseWrapper.CCIPR82I_Person_Search_Response!=null){
                        Map<String, Integer> resultMatchCount = new Map<String, Integer>();
                        Map<String, Integer> resultMatchSSNZeroCount = new Map<String, Integer>();
                        for(NC_CNDSWrapper.PersonaSearchResponse person:responseWrapper.CCIPR82I_Person_Search_Response){
                            mapCNDSKeyVsPerson.put(person.IDENTIFIER + person.CHECK_DIGIT,person);
                            String CNDSsSN= person.PRIMARY_SSN.right(4);


                            if (person.FIRST_NAME==contacts[0].FirstName.toUpperCase() && person.LAST_NAME==contacts[0].LastName.toUpperCase()
                                && person.DATE_OF_BIRTH==birthdate && person.SEX_CODE==contacts[0].Gender__c && (contacts[0].MiddleName != null && (person.MIDDLE_INITIAL == contacts[0].MiddleName.left(1)))
                                && (CNDSsSN=='0000' || CNDSsSN==ssn)) {
                                    
                                
                                if(responseWrapper.CCIPR82I_Person_Search_Response.size() > 1) {
                                    if(CNDSsSN == ssn) {
                                        getResultMatchCount(contacts[0], person, resultMatchCount);
                                    }
                                    if(CNDSsSN == '0000') {
                                        getResultMatchCount(contacts[0], person, resultMatchSSNZeroCount);
                                    }
                                    Integer maxCount = 0;
                                    for(String cndsNo: resultMatchCount.keySet()) {
                                        if(resultMatchCount.get(cndsNo) > maxCount) {
                                            CNDSIdentifier = cndsNo;
                                        }
                                    }
                                    if(CNDSIdentifier == '') {
                                     	for(String cndsNo: resultMatchSSNZeroCount.keySet()) {
                                            if(resultMatchSSNZeroCount.get(cndsNo) > maxCount) {
                                                CNDSIdentifier = cndsNo;
                                            }
                                        }   
                                    }
                                    if(resultMatchCount.size() == 0) {
                                        CNDSIdentifier = person.IDENTIFIER + person.CHECK_DIGIT;
                                    }
                                } else {
                                    CNDSIdentifier=person.IDENTIFIER + person.CHECK_DIGIT;
                                }
                            }
                            else if (person.DATE_OF_BIRTH!=birthdate || person.LAST_NAME!=contacts[0].LastName
                                    || (contacts[0].MiddleName != null && (person.MIDDLE_INITIAL != contacts[0].MiddleName.left(1)))
                                    || person.SEX_CODE==contacts[0].Gender__c) {
                                CNDSIdentifier='';
                                Integer maxCount = 0;
                                for(String cndsNo: resultMatchCount.keySet()) {
                                    if(resultMatchCount.get(cndsNo) > maxCount) {
                                        CNDSIdentifier = cndsNo;
                                    }
                                }
                                    if(CNDSIdentifier == '') {
                                     	for(String cndsNo: resultMatchSSNZeroCount.keySet()) {
                                            if(resultMatchSSNZeroCount.get(cndsNo) > maxCount) {
                                                CNDSIdentifier = cndsNo;
                                            }
                                        }   
                                    }
                            }
                        }

                        //If Consumer found but some fields does not match-update those in CNDS
                        String hEthnicity =contacts[0].Hispanic_Ethnicity__c!=null?contacts[0].Hispanic_Ethnicity__c:null;
                        String language = contacts[0].Primary_Language__c!=null?contacts[0].Primary_Language__c:null;
                        String raceCode1;
                        String raceCode2;
                        String raceCode3;
                        String raceCode4;
                        String raceCode5;

                        if(raceCodes.size()>0){
                            raceCode1=raceCodes[0];
                            if(raceCodes.size()>1){
                                raceCode2=raceCodes[1];
                            }
                            if(raceCodes.size()>2){
                                raceCode3=raceCodes[2];
                            }
                            if(raceCodes.size()>3){
                                raceCode4=raceCodes[3];
                            }
                            if(raceCodes.size()>4){
                                raceCode5=raceCodes[4];
                            }
                        }
                       
                        //If Consumer found update CNDS on consumer in SF
                        if(String.isNotBlank(CNDSIdentifier)){
                            try{
                                contacts[0].Cnds_Identifier__c = CNDSIdentifier;
                                contacts[0].Duplicate_CNDS__c = false;
                                update contacts;   
                            } catch (Exception e){
                                if(e.getMessage().contains('DUPLICATE_VALUE')) {
                                    contacts[0].Cnds_Identifier__c = null;
                                    contacts[0].Duplicate_CNDS__c = true;
                                	update contacts;
                                }
                            }
                            if((mapCNDSKeyVsPerson.get(CNDSIdentifier).ETHNICITY == null || mapCNDSKeyVsPerson.get(CNDSIdentifier).LANGUAGE_PREFRENCE == null
                               || (mapCNDSKeyVsPerson.get(CNDSIdentifier).RACE_CODE1 == null && mapCNDSKeyVsPerson.get(CNDSIdentifier).RACE_CODE2 == null
                                  && mapCNDSKeyVsPerson.get(CNDSIdentifier).RACE_CODE3 == null && mapCNDSKeyVsPerson.get(CNDSIdentifier).RACE_CODE4 == null
                                  && mapCNDSKeyVsPerson.get(CNDSIdentifier).RACE_CODE5 == null)) && UserInfo.getUserName() != 'integration@cnds.com'){
                                System.enqueueJob(new NC_UpdateCNDSConsumer(contacts));
                            }
                        }else{
                            //Create New Consumer In CNDS
                            if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_CreateCNDSConsumer(contacts));
                            }
                        }
                    }else {
                        contacts[0].Allow_Resync__c=true; 
                        update contacts;
                        NC_CNDSUtility.insertErrorRecord(endPoint,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,responseWrapper.STATUS,contacts[0]);
                    }


                }else{
                    //Create Error Object record
                    contacts[0].Allow_Resync__c=true;
                    update contacts;
                    //insertErrorRecord(String endPoint,String req, String res, String error_Desc, String statusCode, Contact con)
                    NC_CNDSUtility.insertErrorRecord(endPoint,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,responseWrapper.STATUS,contacts[0]);

                }
            }

        }
    }

    private void getResultMatchCount(Contact contactRecord, NC_CNDSWrapper.PersonaSearchResponse person, Map<String, Integer> resultMatchCount) {
        Integer count = 0;
        List<String> raceCodes = contactRecord.Race__c.split(';');
        if(person.LANGUAGE_PREFRENCE == contactRecord.Primary_Language__c) {
            count++;
        }
        if(raceCodes.size() > 0 && person.RACE_CODE1 == raceCodes[0]) {
            count++;
        }
        if(raceCodes.size() > 1 && person.RACE_CODE1 == raceCodes[1]) {
            count++;
        }
        if(raceCodes.size() > 2 && person.RACE_CODE1 == raceCodes[2]) {
            count++;
        }
        if(raceCodes.size() > 3 && person.RACE_CODE1 == raceCodes[3]) {
            count++;
        }
        if(raceCodes.size() > 4 && person.RACE_CODE1 == raceCodes[4]) {
            count++;
        }
        if(contactRecord.MiddleName != null && person.MIDDLE_INITIAL == contactRecord.MiddleName.left(1)) {
            count++;
        }
        if(person.NAME_SUFFIX == contactRecord.Suffix) {
            count++;
        }
        resultMatchCount.put(person.IDENTIFIER + person.CHECK_DIGIT, count);
    }

}