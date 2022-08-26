/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_ConnectEquipmentController {

    /*
    *********************************************************
    @Method Name    : getRecordTypes
    @description    : Get case record type ids
    @param          : String recordId
    @return         : Map<String, String>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, String> getRecordTypes(String recordId){
        Map<String, String> recordTypeIdMap = new Map<String, String>();
        Boolean isNDBEDP = false;
        try {
            Id reqEquipmentId = NC_Utility.RecordTypeUtilityMethod('Request_Equipment__c','Equipment');
            Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
            Id ndbedpDemoRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Demo');
            for(Case caseObj: [SELECT recordTypeId FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED]) {
                if(caseObj.recordTypeId == ndbedpRecordTypeId || caseObj.recordTypeId == ndbedpDemoRecordTypeId) {
                    isNDBEDP = true;
                }
            }
            recordTypeIdMap.put('isNDBEDPCase', isNDBEDP+'');
            recordTypeIdMap.put('CaseNDBEDPId', ndbedpRecordTypeId);
            recordTypeIdMap.put('RequestEquipmentId', reqEquipmentId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return recordTypeIdMap;
    }
    
    /*
    *********************************************************
    @Method Name    : getEquipmentCategories
    @description    : Get NDBEDP Equipment categories from metadata and approved request validations
    @param          : String requestId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> getEquipmentCategories(String requestId){
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Equipment_Category__mdt> equipmentCategories = new Map<String, Equipment_Category__mdt>();
        List<Case> caseList = new List<Case>();
        Set<String> matReqStatusSet = new Set<String>{'Open','Pending'};
        Set<String> caseStatusSet = new Set<String>{'Denied','Closed'};
        String errorMsg = 'No equipment returned from KLAS database due to some problem. Please try again later';
        try {
            if(String.isNotBlank(requestId)) {
                caseList = [SELECT Status, MatReqStatus__c, MatRequestObj__c, InActive_Equipments__c FROM Case WHERE Id =: requestId];//WITH SECURITY_ENFORCED
                if(caseList.size() > 0 && caseStatusSet.contains(caseList[0].Status)) {
                    resultMap.put('errorMessage', 'New Equipment cannot be added as Request status is '+caseList[0].Status);
                    return resultMap;
                } else if(caseList.size() > 0 && caseList[0].Status == 'Approved' && caseList[0].MatRequestObj__c == null && !caseList[0].InActive_Equipments__c) {
                    resultMap.put('errorMessage', 'MatRequestObj should not be empty');
                    return resultMap;
                } else if (caseList.size() > 0 && caseList[0].Status == 'Approved' && caseList[0].MatRequestObj__c != null && !matReqStatusSet.contains(caseList[0].MatReqStatus__c)){
                    resultMap.put('errorMessage', 'New Equipment cannot be added as MatRequest status is '+caseList[0].MatReqStatus__c);
                    return resultMap;
                } else if(caseList.size() > 0 && caseList[0].Status == 'Approved' && caseList[0].MatRequestObj__c != null) {
                    String responseStr = NC_NDBEDPEquipmentCatalog.getEquipmentRequestStatus(requestId);
                    if(String.isNotBlank(responseStr)) {
                     	NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse response = (NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse)JSON.deserialize(responseStr, NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse.class);
                        if(response != null && response.STATUS == 200 && response.matRequests != null) {
                            for(NC_NDBEDPEquipmentCatalog.MatRequests matRequest: response.matRequests) {
                                if(String.isNotBlank(matRequest.MatReqStatus) && matRequest.MatReqStatus.toLowerCase() == 'cancelled') {
                                    resultMap.put('errorMessage', 'Cannot add new Equipment as MatReqStatus is cancelled');
                                }
                            }
                        } else if (response != null && response.STATUS != 200 && response.ERROR_DESCRIPTION != null) {
                            resultMap.put('errorMessage', response.ERROR_DESCRIPTION);
                        } else if (response != null) {
                            resultMap.put('errorMessage', String.valueOf(response));
                        }   
                    } else {
                        resultMap.put('errorMessage', errorMsg);
                    }
                }
            }
            equipmentCategories = Equipment_Category__mdt.getAll();
            resultMap.put('equipmentDetails', equipmentCategories);
        } catch (Exception ex) {
            AuraHandledException e = new AuraHandledException(ex.getMessage());
            e.setMessage(ex.getMessage());
            throw e;
        }
        return resultMap;
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveEquipments
    @description    : Get Equipments from KLAS
    @param          : 
    @return         : NC_ConnectEquipmentWrapper.EquipmentResponse
    ********************************************************
    */
    @AuraEnabled
    public static NC_ConnectEquipmentWrapper.EquipmentResponse retrieveEquipments(){
        String errorMsg = 'No equipment returned from KLAS database due to some problem. Please try again later';
        NC_ConnectEquipmentWrapper.EquipmentResponse response;
        List<NC_ConnectEquipmentWrapper.TtEqp> ttEqpList = new List<NC_ConnectEquipmentWrapper.TtEqp>();
        try {
            //String responseStr = '{"STATUS":"200","ERROR_DESCRIPTION":"ACTION COMPLETED SUCCESSFULLY","offset":0,"count":766,"eqp":{"ttEqp":[{"Annotations":"32 Cell Braille Notetaker with built-in WiFi and support for a 3G modem. Perkins style Keyboard.Deaf-Blind features include: HIMS unique, flipable LCD display and vibrate motor for signaling.Native support for IMAP e-mail and social networking such as Twitter and Google Talk.","Author":"HIMS","BibRecObj":"571153.9532","KlasID":"BRM-H3B","Medcode":"BRLM","ReplaceCost":"5595","Titl":"Braille Sense U2","ManPartNum":"H432B","URL":"http://www.hims-inc.com/products/braille-sense-u2/","ImageURL":"https://pndb.klas.com/www/images/BRM-H3B.jpg","ImageFileName":"BRM-H3B.jpg"},{"Annotations":"The WL54-CF is an IEEE802.11g b compatible wireless CompactFlash Card. Transfer rate upto 54Mbps.","Author":"Ambicom","BibRecObj":"572227.9532","KlasID":"ACC-W01","Medcode":"ACC","ReplaceCost":"89","Titl":"Compact Flash wireless Wi-Fi Card for DBC unit","ManPartNum":"08-WL54CF","URL":"http://www.ambicom.com/index.php?option=com_content&view=article&id=71&Itemid=146","ImageURL":"https://pndb.klas.com/www/images/ACC-W01.jfif","ImageFileName":"ACC-W01.jfif"},{"Annotations":"40 cell Braille display with Braille keyboard and HumanWares signature thumb keys for navigation. Connects via USB or Bluetooth.","Author":"HumanWare","BibRecObj":"572502.9532","KlasID":"BRD-W40","Medcode":"BRLD","ReplaceCost":"2995","Titl":"Brailliant BI 40","ManPartNum":"06-BI40NA","URL":"http://www.humanware.com/en-usa/products/blindness/braille_displays/_details/id_230/brailliant_bi_40_new_generation.html","ImageURL":"https://pndb.klas.com/www/images/BRD-W40.jpg","ImageFileName":"BRD-W40.jpg"},{"Annotations":"Screen magnifier, natural sounding speech and full screen reader with robust refreshable Braille synchronised or used separately. Launch SuperNova Access Suite and people who are blind or partially sighted can create beautifully formatted documents, connect with friends via social networks, or plan that next trip.","Author":"Dolphin","BibRecObj":"574413.9532","KlasID":"SW-D011","Medcode":"SW","ReplaceCost":"1195","Titl":"SuperNova Magnifier & Screen Reader","ManPartNum":"SuperNova Suite","URL":"http://www.yourdolphin.com/productdetail.asp?id=1","ImageURL":"https://pndb.klas.com/www/images/SW-D011.jpg","ImageFileName":"SW-D011.jpg"},{"Annotations":"Dolphin Software Maintenance Agreements (SMAs) Receive the next 2 major upgrades for free, and first! Unlimited minor updates also included. Half the price of buying the same 2 upgrades, and no unexpected costs. Priority Product Support, exclusive to SMA owners","BibRecObj":"574767.9532","KlasID":"SM-D011","Medcode":"SMA","ReplaceCost":"239","Titl":"Dolphin SuperNova Magnifer & Screen Reader SMA","ManPartNum":"None","URL":"http://www.yourdolphin.com/productdetail.asp?id=1&z=9&curr=USD"},{"Annotations":"Upgrade an older version of ZoomText to the current version. Will need the old serial number to get pricing.","Author":"AiSquared","BibRecObj":"575097.9532","KlasID":"SU-A021","Medcode":"SMA","ReplaceCost":"0","Titl":"Upgrade an older version of ZoomText to the current version. Will need the old serial number to get pricing.","ManPartNum":"None","URL":"http://www.aisquared.com/zoomtext/more/upgrade/","ImageURL":"https://pndb.klas.com/www/images/SU-A021.jpg","ImageFileName":"SU-A021.jpg"},{"Annotations":"Designed for anyone who struggles to see the lettering on their keyboard, the new ZoomText Large-Print Keyboard makes typing faster and easier than ever before. Each key and button label is easy to see, even in low light, thanks to its 36-point text and choice of high-contrast color schemes: Black on Yellow or White on Black. The ZoomText Large-Print Keyboard also provides quick access to ZoomText (9.04 and later) features. Eighteen dedicated buttons allow you to instantly start ZoomText, change magnification levels, toggle screen enhancements, launch AppReader and DocReader, and more, all without having to memorize hotkeys.","Author":"FREEDOM SCI","BibRecObj":"575390.9532","KlasID":"ACC-K01","Medcode":"ACC","ReplaceCost":"129","Titl":"ZoomText Large-Print Keyboard -U.S. English -Black Print on Yellow","ManPartNum":"900669-007","URL":"https://store.aisquared.com/products/zoomtext-large-print-keyboard-for-pc-black-on-yellow","ImageURL":"https://pndb.klas.com/www/images/New-KB-BOY.jpg","ImageFileName":"New-KB-BOY.jpg"},{"Annotations":"Designed for anyone who struggles to see the lettering on their keyboard, the new ZoomText Large-Print Keyboard makes typing faster and easier than ever before. Each key and button label is easy to see, even in low light, thanks to its 36-point text and choice of high-contrast color schemes: Black on Yellow or White on Black. The ZoomText Large-Print Keyboard also provides quick access to ZoomText (9.04 and later) features. Eighteen dedicated buttons allow you to instantly start ZoomText, change magnification levels, toggle screen enhancements, launch AppReader and DocReader, and more, all without having to memorize hotkeys.","Author":"FREEDOM SCI","BibRecObj":"575484.9532","KlasID":"ACC-K02","Medcode":"ACC","ReplaceCost":"129","Titl":"ZoomText Large-Print Keyboard -U.S. English- White Print on Black","ManPartNum":"900668-007","URL":"https://store.aisquared.com/products/zoomtext-large-print-keyboard-for-pc-white-on-black","ImageURL":"https://pndb.klas.com/www/images/Zoomtext.png","ImageFileName":"Zoomtext.png"},{"Annotations":"A Freedom Scientific Software Maintenance Agreement (SMA) is the most economical way to keep current with the latest versions of Freedom Scientific software. SMA holders receive two consecutive upgrades on CD-ROM at up to 50 percent off the regular upgrade price.","BibRecObj":"575911.9532","KlasID":"SM-F021","Medcode":"SMA","ReplaceCost":"75","Titl":"Magic SMA Bought With Purchase","ManPartNum":"SMNT","URL":"http://www.freedomscientific.com/support/support-pma.asp","ImageURL":"https://pndb.klas.com/www/images/"},{"Annotations":"A Freedom Scientific Software Maintenance Agreement (SMA) is the most economical way to keep current with the latest versions of Freedom Scientific software. SMA holders receive two consecutive upgrades on CD-ROM at up to 50 percent off the regular upgrade price. Additionally, they can download the upgrade directly from our Web site. Additional cost applied when an SMA is bought after the original software purchase.","BibRecObj":"575997.9532","KlasID":"SM-F025","Medcode":"SMA","ReplaceCost":"100","Titl":"Magic with Speech SMA Bought with Purchase","ManPartNum":"SM","URL":"http://www.freedomscientific.com/support/support-pma.asp"}]}}';
            String responseStr = NC_NDBEDPEquipmentCatalog.getEquipmentCatalog();
            if(String.isNotBlank(responseStr)) {
             	response = (NC_ConnectEquipmentWrapper.EquipmentResponse)JSON.deserialize(responseStr, NC_ConnectEquipmentWrapper.EquipmentResponse.class);   
            } else {
                AuraHandledException e = new AuraHandledException(errorMsg);
                e.setMessage(errorMsg);
                throw e;
            }

            //Filter active categories
            if(response != null && response.eqp != null && response.eqp.ttEqp != null) {
             	for(NC_ConnectEquipmentWrapper.TtEqp equipment: response.eqp.ttEqp) {
                    if(String.isNotBlank(equipment.OPACSup) && equipment.OPACSup.toLowerCase() == 'false'){
                        ttEqpList.add(equipment);
                    }
                }
            	response.eqp.ttEqp = ttEqpList;   
            } else {
                AuraHandledException e = new AuraHandledException(response.ERROR_DESCRIPTION);
                e.setMessage(response.ERROR_DESCRIPTION);
                throw e;
            }
            if(response.STATUS != '200') {
                AuraHandledException e = new AuraHandledException(response.ERROR_DESCRIPTION);
                e.setMessage(response.ERROR_DESCRIPTION);
                throw e;
            }
        } catch (Exception ex) {
            AuraHandledException e = new AuraHandledException(ex.getMessage());
            e.setMessage(ex.getMessage());
            throw e;
        }
        return response;
    }

    /*
    *********************************************************
    @Method Name    : createEquipmentAndEquipmentRequest
    @description    : Create new Request Equipments and create/update NDBEDP equipments
    @param          : String equipmentDetails, String requestId
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static String createEquipmentAndEquipmentRequest(String equipmentDetails, String requestId){
        List<NC_ConnectEquipmentWrapper.TtEqp> equipmentData;
        Map<String, NC_ConnectEquipmentWrapper.TtEqp> equipmentCategoriesMap = new Map<String, NC_ConnectEquipmentWrapper.TtEqp>();
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        Id ndbedpDemoRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Demo');
        String equipmentType = 'NDBEDP';
        try {

            List<Case> caseList = [SELECT AccountId, recordTypeId FROM Case WHERE Id =: requestId WITH SECURITY_ENFORCED];
            
            if (!caseList.isEmpty() && caseList[0].recordTypeId == ndbedpDemoRecordTypeId) {
                equipmentType = 'Demo';
            }

            equipmentData = (List<NC_ConnectEquipmentWrapper.TtEqp>)JSON.deserialize(equipmentDetails, List<NC_ConnectEquipmentWrapper.TtEqp>.class);
            for(NC_ConnectEquipmentWrapper.TtEqp eqp: equipmentData) {
                equipmentCategoriesMap.put(eqp.KlasID, eqp);
            }

            Map<String, Equipment__c> klasEqpMap = new Map<String, Equipment__c>();
            for(Equipment__c eqp: [SELECT KlasID__c, Equipment_Type__c, Description__c, Author__c, BibRecObj__c, Equipment_Category__c, Amount_Authorized__c, Equipment_Name__c, ManPartNum__c, URL__c, ImageURL__c FROM Equipment__c WHERE KlasID__c IN: equipmentCategoriesMap.keySet() AND Equipment_Type__c =: equipmentType WITH SECURITY_ENFORCED]) {
                klasEqpMap.put(eqp.KlasID__c, eqp);
            }

            Map<String, String> equipmentIdMap = new Map<String,String>();
            Set<String> createEquipments = new Set<String>();
            for(String eqpCategory: equipmentCategoriesMap.keySet()) {
                if(klasEqpMap.containsKey(eqpCategory) && klasEqpMap.get(eqpCategory).Equipment_Type__c == equipmentType) {
                    Equipment__c currentEquipment = klasEqpMap.get(eqpCategory);
                    NC_ConnectEquipmentWrapper.TtEqp latestEquipment = equipmentCategoriesMap.get(eqpCategory);
                    if(currentEquipment.Description__c != latestEquipment.Annotations || currentEquipment.Author__c != latestEquipment.Author 
                        || currentEquipment.BibRecObj__c != latestEquipment.BibRecObj || currentEquipment.Equipment_Category__c != latestEquipment.Medcode 
                        || currentEquipment.Amount_Authorized__c != Decimal.valueOf(latestEquipment.ReplaceCost) || currentEquipment.Equipment_Name__c != latestEquipment.Titl
                        || currentEquipment.ManPartNum__c != latestEquipment.ManPartNum || currentEquipment.URL__c != latestEquipment.URL 
                        || currentEquipment.ImageURL__c != latestEquipment.ImageURL) {
                        createEquipments.add(eqpCategory);
                        equipmentIdMap.put(eqpCategory, currentEquipment.id);
                    }
                } else {
                    createEquipments.add(eqpCategory);
                }
            }

            Id ndbedpEqpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Equipment__c','NDBEDP');

            List<Equipment__c> newEquipments = new List<Equipment__c>();
            for(String eqpCategory: createEquipments) {
                if(equipmentCategoriesMap.containsKey(eqpCategory)) {
                    Equipment__c eqp = new Equipment__c();
                    if(equipmentIdMap.containsKey(eqpCategory)) {
                        eqp.id = equipmentIdMap.get(eqpCategory);
                    }
                    eqp.recordTypeId = ndbedpEqpRecordTypeId;
                    eqp.KlasID__c = equipmentCategoriesMap.get(eqpCategory).KlasID;
                    eqp.BibRecObj__c = equipmentCategoriesMap.get(eqpCategory).BibRecObj;
                    eqp.Equipment_Category__c = equipmentCategoriesMap.get(eqpCategory).Medcode;
                    eqp.IsActive__c = true;
                    eqp.OPACSup__c = String.isNotBlank(equipmentCategoriesMap.get(eqpCategory).OPACSup) ? Boolean.valueOf(equipmentCategoriesMap.get(eqpCategory).OPACSup) : true;
                    eqp.Amount_Authorized__c = Decimal.valueOf(equipmentCategoriesMap.get(eqpCategory).ReplaceCost);
                    eqp.Equipment_Name__c = equipmentCategoriesMap.get(eqpCategory).Titl;
                    eqp.Equipment_Type__c = equipmentType;
                    eqp.Description__c = equipmentCategoriesMap.get(eqpCategory).Annotations;
                    eqp.Author__c = equipmentCategoriesMap.get(eqpCategory).Author;
                    eqp.ManPartNum__c = equipmentCategoriesMap.get(eqpCategory).ManPartNum;
                    eqp.URL__c = equipmentCategoriesMap.get(eqpCategory).URL;
                    eqp.ImageURL__c = equipmentCategoriesMap.get(eqpCategory).ImageURL;
                    newEquipments.add(eqp);
                }
            }

            if(newEquipments.size() > 0) {
                //SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Equipment__c', newEquipments, 'upsert', true, 'NC_ConnectEquipmentController', 'createEquipmentAndEquipmentRequest');
                //upsert decision.getRecords();
                //newEquipments = decision.getRecords();
                upsert newEquipments;
                
                for(Equipment__c eqp: newEquipments) {
                    if(!klasEqpMap.containsKey(eqp.KlasID__c)) {
                        klasEqpMap.put(eqp.KlasID__c, eqp);
                    }
                }
            }

            Id requestEqpNDBEDPId = NC_Utility.RecordTypeUtilityMethod('Request_Equipment__c','NDBEDP');
            List<Request_Equipment__c> reqEquipmentList = new List<Request_Equipment__c>();
            for(NC_ConnectEquipmentWrapper.TtEqp eqp: equipmentData) {
                Request_Equipment__c reqEquipment = new Request_Equipment__c();
                reqEquipment.recordTypeId = requestEqpNDBEDPId;
                reqEquipment.Equipment__c = klasEqpMap.get(eqp.KlasID).id;
                reqEquipment.Request__c = requestId;
                reqEquipment.UnitPrice__c = klasEqpMap.get(eqp.KlasID).Amount_Authorized__c;
                reqEquipment.Quantity__c  = String.isNotBlank(equipmentCategoriesMap.get(eqp.KlasID).quantity) ? equipmentCategoriesMap.get(eqp.KlasID).quantity : null;
                reqEquipmentList.add(reqEquipment);
            }

            if(reqEquipmentList.size() > 0) {
                SObjectAccessDecision decision1 = SecurityLibrary.getAccessibleData('Request_Equipment__c', reqEquipmentList, 'insert', true, 'NC_ConnectEquipmentController', 'createEquipmentAndEquipmentRequest');
                insert decision1.getRecords();
                reqEquipmentList = decision1.getRecords();
            }
        } catch (Exception e) {
			if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                String errorMsg = '';
                Integer numErrors = e.getNumDml();
                for(Integer i=0;i<e.getNumDml();i++) {
                    errorMsg += e.getDmlMessage(i);
                }
                throw new AuraHandledException(errorMsg);
            } else if (e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION ')){
                String errorMsg = 'Something went wrong';
                throw new AuraHandledException(errorMsg);
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return 'SUCCESS';
    }
}