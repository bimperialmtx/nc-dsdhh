/**
 * Created by ashishpandey on 30/06/21.
 */

public class NC_NDBEDP_PatronCreateUpdate implements Queueable,Database.AllowsCallouts{

    public List<Contact> contacts;
    public NC_NDBEDP_PatronCreateUpdate(List<Contact> conList){
        contacts = conList ;

    }
    public void execute(QueueableContext qc){
        Contact contactObj;
        for(Contact con :[SELECT Id,Video_Phone_Number__c,Patron_Contact_Obj_Video_Phone__c,Ethnicity__c,OtherCountryCode,OtherStateCode,Patron_Contact_Obj_Add__c,Patron_Type__c,Allow_NDBEDP_Resync__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,Patron_Contact_Obj_Email__c,County__c,Preferred_Contact_Method__c,Status_Code__c,Reg_End_Date__c,Patron_Obj__c,Address_Link_Obj__c,Patron_Contact_Obj__c,Library_ID__c,Email,Alt_Phone_Number__c,Work_Phone_Number__c,Cell_Phone_Number__c, FirstName,MiddleName,BirthDate,Primary_Language__c,Suffix,Hispanic_Ethnicity__c,LastName,Gender__c,MobilePhone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,Patron_ID__c from Contact WHERE Id=:contacts[0].Id]){
            contactObj=con;
        }

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
        requestBody.PatronID= contactObj.Patron_ID__c!=null?contactObj.Patron_ID__c:'';
        requestBody.StatusCode= contactObj.Status_Code__c!=null?contactObj.Status_Code__c:'A';
        requestBody.LastName= contactObj.LastName!=null?contactObj.LastName:null;
        requestBody.FirstName= contactObj.FirstName!=null?contactObj.FirstName:null;
        requestBody.MI= contactObj.MiddleName!=null?contactObj.MiddleName.left(1):null;
        if (contactObj.Suffix!=null && (contactObj.Suffix=='Esq' || contactObj.Suffix=='III' || contactObj.Suffix=='IV' || contactObj.Suffix=='JR' || contactObj.Suffix=='PHD' || contactObj.Suffix=='SR')) {
            requestBody.SuffixCode=contactObj.Suffix;
        }else {
            requestBody.SuffixCode='';
        }
        requestBody.BirthDate= String.valueOf(contactObj.BirthDate);
        //Setting up Gender Code
        if (contactObj.Gender__c!=null) {
            requestBody.Gender= contactObj.Gender__c=='Male'?'M':'F';
        }else {
            requestBody.Gender='';
        }
        //Setting up Ethnicity__c Code
        if (contactObj.Ethnicity__c!=null) {
            requestBody.Ethnicity = contactObj.Ethnicity__c!=null && contactObj.Ethnicity__c=='Hispanic/Latino' ?'LAT':'OTH';
        }else {
            requestBody.Ethnicity= '';
        }
        //Setting up langCode Code
        String langCode='';
        if(contactObj.Primary_Language__c=='English' || contactObj.Primary_Language__c=='Spanish' || contactObj.Primary_Language__c=='ASL(American Sign Language)'){
            langCode = languageMap.get(contactObj.Primary_Language__c);
        }else {
            langCode='OTH';
        }
        requestBody.LanguageCode= langCode;
        requestBody.LibraryID= 'NC';
        requestBody.RegEndDate= String.valueOf(Date.today()+365);
        requestBody.PatronType= 'CNS';
        String CountyCode='';
        If(contactObj.County__c!=null){
            CountyCode=countyNameVsCode.get(contactObj.County__c);
        }

        //****Constructing the patronContacts phone request param*****
        //Cell Phone
        if(contactObj.Cell_Phone_Number__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= contactObj.Patron_Contact_Obj_MobilePhone__c!=null?contactObj.Patron_Contact_Obj_MobilePhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='CellP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=contactObj.Cell_Phone_Number__c;

            patronContacts.add(patContact);
        }
        //Work Phone
        if(contactObj.Work_Phone_Number__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= contactObj.Patron_Contact_Obj_WorkPhone__c!=null?contactObj.Patron_Contact_Obj_WorkPhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='WorkP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=contactObj.Work_Phone_Number__c;

            patronContacts.add(patContact);
        }
        //Alt Phone
        if(contactObj.Alt_Phone_Number__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= contactObj.Patron_Contact_Obj_AltPhone__c!=null?contactObj.Patron_Contact_Obj_AltPhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='OthP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=contactObj.Alt_Phone_Number__c;

            patronContacts.add(patContact);
        }
        //Video Phone
        if(contactObj.Video_Phone_Number__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= contactObj.Patron_Contact_Obj_Video_Phone__c!=null?contactObj.Patron_Contact_Obj_Video_Phone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='VidP';
            patContact.ContactMode='VID';
            patContact.ContactValue=contactObj.Video_Phone_Number__c;

            patronContacts.add(patContact);
        }
        //****Constructing the patronContacts Email request param*****
        if(contactObj.Email!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= contactObj.Patron_Contact_Obj_Email__c!=null?contactObj.Patron_Contact_Obj_Email__c:'';
            patContact.ContactType='EM';
            patContact.ContactSubType='Email';
            patContact.ContactMode='TXT';
            patContact.ContactValue=contactObj.Email;

            patronContacts.add(patContact);
        }
        //****Constructing the patronContacts Address request param*****
        //Physical Address
        if(contactObj.OtherStreet!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= contactObj.Patron_Contact_Obj_Add__c!=null?contactObj.Patron_Contact_Obj_Add__c:'';
            patContact.ContactType ='ADDR';
            patContact.ContactSubType ='HomeA';
            patContact.ContactMode ='BRL';
            patContact.ContactValue = contactObj.OtherStreet;
            patContact.Address = contactObj.OtherStreet;
            patContact.City = contactObj.OtherCity!=null?contactObj.OtherCity:'';
            patContact.PostalCode = contactObj.OtherPostalCode!=null?contactObj.OtherPostalCode:'';
            patContact.CountyCode = CountyCode;
            if (contactObj.OtherCountryCode!=null) {
                patContact.CountryCode = contactObj.OtherCountryCode=='US'?'USA':contactObj.OtherCountryCode;
            }else {
                patContact.CountryCode='';
            }
            //patContact.CountryCode = contacts[0].OtherCountryCode;
            patContact.StateCode = contactObj.OtherStateCode;

            patronContacts.add(patContact);
        }

        //****Constructing the patronContacts Preferred Method request param*****
        if (contactObj.Preferred_Contact_Method__c!=null) {
            NC_NDBEDPRequestWrapper.PatronContactPrefs patContactPref = new NC_NDBEDPRequestWrapper.PatronContactPrefs();
            if(contactObj.Preferred_Contact_Method__c=='Email'){
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = contactObj.Email;
                patContactPref.ContactSubType ='Email';
                patContactPref.ContactType ='EM';
                patContactPref.PatContactPrefType ='EM/HomeE';
            }else if (contactObj.Preferred_Contact_Method__c=='Cell Phone Number') {
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = contactObj.Cell_Phone_Number__c;
                patContactPref.ContactSubType ='CellP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / CellP';
            }else if (contactObj.Preferred_Contact_Method__c=='Work Phone Number') {
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = contactObj.Work_Phone_Number__c;
                patContactPref.ContactSubType ='WorkP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / WorkP';
            }else if (contactObj.Preferred_Contact_Method__c=='Alt Phone Number') {
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = contactObj.Alt_Phone_Number__c;
                patContactPref.ContactSubType ='OthP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / OthP'; 
            }else if(contactObj.Preferred_Contact_Method__c=='Video Phone Number'){
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = contactObj.Video_Phone_Number__c;
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
        String endPoint = String.valueOf(Label.NDBEDP_Patron_Search_Create_N1_N2);
        Http h = new Http();
        HttpRequest httpReq = new HttpRequest();

        httpReq.setMethod('POST');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint);
        httpReq.setBody(body);
        HttpResponse res;
        try{
            res = h.send(httpReq);
        }catch (Exception e){
            contacts[0].Allow_NDBEDP_Resync__c=true;
            update contacts;
            NC_CNDSUtility.insertNDBEDPError(endPoint,body,e.getMessage(),e.getMessage(),'503',contacts[0]);
        }

        NC_NDBEDPResponseWrapper responseWrapper = (NC_NDBEDPResponseWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPResponseWrapper.class);

        if(res.getStatusCode() == 200) {
            if(responseWrapper.STATUS!=500){
                contacts[0].Patron_ID__c =responseWrapper.Patron.PatronID;
                contacts[0].Patron_Obj__c =responseWrapper.Patron.PatronObj; 
                contacts[0].Library_ID__c='NC';

                if (responseWrapper.Patron.PatronContacts!=null) {
                    for(NC_NDBEDPResponseWrapper.PatronContacts patContact :responseWrapper.Patron.PatronContacts){
                        if(patContact.ContactType=='ADDR' && patContact.ContactSubType=='HomeA'){
                            contacts[0].Address_Link_Obj__c = patContact.AddressLinkObj;
                            contacts[0].Patron_Contact_Obj_Add__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='EM' && patContact.ContactSubType=='Email'){
                            contacts[0].Patron_Contact_Obj_Email__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='CellP'){
                            contacts[0].Patron_Contact_Obj_MobilePhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='WorkP'){
                            contacts[0].Patron_Contact_Obj_WorkPhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='OthP'){
                            contacts[0].Patron_Contact_Obj_AltPhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='VidP'){
                            contacts[0].Patron_Contact_Obj_Video_Phone__c = patContact.PatronContactObj;
                        }

                    }
                }

                contacts[0].Allow_NDBEDP_Resync__c=false;
                contacts[0].Status_Code__c='A';
                if(contacts[0].Reg_End_Date__c==null){
                    contacts[0].Reg_End_Date__c= date.today()+365;
                }

                try{
                    update contacts;
                }catch (Exception e){
                    NC_CNDSUtility.insertNDBEDPError(endPoint,body,e.getMessage(),e.getMessage(),'503',contacts[0]);
                }

            }else {
                contacts[0].Allow_NDBEDP_Resync__c=true;
                update contacts;
                NC_CNDSUtility.insertNDBEDPError(endPoint,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),contacts[0]);
            }

        }else{
            contacts[0].Allow_NDBEDP_Resync__c=true;
            update contacts;
            NC_CNDSUtility.insertNDBEDPError(endPoint,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),contacts[0]);
        }

    }
}