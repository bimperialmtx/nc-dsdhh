/**
 * Created by ashishpandey on 08/07/21.
 * External Assessor Sync With KLAS
 */

public class NC_NDBEDP_TrainerCreateUpdate implements Queueable,Database.AllowsCallouts{
    public List<Account> accounts;
    public NC_NDBEDP_TrainerCreateUpdate(List<Account> accList){
        accounts = accList ;

    }
    public void execute(QueueableContext qc){

        NC_NDBEDPRequestWrapper requestBody = new NC_NDBEDPRequestWrapper();
        List<NC_NDBEDPRequestWrapper.PatronContacts> patronContacts = new List<NC_NDBEDPRequestWrapper.PatronContacts>();
        List<NC_NDBEDPRequestWrapper.PatronContactPrefs> patronContactPrefs = new List<NC_NDBEDPRequestWrapper.PatronContactPrefs>();

        //****Map of County Name Vs Code***************
        Map<String,String> countyNameVsCode = new Map<String, String>();
        for(County_Codes_and_Names__mdt mtd :[SELECT Id,County_Code__c,County_Name__c FROM County_Codes_and_Names__mdt]){
            countyNameVsCode.put(mtd.County_Name__c,mtd.County_Code__c);
        }

        //***Language Map****************
        Map<String, String> languageMap = new Map<String, String>();
        languageMap.put('English', 'EN');
        languageMap.put('Spanish', 'SP');
        languageMap.put('Signed English', 'SEE');
        languageMap.put('ASL(American Sign Language)', 'ASL');
        languageMap.put('No Formal Language', 'NFL');


        //****Setting up the request param***************
        requestBody.PatronID= accounts[0].Patron_ID__c!=null?accounts[0].Patron_ID__c:'';
        requestBody.StatusCode= accounts[0].Status_Code__c!=null?accounts[0].Status_Code__c:'A';
        requestBody.LastName= accounts[0].Last_Name__c!=null?accounts[0].Last_Name__c:null;
        requestBody.FirstName= accounts[0].First_Name__c!=null?accounts[0].First_Name__c:null;
        requestBody.MI= accounts[0].Middle_Name__c!=null?accounts[0].Middle_Name__c.left(1):null;
        if (accounts[0].Suffix__c!=null && (accounts[0].Suffix__c=='Esq' || accounts[0].Suffix__c=='III' || accounts[0].Suffix__c=='IV' || accounts[0].Suffix__c=='JR' || accounts[0].Suffix__c=='PHD' || accounts[0].Suffix__c=='SR')) {
            requestBody.SuffixCode=accounts[0].Suffix__c;
        }else {
            requestBody.SuffixCode='';
        }
        requestBody.BirthDate= accounts[0].BirthDate__c!=null?String.valueOf(accounts[0].BirthDate__c):'';
        //Setting up Gender Code
        if (accounts[0].Gender__c!=null) {
            requestBody.Gender= accounts[0].Gender__c=='Male'?'M':'F';
        }else {
            requestBody.Gender='';
        }
        //Setting up Ethnicity__c Code
        if (accounts[0].Ethnicity__c!=null) {
            requestBody.Ethnicity = accounts[0].Ethnicity__c!=null && accounts[0].Ethnicity__c=='Hispanic/Latino' ?'LAT':'OTH';
        }else {
            requestBody.Ethnicity= '';
        }

        String langCode='';
        if(accounts[0].Primary_Language__c=='English' || accounts[0].Primary_Language__c=='Spanish' || accounts[0].Primary_Language__c=='ASL(American Sign Language)'){
            langCode = languageMap.get(accounts[0].Primary_Language__c);
        }else {
            langCode='OTH';
        }
        requestBody.LanguageCode= langCode;
        requestBody.LibraryID= 'NC';
        //requestBody.RegEndDate= String.valueOf(Date.today()+365);
        requestBody.PatronType= 'TA';
        String CountyCode='';
        If(accounts[0].County__c!=null){
            CountyCode=countyNameVsCode.get(accounts[0].County__c);
        }

        //****Constructing the patronContacts phone request param*****
        if(accounts[0].Cell_Phone__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= accounts[0].Patron_Contact_Obj_MobilePhone__c!=null?accounts[0].Patron_Contact_Obj_MobilePhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='CellP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=accounts[0].Cell_Phone__c;

            patronContacts.add(patContact);
        }
        if(accounts[0].Work_Phone__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= accounts[0].Patron_Contact_Obj_WorkPhone__c!=null?accounts[0].Patron_Contact_Obj_WorkPhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='WorkP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=accounts[0].Work_Phone__c;

            patronContacts.add(patContact);
        }
        if(accounts[0].Alternative_Phone__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= accounts[0].Patron_Contact_Obj_AltPhone__c!=null?accounts[0].Patron_Contact_Obj_AltPhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='OthP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=accounts[0].Alternative_Phone__c;

            patronContacts.add(patContact);
        }
        //Video Phone
        if(accounts[0].Video_Phone__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= accounts[0].Patron_Contact_Obj_Video_Phone__c!=null?accounts[0].Patron_Contact_Obj_Video_Phone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='VidP';
            patContact.ContactMode='VID';
            patContact.ContactValue=accounts[0].Video_Phone__c;

            patronContacts.add(patContact);
        }
        //****Constructing the patronContacts Email request param*****
        if(accounts[0].Email__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= accounts[0].Patron_Contact_Obj_Email__c!=null?accounts[0].Patron_Contact_Obj_Email__c:'';
            patContact.ContactType='EM';
            patContact.ContactSubType='Email';
            patContact.ContactMode='TXT';
            patContact.ContactValue=accounts[0].Email__c;

            patronContacts.add(patContact);
        }
        //****Constructing the patronContacts Address request param*****
        //Physical Address
        if(accounts[0].BillingStreet!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= accounts[0].Patron_Contact_Obj_Add__c!=null?accounts[0].Patron_Contact_Obj_Add__c:'';
            patContact.ContactType ='ADDR';
            patContact.ContactSubType ='HomeA';
            patContact.ContactMode ='BRL';
            patContact.ContactValue = accounts[0].BillingStreet;
            patContact.Address = accounts[0].BillingStreet;
            patContact.City = accounts[0].BillingCity!=null?accounts[0].BillingCity:'';
            patContact.PostalCode = accounts[0].BillingPostalCode!=null?accounts[0].BillingPostalCode:'';
            patContact.CountyCode = CountyCode;
            if (accounts[0].BillingCountryCode!=null) {
                patContact.CountryCode = accounts[0].BillingCountryCode=='US'?'USA':accounts[0].BillingCountryCode;
            }else {
                patContact.CountryCode='';
            }
            //patContact.CountryCode = accounts[0].BillingCountryCode;
            patContact.StateCode = accounts[0].BillingStateCode!=null?accounts[0].BillingStateCode:'';

            patronContacts.add(patContact);
        }

        //****Constructing the patronContacts Preferred Method request param*****
        if (accounts[0].Preferred_Method_of_Contact__c!=null) {
            NC_NDBEDPRequestWrapper.PatronContactPrefs patContactPref = new NC_NDBEDPRequestWrapper.PatronContactPrefs();
            if(accounts[0].Preferred_Method_of_Contact__c=='Email'){
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='';
                patContactPref.Order ='1';
                patContactPref.ContactValue = accounts[0].Email__c;
                patContactPref.ContactSubType ='Email';
                patContactPref.ContactType ='EM';
                patContactPref.PatContactPrefType ='';
            }else if (accounts[0].Preferred_Method_of_Contact__c=='Cell Phone') {
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = accounts[0].Cell_Phone__c!=null?accounts[0].Cell_Phone__c:'';
                patContactPref.ContactSubType ='CellP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / CellP';
            }else if (accounts[0].Preferred_Method_of_Contact__c=='Work Phone') {
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = accounts[0].Work_Phone__c;
                patContactPref.ContactSubType ='WorkP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / CellP';
            }else if (accounts[0].Preferred_Method_of_Contact__c=='Alternative Phone') {
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = accounts[0].Alternative_Phone__c!=null?accounts[0].Alternative_Phone__c:'';
                patContactPref.ContactSubType ='OthP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / CellP';
            }else if(accounts[0].Preferred_Method_of_Contact__c=='Video Phone'){
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = accounts[0].Video_Phone__c;
                patContactPref.ContactSubType ='VidP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / VidP';
            }
            patronContactPrefs.add(patContactPref);

        }

        //****Setting up the patronContacts request param*****
        requestBody.PatronContacts=patronContacts;
        //****Setting up the patronContactPrefs request param*****
        requestBody.PatronContactPrefs=patronContactPrefs;


        String body= JSON.serialize(requestBody);


        String api_key = String.valueOf(Label.NDBEDP_Key);
        String endPointTemp = String.valueOf(Label.NDBEDP_Patron_Search_Create_N1_N2);
        Http h = new Http();
        HttpRequest httpReq = new HttpRequest();

        httpReq.setMethod('POST');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPointTemp);
        httpReq.setBody(body);
        HttpResponse res;
        try{
            res = h.send(httpReq);
        }catch (Exception e){
            accounts[0].Allow_NDBEDP_Resync__c=true;
            update accounts;
            NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,body,e.getMessage(),e.getMessage(),'503',accounts[0]);
        }


        NC_NDBEDPResponseWrapper responseWrapper = (NC_NDBEDPResponseWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPResponseWrapper.class);

        if(res.getStatusCode() == 200) {
            if(responseWrapper.STATUS!=500){
                Account acc =[SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                        Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM Account WHERE Id=:accounts[0].Id];

                acc.Patron_ID__c =responseWrapper.Patron.PatronID;
                acc.Patron_Obj__c =responseWrapper.Patron.PatronObj;
                acc.Library_ID__c='NC';

                if (responseWrapper.Patron.PatronContacts!=null) {
                    for(NC_NDBEDPResponseWrapper.PatronContacts patContact :responseWrapper.Patron.PatronContacts){
                        if(patContact.ContactType=='ADDR' && patContact.ContactSubType=='HomeA'){
                            acc.Address_Link_Obj__c = patContact.AddressLinkObj;
                            acc.Patron_Contact_Obj_Add__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='EM' && patContact.ContactSubType=='Email'){
                            acc.Patron_Contact_Obj_Email__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='CellP'){
                            acc.Patron_Contact_Obj_MobilePhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='WorkP'){
                            acc.Patron_Contact_Obj_WorkPhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='OthP'){
                            acc.Patron_Contact_Obj_AltPhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='VidP'){
                            acc.Patron_Contact_Obj_Video_Phone__c = patContact.PatronContactObj;
                        }

                    }
                }

                acc.Allow_NDBEDP_Resync__c=false;
                acc.Status_Code__c='A';
                try{
                    update acc;
                }catch (Exception e){
                    NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,body,e.getMessage(),e.getMessage(),'503',accounts[0]);
                }

            }else {
                accounts[0].Allow_NDBEDP_Resync__c=true;
                update accounts;
                NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),accounts[0]);
            }

        }else{
            accounts[0].Allow_NDBEDP_Resync__c=true;
            update accounts;
            NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),accounts[0]);
        }

    }

}