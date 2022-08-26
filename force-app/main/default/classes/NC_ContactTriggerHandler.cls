/*
*   Class Name: NC_ContactTriggerHandler
*   Description: Contact Trigger Handler -- Logics on insert, update and delete
*
*   Date              New/Modified            User                 Identifier                Description
*   28/04/2020           New            Shubham Dadhich(mtx)
*   25/05/2020         updated        hiten.aggarwal@mtxb2b.com
*/
public without sharing class NC_ContactTriggerHandler {
    
    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before Insert' trigger event
    @param          : List<Contact> newContactList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Contact> newContactList){
        populateAgeRange(newContactList,NULL);
        updateMailingCity(newContactList,NULL);
        updateDetailsFromCounty(newContactList,NULL);
        fetchRelatedCounty(newContactList);
        updateUserIdField(newContactList);
        raceValidation(newContactList, NULL);
        updateAlternatePhoneNumber(newContactList);
        updateCellPhoneNumber(newContactList);
        updateCaptelPhoneNumber(newContactList);
        updateHomePhoneNumber(newContactList);
        updateMobilePhoneNumber(newContactList);
        updateTTYPhoneNumber(newContactList);
        updateVideoPhoneNumber(newContactList);
        updateWorkPhoneNumber(newContactList);
    }
    
    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'after Insert' trigger event
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    public static void afterInsert(List<Contact> newList){
        createAlternativeContact(newList,NULL);
        contactIdEncrypted(newList);
    }
    
    /*
    *********************************************************
    @Method Name    : contactIdEncrypted
    @description    : Create encrypted id of contact and store in a field
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    public static void contactIdEncrypted(List<Contact> newList){
        List<Contact> contactList = new List<Contact>();
        for(Contact con:newList){
            Contact contactRecord = new Contact();
            contactRecord.id = con.id;
            contactRecord.Contact_Id_Encrypted__c=NC_CryptoEncryption.encodeString(contactRecord.Id);
            contactList.add(contactRecord);
        }
        //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Contact', contactList, 'update', true, 'NC_ContactTriggerHandler', 'contactIdEncrypted');
        //update decision.getRecords();
        update contactList;
        
    }
    
    private static Map<String, Boolean> dailyUpdateMap = new Map<String, Boolean>();

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<Contact> newList, Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Contact> newList, Map<Id,Contact> oldMap){
        createAlternativeContact(newList,oldMap);
        
        //callout to CNDS
        List<Contact> updatedContacts=new List<Contact> ();
        for(Contact contactRecord : newList){
            if((oldMap.get(contactRecord.Id).Name_Change_Document__c != contactRecord.Name_Change_Document__c && contactRecord.Name_Change_Document__c==true)
                    || (oldMap.get(contactRecord.Id).DOB_Document__c != contactRecord.DOB_Document__c && contactRecord.DOB_Document__c==true)
                    && contactRecord.Cnds_Identifier__c!=null){
                updatedContacts.add(contactRecord);
            }
            if(dailyUpdateMap.containsKey(contactRecord.id) && !dailyUpdateMap.get(contactRecord.id) && contactRecord.Allow_CNDS_Update_Sync__c==false && contactRecord.Cnds_Identifier__c!=null
                    && (oldMap.get(contactRecord.Id).Gender__c != contactRecord.Gender__c || oldMap.get(contactRecord.Id).Hispanic_Ethnicity__c != contactRecord.Hispanic_Ethnicity__c || oldMap.get(contactRecord.Id).Primary_Language__c != contactRecord.Primary_Language__c || oldMap.get(contactRecord.Id).Race__c != contactRecord.Race__c)){
                updatedContacts.add(contactRecord);
            }
        }
        if(!updatedContacts.isEmpty()){
             if(!Test.isRunningTest()) {
            System.enqueueJob(new NC_UpdateCNDSConsumer(updatedContacts));
             }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Contact> newContactList,Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Contact> newContactList,Map<Id,Contact> oldMap){
        populateAgeRange(newContactList,oldMap);
        updateMailingCity(newContactList,oldMap);
        updateDetailsFromCounty(newContactList,NULL);
        fetchRelatedCounty(newContactList);
        uncheckNameChangeDocument(newContactList,oldMap);
        raceValidation(newContactList, oldMap);
        ssnValidation(newContactList, oldMap);
        updateAlternatePhoneNumber(newContactList);
        updateCellPhoneNumber(newContactList);
        updateCaptelPhoneNumber(newContactList);
        updateHomePhoneNumber(newContactList);
        updateMobilePhoneNumber(newContactList);
        updateTTYPhoneNumber(newContactList);
        updateVideoPhoneNumber(newContactList);
        updateWorkPhoneNumber(newContactList);
    }
    
    /*
    *********************************************************
    @Method Name    : ssnValidation
    @description    : Create CNDS record of SSN number doesn't match
    @param          : List<Contact> newList, Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    private static void ssnValidation(List<Contact> newList, Map<Id,Contact> oldMap) {
        Boolean isDailyUpdate;
        List<Contact> createCNDSConsumerList = new List<Contact>();
        for(Contact con: newList) {
            isDailyUpdate = false;
            if((UserInfo.getUserId() == Label.Integration_User || Test.isRunningTest())  && con.Cnds_Identifier__c == oldMap.get(con.id).Cnds_Identifier__c
                    && con.Social_Security_Number__c != null && oldMap.get(con.id).Social_Security_Number__c != null
               		&& oldMap.get(con.id).Birthdate==con.Birthdate
                    && (con.Social_Security_Number__c.right(4) == '0000' || con.Social_Security_Number__c.right(4) == oldMap.get(con.id).Social_Security_Number__c.right(4))
                   ) {
                isDailyUpdate = true;
                con.Social_Security_Number__c = oldMap.get(con.id).Social_Security_Number__c;
            }else if(
                    (UserInfo.getUserId() == Label.Integration_User || Test.isRunningTest()) 
                    && con.Cnds_Identifier__c != null
                    && oldMap.get(con.id).Cnds_Identifier__c == con.Cnds_Identifier__c
                    && oldMap.get(con.id).Social_Security_Number__c != null
                    && con.Social_Security_Number__c != null
                    && (oldMap.get(con.id).Birthdate!=con.Birthdate || oldMap.get(con.id).Social_Security_Number__c.right(4) != con.Social_Security_Number__c.right(4))
                    //&& con.Social_Security_Number__c.right(4) != '0000'
                   ) {
                con.FirstName = oldMap.get(con.id).FirstName;
                con.MiddleName = oldMap.get(con.id).MiddleName;
                con.LastName = oldMap.get(con.id).LastName;
                con.Suffix = oldMap.get(con.id).Suffix;
                con.Gender__c = oldMap.get(con.id).Gender__c;
                con.Social_Security_Number__c = oldMap.get(con.id).Social_Security_Number__c;
                con.Birthdate = oldMap.get(con.id).Birthdate;
                con.Race__c = oldMap.get(con.id).Race__c;
                con.Ethnicity__c = oldMap.get(con.id).Ethnicity__c;
                con.Hispanic_Ethnicity__c = oldMap.get(con.id).Hispanic_Ethnicity__c;
                con.Primary_Language__c = oldMap.get(con.id).Primary_Language__c;
                createCNDSConsumerList.add(con);
            }
            dailyUpdateMap.put(con.id, isDailyUpdate);
        }
        if(createCNDSConsumerList.size() > 0) {
            System.enqueueJob(new NC_CreateCNDSConsumer(createCNDSConsumerList));
        }
    }
    
    /*
    *********************************************************
    @Method Name    : raceValidation
    @description    : IF 'Unreported' selected as a race value - it will be a single picklist else For the rest of the Race value, it can be multiple picklists
    @param          : List<Contact> newList, Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    private static void raceValidation(List<Contact> newList, Map<Id,Contact> oldMap) {
        for(Contact con: newList) {
            if(con.Ethnicity__c == 'Not Hispanic/Latino') {
                con.Hispanic_Ethnicity__c = 'Not Hispanic/Latino';
            }
            if(con.Race__c != null && con.Race__c.contains('Unreported') && con.Race__c.contains(';')) {
                con.addError('One value should be selected for Unreported Race');
            }
            if(oldMap != null
               && oldMap.get(con.Id).Race__c != con.Race__c
               && oldMap.get(con.Id).Race__c != null
               && con.Race__c == 'Unreported') {
                   con.addError('Race cannot be changed to Unreported if it is already reported');
               }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateAlternatePhoneNumber
    @description    : Update Alternate phone number from phone
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateAlternatePhoneNumber(List<Contact> newList){
        
        String phone='';
        for(Contact con: newList) {
            if(con.Alt_Phone_Number__c!=null){
                phone=String.valueOf(con.Alt_Phone_Number__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //     phone=phone.replace('1', '');
                    // }
                }
                con.Alt_Phone_Number__c=phone;
                
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateCellPhoneNumber
    @description    : Update phone from Cell phone number
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateCellPhoneNumber(List<Contact> newList){
        
        String phone='';
        for(Contact con: newList) {
            if(con.Cell_Phone_Number__c!=null){
                phone=String.valueOf(con.Cell_Phone_Number__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //     phone=phone.replace('1', '');
                    // }
                }
                con.Cell_Phone_Number__c=phone;
                
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateCaptelPhoneNumber
    @description    : Update phone from Captel
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateCaptelPhoneNumber(List<Contact> newList){
        
        String phone='';
        for(Contact con: newList) {
            if(con.Captel__c!=null){
                phone=String.valueOf(con.Captel__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //     phone=phone.replace('1', '');
                    // }
                }
                con.Captel__c=phone;
                
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateHomePhoneNumber
    @description    : Update phone from Home phone
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateHomePhoneNumber(List<Contact> newList){
        
        String phone='';
        for(Contact con: newList) {
            if(con.HomePhone!=null){
                phone=String.valueOf(con.HomePhone);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //     phone=phone.replace('1', '');
                    // }
                }
                con.HomePhone=phone;
                
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateMobilePhoneNumber
    @description    : Update phone from Mobile
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateMobilePhoneNumber(List<Contact> newList){
        
        String phone='';
        for(Contact con: newList) {
            if(con.MobilePhone!=null){
                phone=String.valueOf(con.MobilePhone);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //     phone=phone.replace('1', '');
                    // }
                }
                con.MobilePhone=phone;
                
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateTTYPhoneNumber
    @description    : Update phone from TTY
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateTTYPhoneNumber(List<Contact> newList){
        
        String phone='';
        for(Contact con: newList) {
            if(con.TTY__c!=null){
                phone=String.valueOf(con.TTY__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //     phone=phone.replace('1', '');
                    // }
                }
                con.TTY__c=phone;
                
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateVideoPhoneNumber
    @description    : Update phone from Video phone
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateVideoPhoneNumber(List<Contact> newList){
        
        String phone='';
        for(Contact con: newList) {
            if(con.Video_Phone_Number__c!=null){
                phone=String.valueOf(con.Video_Phone_Number__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //     phone=phone.replace('1', '');
                    // }
                }
                con.Video_Phone_Number__c=phone;
                
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateWorkPhoneNumber
    @description    : Update phone from Work phone
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateWorkPhoneNumber(List<Contact> newList){
        
        String phone='';
        for(Contact con: newList) {
            if(con.Work_Phone_Number__c!=null){
                phone=String.valueOf(con.Work_Phone_Number__c);
                if(phone.contains('-')){
                    phone=phone.replaceAll('-','');
                }
                if(phone.contains('(')){
                    phone=phone.replace('(','');
                }
                if(phone.contains(')')){
                    phone=phone.replace(')','');
                }
                if(phone.contains(' ')){
                    phone=phone.replace(' ','');
                }
                if(phone.contains('+1')){
                    phone = phone.replace('+1','');
                    // if(phone.contains('1'))
                    // {
                    //     phone=phone.replace('1', '');
                    // }
                }
                con.Work_Phone_Number__c=phone;
                
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : uncheckNameChangeDocument
    @description    : uncheck Name ChangeDocument to allow r-sync to CNDS
    @param          : List<Contact> newList, Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    private static void uncheckNameChangeDocument(List<Contact> newList, Map<Id,Contact> oldMap) {
        for (Contact con : newList) {
            if(UserInfo.getUserId() != Label.Integration_User) {
                if (con.FirstName != oldMap.get(con.Id).FirstName || con.LastName != oldMap.get(con.Id).LastName || con.MiddleName != oldMap.get(con.Id).MiddleName || con.Suffix != oldMap.get(con.Id).Suffix) {
                    con.Name_Change_Document__c = false;
                    if(con.Cnds_Identifier__c!=null){
                        con.Is_Name_Updated__c = true;
                    }
                }
                if (con.Name_Change_Document__c != oldMap.get(con.Id).Name_Change_Document__c && con.Name_Change_Document__c==true) {
                    con.Is_Name_Updated__c = false;
                }
                
                if (con.Birthdate != oldMap.get(con.Id).Birthdate) {
                    con.DOB_Document__c = false;
                    if(con.Cnds_Identifier__c!=null){
                        con.Is_DOB_Updated__c = true;
                    }
                }
                if (con.DOB_Document__c != oldMap.get(con.Id).DOB_Document__c && con.DOB_Document__c==true) {
                    con.Is_DOB_Updated__c = false;
                }   
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : populateAgeRange
    @description    : Populate Age Range
    @param          : List<Contact> newList, Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    private static void populateAgeRange(List<Contact> newList, Map<Id,Contact> oldMap){
        for(Contact selectedContact : newList){
            if((oldMap == NULL || oldMap.get(selectedContact.Id).Birthdate != selectedContact.Birthdate) 
               && selectedContact.Birthdate != NULL){
                   if(selectedContact.Age__c != NULL){
                       if(selectedContact.Age__c >= 0 && selectedContact.Age__c <= 18){
                           selectedContact.Age_Range__c = '0-18';
                       }else if(selectedContact.Age__c >= 19 && selectedContact.Age__c <= 24){
                           selectedContact.Age_Range__c = '19-24';
                       }else if(selectedContact.Age__c >= 25 && selectedContact.Age__c <= 34){
                           selectedContact.Age_Range__c = '25-34';
                       }else if(selectedContact.Age__c >= 35 && selectedContact.Age__c <= 44){
                           selectedContact.Age_Range__c = '35-44';
                       }else if(selectedContact.Age__c >= 45 && selectedContact.Age__c <= 54){
                           selectedContact.Age_Range__c = '45-54';    
                       }else if(selectedContact.Age__c >= 55 && selectedContact.Age__c <= 59){
                           selectedContact.Age_Range__c = '55-59';
                       }else if(selectedContact.Age__c >= 60 && selectedContact.Age__c <= 64){
                           selectedContact.Age_Range__c = '60-64';
                       }else if(selectedContact.Age__c >= 65 && selectedContact.Age__c <= 74){
                           selectedContact.Age_Range__c = '65-74';
                       }else if(selectedContact.Age__c >= 75 && selectedContact.Age__c <= 84){
                           selectedContact.Age_Range__c = '75-84';
                       }else if(selectedContact.Age__c >= 85 && selectedContact.Age__c <= 99){
                           selectedContact.Age_Range__c = '85-99';
                       }else if(selectedContact.Age__c >= 100){
                           selectedContact.Age_Range__c = '100+';
                       }
                   }
               }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : createAlternativeContact
    @description    : Create alternate contact record for primary contact on insert or update
    @param          : List<Contact> newList, Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    private static void createAlternativeContact(List<Contact> newList, Map<Id,Contact> oldMap){
        Map<Contact,Id> contactIdToPrimaryAlternativeContactMap = new Map<Contact,Id>();
        List<Alternate_Contact__c> alternateContactList = new List<Alternate_Contact__c>();
        List<Id> contactWithInvalidAlternateContactList = new List<Id>();
        Map<Id,Id> consumerToAlreadyPresentAlternateContactMap = new Map<Id,Id>();
        for(Contact contactRecord : newList){
            if((oldMap == null || oldMap.get(contactRecord.Id).Primary_Alternative_Contact__c != contactRecord.Primary_Alternative_Contact__c)
               && contactRecord.Primary_Alternative_Contact__c != NULL){
                   if(contactRecord.Id == contactRecord.Primary_Alternative_Contact__c){
                       contactRecord.addError('Consumer cannot be alternate contact for itself.');    
                   }
                   contactIdToPrimaryAlternativeContactMap.put(contactRecord, contactRecord.Primary_Alternative_Contact__c);
               }
        }
        
        for(Alternate_Contact__c alternativeContact : [SELECT Id, Consumer__c, Related_To__c ,Consumer__r.Is_Minor__c,
                                                       Relationship_Type__c, Primary_Alternate_Contact__c
                                                       FROM Alternate_Contact__c 
                                                       WHERE Related_To__c IN: contactIdToPrimaryAlternativeContactMap.Values() 
                                                       AND Consumer__c IN: contactIdToPrimaryAlternativeContactMap.keySet()]){
                                                           if(alternativeContact.Consumer__r.Is_Minor__c && (alternativeContact.Relationship_Type__c != 'Parent' && alternativeContact.Relationship_Type__c != 'Guardian')){
                                                               contactWithInvalidAlternateContactList.add(alternativeContact.Consumer__c);                             
                                                           }else{
                                                               alternativeContact.Primary_Alternate_Contact__c = True;
                                                               alternateContactList.add(alternativeContact);  
                                                               consumerToAlreadyPresentAlternateContactMap.put(alternativeContact.Consumer__c, alternativeContact.Id);
                                                           }
                                                       }
        
        for(Contact contactRecord : contactIdToPrimaryAlternativeContactMap.keySet()){
            if(contactWithInvalidAlternateContactList.contains(contactRecord.Id)){
                contactRecord.addError('Please provide a primary alternate contact with relation type parent or guardian');
            }
            if(!(consumerToAlreadyPresentAlternateContactMap.containsKey(contactRecord.Id)) &&  !(contactWithInvalidAlternateContactList.contains(contactRecord.Id))){
                if(contactRecord.Is_Minor__c && contactRecord.Relationship_Type__c != 'Parent' && contactRecord.Relationship_Type__c != 'Guardian'){
                    contactRecord.addError('Please provide a primary alternate contact with relation type parent or guardian');
                }else{
                    Alternate_Contact__c alternateContact = new Alternate_Contact__c();
                    alternateContact.Consumer__c = contactRecord.Id;
                    alternateContact.Related_To__c = contactRecord.Primary_Alternative_Contact__c;
                    alternateContact.Power_of_Attorney__c = contactRecord.Power_of_Attorney__c;
                    alternateContact.Relationship_Type__c = contactRecord.Relationship_Type__c;
                    alternateContact.Legal_Guardian__c = contactRecord.Legal_Guardian__c;
                    alternateContact.Primary_Alternate_Contact__c = True;
                    alternateContactList.add(alternateContact);
                }
            }
        }
        
        if(!alternateContactList.isEmpty()){
            SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Alternate_Contact__c', alternateContactList, 'upsert', true,'NC_ContactTriggerHandler','createAlternativeContact');
            UPSERT decision1.getRecords();
            // Upsert alternateContactList;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : fetchRelatedCounty
    @description    : Fetch Related County on the basis of City And Zipcode and populate it on Contact
    @param          : List<Contact> newContactList
    @return         : void
    ********************************************************
    */
    private static void fetchRelatedCounty(List<Contact> newContactList){
        
        List<String> zipCodeList = new List<String>();
        List<String> cityList = new List<String>();
        Map<String, Id> mapOfRegionalAccountNameWithId = new Map<String, Id>();
        Id RecordTypeId_RegionaCenter = NC_Utility.RecordTypeUtilityMethod('Account',NC_Constant.Account_Regional_Center_RecordType);
        
        //Add Values to City List and Zip List
        for(Contact conRecord : newContactList){
            cityList.add(conRecord.OtherCity);
            zipCodeList.add(conRecord.OtherPostalCode);
        }
        
        //Fetch Regional Center Account
        for(Account accRegional : [SELECT Id, Name FROM Account WHERE RecordTypeId =: RecordTypeId_RegionaCenter WITH SECURITY_ENFORCED]){
            mapOfRegionalAccountNameWithId.put(accRegional.Name, accRegional.Id);
        }
        
        //Fethcing County On the basis of CityList and ZipList
        for(Regional_Center_And_County__mdt regionalCenterCountyRecord : [SELECT Id, Regional_Center__c, County__c, City__c, Zip_Code__c, Region__c FROM Regional_Center_And_County__mdt WHERE Zip_Code__c IN: zipCodeList AND City__c IN: cityList]){
            for(Contact conRecord : newContactList){
                if(regionalCenterCountyRecord.City__c == conRecord.OtherCity && regionalCenterCountyRecord.Zip_Code__c == conRecord.OtherPostalCode){
                    // Inserting Values in County Field
                    conRecord.County__c = regionalCenterCountyRecord.County__c;
                    conRecord.Region__c = regionalCenterCountyRecord.Region__c != NULL ? regionalCenterCountyRecord.Region__c : NULL;
                    if(mapOfRegionalAccountNameWithId.containsKey(regionalCenterCountyRecord.Regional_Center__c)){
                        conRecord.Regional_Center_Office__c = mapOfRegionalAccountNameWithId.get(regionalCenterCountyRecord.Regional_Center__c);
                    }
                }
            }
        }
        
    }
    
    /*
    *********************************************************
    @Method Name    : updateDetailsFromCounty
    @description    : Update details from County
    @param          : List<Contact> newList, Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    private static void updateDetailsFromCounty(List<Contact> newList, Map<Id,Contact> oldMap){
        Map<Contact,String> contactToCountyMap = new Map<Contact,String>();
        Map<String, Id> mapOfRegionalAccountNameWithId = new Map<String, Id>();
        Id RecordTypeId_RegionaCenter = NC_Utility.RecordTypeUtilityMethod('Account',NC_Constant.Account_Regional_Center_RecordType);
        
        for(Contact selectedContact : newList){
            if((oldMap == NULL || oldMap.get(selectedContact.Id).County__c != selectedContact.County__c) && selectedContact.County__c != NULL){
                if(selectedContact.County__c == 'Out of State' ){
                    selectedContact.Region__c = 'Out of State';
                }else{
                    contactToCountyMap.put(selectedContact ,selectedContact.County__c);
                }
                
                
            }
        }
        
        //Fetch Regional Center Account
        for(Account accRegional : [SELECT Id, Name FROM Account WHERE RecordTypeId =: RecordTypeId_RegionaCenter WITH SECURITY_ENFORCED]){
            mapOfRegionalAccountNameWithId.put(accRegional.Name, accRegional.Id);
        }
        
        for(Regional_Center_And_County__mdt regionalCenterCountyRecord : [SELECT Id, Regional_Center__c, County__c, City__c, Zip_Code__c, Region__c 
                                                                          FROM Regional_Center_And_County__mdt 
                                                                          WHERE County__c IN: contactToCountyMap.values()]){
                                                                              for(Contact contactRecord: contactToCountyMap.keySet()){
                                                                                  if(contactToCountyMap.get(contactRecord) == regionalCenterCountyRecord.County__c){
                                                                                      contactRecord.Region__c = regionalCenterCountyRecord.Region__c;
                                                                                      if(mapOfRegionalAccountNameWithId.containsKey(regionalCenterCountyRecord.Regional_Center__c)){
                                                                                          contactRecord.Regional_Center_Office__c = mapOfRegionalAccountNameWithId.get(regionalCenterCountyRecord.Regional_Center__c);
                                                                                      }
                                                                                  }                                                           
                                                                              }
                                                                          }
        
    }
    
    /*
    *********************************************************
    @Method Name    : updateMailingCity
    @description    : Update the Mailing address on contact same as other address(Physical Address)
    @param          : List<Contact> newList,Map<Id,Contact> oldMap
    @return         : void
    ********************************************************
    */
    private static void updateMailingCity(List<Contact> newList,Map<Id,Contact> oldMap){
        
        for(Contact selectedContact: newList){
            if((oldMap == Null || selectedContact.OtherCity != selectedContact.MailingCity
                || selectedContact.OtherCountry != selectedContact.MailingCountry
                || selectedContact.OtherPostalCode != selectedContact.MailingPostalCode
                || selectedContact.OtherStateCode != selectedContact.MailingStateCode
                ||  selectedContact.OtherStreet != selectedContact.MailingStreet)
               && selectedContact.Same_as_Physical__c){
                   selectedContact.MailingCity = String.isNotBlank(selectedContact.OtherCity) ? selectedContact.OtherCity : NULL;
                   selectedContact.MailingCountry = String.isNotBlank(selectedContact.OtherCountry) ? selectedContact.OtherCountry : NULL;
                   selectedContact.MailingPostalCode = String.isNotBlank(selectedContact.OtherPostalCode) ? selectedContact.OtherPostalCode : NULL;
                   selectedContact.MailingStateCode = String.isNotBlank(selectedContact.OtherStateCode) ? selectedContact.OtherStateCode : NULL;
                   selectedContact.MailingStreet = String.isNotBlank(selectedContact.OtherStreet) ? selectedContact.OtherStreet : NULL;
               }
        }
        
    }

    /*
    *********************************************************
    @Method Name    : updateUserIdField
    @description    : Generate and update user id field 
    @param          : List<Contact> newList
    @return         : void
    ********************************************************
    */
    private static void updateUserIdField(List<Contact> newList){
        
        Map<String,String> contactMap = new Map<String,String>();
        for(Contact con : [SELECT Id, User_Id__c FROM Contact WITH SECURITY_ENFORCED LIMIT 50000]){
            contactMap.put(con.User_Id__c, con.Id);
        }
        
        for(Contact con: newList){
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            String randomStr = key.substring(0,8);//8 digits
            
            if (contactMap.get(randomStr) ==null) {
                con.User_Id__c = randomStr;
            }else {
                con.User_Id__c = getRandomString();
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : getRandomString
    @description    : Generate random String
    @param          : 
    @return         : String
    ********************************************************
    */
    private static String getRandomString() {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String randomStr = key.substring(0,8);//8 digits
        return randomStr;
    }
    
}