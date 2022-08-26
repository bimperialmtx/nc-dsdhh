/**
 * Created by ashishpandey on 01/07/21.
 * NDBEDP Patron search by id
 */

public class NC_NDBEDP_PatronSearchById implements Queueable,Database.AllowsCallouts{

    public List<Contact> contacts;
    public NC_NDBEDP_PatronSearchById(List<Contact> conList){
        contacts = conList ;

    }
    public void execute(QueueableContext qc){

        Contact contactObj;//null
        for(Contact con :[SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c
        FROM Contact WHERE Id=:contacts[0].Id]){
            contactObj=con;
        }
        //***Language Map****************
        Map<String, String> languageMap = new Map<String, String>();
        languageMap.put('ASL', 'ASL(American Sign Language)');
        languageMap.put('EN', 'English');
        languageMap.put('NFL', 'No Formal Language');
        languageMap.put('SP', 'Spanish');
        languageMap.put('SEE', 'Signed English');

        //****Map of County Name Vs Code***************
        Map<String,String> countyNameVsCode = new Map<String, String>();
        for(County_Codes_and_Names__mdt mtd :[SELECT Id,County_Code__c,County_Name__c FROM County_Codes_and_Names__mdt]){
            countyNameVsCode.put(mtd.County_Name__c,mtd.County_Code__c);
        }


        String api_key = String.valueOf(Label.NDBEDP_Key);
        //****Setting up the request param*****
        String patronId = contactObj!=null?contactObj.Patron_ID__c:'';

        String patronType = 'CNS';
        String endPointTemp = String.valueOf(Label.NDBEDP_Patron_Search_Create_N1_N2);
        String endPoint= endPointTemp+'?PatronId='+patronId;
        //String endPoint= 'https://eis.dhstst.nc.gov/ws/rest/klas/patrons?PatronId='+patronId;

        Http h = new Http();
        HttpResponse res;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint);

        try{
            res = h.send(httpReq);
        }catch (Exception e){
            contacts[0].Allow_NDBEDP_Resync__c=true;
            update contacts;
            NC_CNDSUtility.insertNDBEDPError(endPoint,patronId,e.getMessage(),e.getMessage(),'503',contacts[0]);
        }
        if(res!=null){
            NC_NDBEDPWrapper responseWrapper = (NC_NDBEDPWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPWrapper.class);
            if(responseWrapper.STATUS == 200) {
                if(responseWrapper.patrons!=null){
                    String patronContactObj;
                    String addressLinkObj;
                    for(NC_NDBEDPWrapper.patrons person:responseWrapper.patrons){
                        if(person.PatronContacts!=null){
                            for (NC_NDBEDPWrapper.PatronContacts patronCon:person.PatronContacts){
                                if(patronCon.PatronContactObj!=null && patronCon.ContactType=='ADDR' && patronCon.ContactSubType=='HomeA'){
                                    patronContactObj=patronCon.PatronContactObj;
                                    addressLinkObj=patronCon.AddressLinkObj;
                                }
                            }
                        }
                    }
                    if (patronContactObj!=null) {
                        contacts[0].Patron_Contact_Obj_Add__c=patronContactObj;
                        contacts[0].Address_Link_Obj__c=addressLinkObj;
                        update contacts;
                    }

                    for(NC_NDBEDPWrapper.patrons person:responseWrapper.patrons){
                        String genderCode;
                        if (contactObj.Gender__c!=null) {
                            genderCode= contactObj.Gender__c=='Male'?'M':'F';
                        }
                        if ((contactObj.Primary_Language__c!=null && languageMap.get(person.LanguageCode)!=contactObj.Primary_Language__c) || (person.GenderCode!=genderCode)) {
                            if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_NDBEDP_PatronCreateUpdate(contacts));
                            }
                        }else
                        if(person.PatronContacts!=null){
                            for (NC_NDBEDPWrapper.PatronContacts patronCon:person.PatronContacts){

                                if (patronCon.CountyCode!= countyNameVsCode.get(contactObj.County__c)
                                    || patronCon.City!=contactObj.OtherCity
                                    || patronCon.PostalCode!=contactObj.OtherPostalCode
                                    || patronCon.StateCode!=contactObj.OtherStateCode
                                    || patronCon.ContactType=='PH' && patronCon.ContactSubType=='CellP' && patronCon.ContactValue!=contactObj.Cell_Phone_Number__c
                                    || patronCon.ContactType=='PH' && patronCon.ContactSubType=='WorkP' && patronCon.ContactValue!=contactObj.Work_Phone_Number__c
                                    || patronCon.ContactType=='PH' && patronCon.ContactSubType=='OthP' && patronCon.ContactValue!=contactObj.Alt_Phone_Number__c
                                    || patronCon.ContactType=='EM' && patronCon.ContactSubType=='Email' && patronCon.ContactValue!=contactObj.Email) {
                                        if(!Test.isRunningTest()){
                                         	System.enqueueJob(new NC_NDBEDP_PatronCreateUpdate(contacts));   
                                        }
                                    break;
                                }else {
                                    //contacts[0].Allow_NDBEDP_Resync__c=false;
                                    //update contacts;
                                }
                            }
                        }
                    }
                }else {
                    contacts[0].Allow_NDBEDP_Resync__c=true;
                    update contacts;
                    NC_CNDSUtility.insertNDBEDPError(endPoint,patronId,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),contacts[0]);
                }
            }else{
                contacts[0].Allow_NDBEDP_Resync__c=true;
                update contacts;
                //insertErrorRecord(String endPoint,String req, String res, String error_Desc, String statusCode, Contact con)
                NC_CNDSUtility.insertNDBEDPError(endPoint,patronId,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),contacts[0]);

            }
        }
    }

}