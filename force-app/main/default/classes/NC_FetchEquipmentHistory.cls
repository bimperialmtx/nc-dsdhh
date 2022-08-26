/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_FetchEquipmentHistory {

    /*
    *********************************************************
    @Method Name    : getEquipmentHistory
    @description    : Fetch Equipment history from KLAS
    @param          : String patronId
    @return         : String
    ********************************************************
    */
    public static String getEquipmentHistory(String patronId) {
        String api_key = String.valueOf(Label.NDBEDP_Key);
        //String endPoint= 'https://eis.dhstst.nc.gov/ws/rest/klas/migration/QA/?PatronId=' + patronId;
        String endPoint = String.valueOf(Label.NDBEDP_Fetch_Equipment_History).replace('{PatronId}', patronId);

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
        }
        return String.valueOf(res.getBody());
    }

    /*
    *********************************************************
    @Method Name    : fetchEquipmentHistoryFuture
    @description    : Fetch Equipment history from KLAS future
    @param          : String contactId
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public static void fetchEquipmentHistoryFuture(String contactId) {
        fetchEquipmentHistory(contactId);
    }

    /*
    *********************************************************
    @Method Name    : fetchEquipmentHistory
    @description    : insert Case and Request equipment after fetching history
    @param          : String contactId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> fetchEquipmentHistory(String contactId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String response;
        List<Contact> contactList = new List<Contact>();
        try{
            if(String.isNotBlank(contactId)) {
                contactList = [SELECT Patron_ID__c FROM Contact WHERE Id =: contactId WITH SECURITY_ENFORCED];
            } else {
                returnMap.put('Error', 'Contact Id cannot be blank');
            }
    
            if(contactList.size() > 0 && String.isNotBlank(contactList[0].Patron_ID__c)) {
                response = getEquipmentHistory(contactList[0].Patron_ID__c);
                //response = '{"STATUS":200,"ERROR_DESCRIPTION":"ACTIONCOMPLETEDSUCCESSFULLY","matRequests":[{"MatReqStatus":"Closed","MatReqStatusDate":"2021-09-09","MatReqType":"Eqp","MatRequestID":"210909-001","MatRequestObj":"54645937.9532","ttMatRequestLine":[{"BibRecObj":"575390.9532","LastActionCode":"CAN","ActionCodeDesc":"Cancelled","LineNum":"1","LineStatus":"Closed","LineStatusDate":"2021-09-09","MatRequestLineObj":"54645944.9532","QtyOrdered":"1","QtyShipped":"0","Shipping":"0","Total":"0"},{"BibRecObj":"577570.9532","LastActionCode":"CAN","ActionCodeDesc":"Cancelled","LineNum":"2","LineStatus":"Closed","LineStatusDate":"2021-09-09","MatRequestLineObj":"54645946.9532","QtyOrdered":"1","QtyShipped":"0","Shipping":"0","Total":"0"}]}]}';
            } else {
                returnMap.put('Error', 'Contact Patron Id is blank');
                return returnMap;
            }
            if(String.isNotBlank(response)) {
                Map<String, String> reqEqpCaseMap = new Map<String, String>();
                List<Case> caseToInsert = new List<Case>();
                Map<String, Request_Equipment__c> reqEqpMap = new Map<String, Request_Equipment__c>();
                Map<String, NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine> reqEqpKLASMap = new Map<String, NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine>();
                NC_NDBEDPEquipmentCatalog.ResponseWrapper responseWrapper = (NC_NDBEDPEquipmentCatalog.ResponseWrapper)JSON.deserialize(response,NC_NDBEDPEquipmentCatalog.ResponseWrapper.class);
                if(responseWrapper.STATUS==200){
                    if(!responseWrapper.matRequests.isEmpty()){
                        for(NC_NDBEDPEquipmentCatalog.ResponseMatRequests req :responseWrapper.matRequests){
                            Case caseObj = new Case();
                            caseObj.recordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
                            caseObj.ContactId = contactId;
                            caseObj.Status = 'Approved';
                            caseObj.Equipment_Types__c = 'NDBEDP';
                            caseObj.Fetched_as_Equipment_History_from_KLAS__c = true;
                            caseObj.MatReqStatus__c= req.MatReqStatus;
                            caseObj.MatReqStatusDate__c= Date.valueOf(req.MatReqStatusDate);
                            caseObj.MatRequestID__c= req.MatRequestID;
                            caseObj.MatRequestObj__c= req.MatRequestObj;
                            caseObj.MatReqType__c=req.MatReqType;
                            caseToInsert.add(caseObj);
    
                            for (NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine reqLine :req.ttMatRequestLine){
                                Request_Equipment__c reqEuip = new Request_Equipment__c();
                                reqEuip.recordTypeId = SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
                                reqEuip.BibRecObj_Text__c = reqLine.BibRecObj;
                                reqEuip.LastActionCode__c= reqLine.LastActionCode;
                                reqEuip.ActionCodeDesc__c= reqLine.ActionCodeDesc;
                                reqEuip.LineNum__c= String.valueOf(reqLine.LineNum);
                                reqEuip.LineStatus__c= reqLine.LineStatus;
                                reqEuip.LineStatusDate__c= Date.valueOf(reqLine.LineStatusDate);
                                reqEuip.MatRequestLineObj__c= reqLine.MatRequestLineObj;
                                reqEuip.QtyOrdered__c = reqLine.QtyOrdered;
                                reqEuip.QtyShipped__c= reqLine.QtyShipped;
                                reqEuip.Shipping__c= Decimal.valueOf(reqLine.Shipping);
                                reqEuip.Total__c= Decimal.valueOf(reqLine.Total);
                                reqEuip.UnitPrice__c= Decimal.valueOf(reqLine.UnitPrice);
                                if (reqLine.LastShipDate!=null) {
                                    reqEuip.LastShipDate__c= Date.valueOf(reqLine.LastShipDate);
                                }
                                if (reqLine.LastActionDate!=null) {
                                    reqEuip.LastActionDate__c= Date.valueOf(reqLine.LastActionDate);
                                }
                                reqEuip.MRLineUserRef3__c= reqLine.MRLineUserRef3;
                                reqEuip.MedCodeDesc__c= reqLine.MedCodeDesc;
                                reqEuip.TitleInfo__c= reqLine.TitleInfo;
                                reqEuip.PublicNote__c= reqLine.PublicNote;
                                
                                reqEqpCaseMap.put(reqEuip.BibRecObj_Text__c, caseObj.MatRequestID__c);
                                reqEqpMap.put(reqEuip.BibRecObj_Text__c, reqEuip);
                                reqEqpKLASMap.put(reqLine.BibRecObj, reqLine);
                            }
                        }
                        if(reqEqpMap.size() > 0) {
                            createEquipmentRequest(reqEqpMap, reqEqpKLASMap, reqEqpCaseMap, caseToInsert);
                            updateContact(contactId);
                            returnMap.put('Success', 'Equipment history details has been fetched successfully');
                        }
                    } else {
                        returnMap.put('Success', responseWrapper.ERROR_DESCRIPTION);
                    }
                } else {
                    if(String.isNotBlank(responseWrapper.ERROR_DESCRIPTION)) {
                        returnMap.put('Error', responseWrapper.ERROR_DESCRIPTION);
                    } else {
                        returnMap.put('Error', 'No response returned from KLAS due to some problem. Please try again later');
                    }
                }
            } else {
                returnMap.put('Error', 'No response returned from KLAS due to some problem. Please try again later');
            }
        } catch(Exception e) {
            returnMap.put('Error', e.getMessage());
            removeRequests(contactId);
        }
        return returnMap;
    }
    
    /*
    *********************************************************
    @Method Name    : removeRequests
    @description    : delete case in case of any failure
    @param          : String contactId
    @return         : void
    ********************************************************
    */
    public static void removeRequests(String contactID) {
        List<Case> requestList = [SELECT id FROM Case WHERE ContactId =: contactID];
        if(!requestList.isEmpty()) {
            delete requestList;
        }
    }

    /*
    *********************************************************
    @Method Name    : createEquipmentRequest
    @description    : Create or update existing equipments
    @param          : Map<String, Request_Equipment__c> reqEqpMap, Map<String, NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine> reqEqpKLASMap, Map<String, String> reqEqpCaseMap, List<Case> caseToInsert
    @return         : void
    ********************************************************
    */
    public static void createEquipmentRequest(Map<String, Request_Equipment__c> reqEqpMap, Map<String, NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine> reqEqpKLASMap, Map<String, String> reqEqpCaseMap, List<Case> caseToInsert) {
        List<Request_Equipment__c> lineItemsToInsert = new List<Request_Equipment__c>();
        Map<String, NC_ConnectEquipmentWrapper.TtEqp> bibRecObjKLASMap = new Map<String, NC_ConnectEquipmentWrapper.TtEqp>();
        Map<String, Equipment__c> bibRecObjSFMap = new Map<String, Equipment__c>();
        List<Equipment__c> upsertEquipments = new List<Equipment__c>();
        Boolean invokeN3KLAS = false;
        String equipmentType = 'NDBEDP';
        Id ndbedpEqpRecordTypeId = SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();

        for(Equipment__c eqp: [SELECT KlasID__c, Equipment_Type__c, Description__c, Author__c, BibRecObj__c, Equipment_Category__c, Amount_Authorized__c, Equipment_Name__c, ManPartNum__c, URL__c, ImageURL__c FROM Equipment__c WHERE BibRecObj__c IN: reqEqpMap.keySet() AND Equipment_Type__c =: equipmentType WITH SECURITY_ENFORCED]) {
            bibRecObjSFMap.put(eqp.BibRecObj__c, eqp);
            if(reqEqpKLASMap.containsKey(eqp.BibRecObj__c)) {
                eqp.Amount_Authorized__c = Decimal.valueOf(reqEqpKLASMap.get(eqp.BibRecObj__c).UnitPrice);
                eqp.Equipment_Name__c = reqEqpKLASMap.get(eqp.BibRecObj__c).Titl;
                eqp.KlasID__c = reqEqpKLASMap.get(eqp.BibRecObj__c).KLASID;
                eqp.ManPartNum__c = reqEqpKLASMap.get(eqp.BibRecObj__c).ManPartNum;
                eqp.Equipment_Category__c = reqEqpKLASMap.get(eqp.BibRecObj__c).Medcode;
                upsertEquipments.add(eqp);
            }
        }

        for(String bibRecObj: reqEqpMap.keySet()) {
            if(!bibRecObjSFMap.containsKey(bibRecObj)) {
                invokeN3KLAS = true;
                break;
            }
        }
        
        if(invokeN3KLAS) {
            NC_ConnectEquipmentWrapper.EquipmentResponse response = NC_ConnectEquipmentController.retrieveEquipments();
            if(response != null && response.eqp != null && !response.eqp.ttEqp.isEmpty())
            for(NC_ConnectEquipmentWrapper.TtEqp eqp: response.eqp.ttEqp) {
                if(reqEqpMap.containsKey(eqp.BibRecObj)) {
                    bibRecObjKLASMap.put(eqp.BibRecObj, eqp);
                }
            }
        }
        
        Map<String, String> equipmentIdMap = new Map<String,String>();
        Set<String> createEquipments = new Set<String>();
        for(String bibRecObj: bibRecObjKLASMap.keySet()) {
            if(bibRecObjSFMap.containsKey(bibRecObj) && bibRecObjSFMap.get(bibRecObj).Equipment_Type__c == equipmentType) {
                equipmentIdMap.put(bibRecObj, bibRecObjSFMap.get(bibRecObj).id);
            } else {
                createEquipments.add(bibRecObj);
            }
        }

        for(String bibRecObj: createEquipments) {
            if(bibRecObjKLASMap.containsKey(bibRecObj)) {
                Equipment__c eqp = new Equipment__c();
                eqp.recordTypeId = ndbedpEqpRecordTypeId;
                eqp.KlasID__c = bibRecObjKLASMap.get(bibRecObj).KlasID;
                eqp.BibRecObj__c = bibRecObjKLASMap.get(bibRecObj).BibRecObj;
                eqp.Equipment_Category__c = bibRecObjKLASMap.get(bibRecObj).Medcode;
                eqp.IsActive__c = true;
                eqp.OPACSup__c = String.isNotBlank(bibRecObjKLASMap.get(bibRecObj).OPACSup) ? Boolean.valueOf(bibRecObjKLASMap.get(bibRecObj).OPACSup) : true;
                eqp.Amount_Authorized__c = Decimal.valueOf(bibRecObjKLASMap.get(bibRecObj).ReplaceCost);
                eqp.Equipment_Name__c = bibRecObjKLASMap.get(bibRecObj).Titl;
                eqp.Equipment_Type__c = equipmentType;
                eqp.Description__c = bibRecObjKLASMap.get(bibRecObj).Annotations;
                eqp.Author__c = bibRecObjKLASMap.get(bibRecObj).Author;
                eqp.ManPartNum__c = bibRecObjKLASMap.get(bibRecObj).ManPartNum;
                eqp.URL__c = bibRecObjKLASMap.get(bibRecObj).URL;
                eqp.ImageURL__c = bibRecObjKLASMap.get(bibRecObj).ImageURL;
                upsertEquipments.add(eqp);
            }
        }

        if(upsertEquipments.size() > 0) {
            SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Equipment__c', upsertEquipments, 'upsert', true, 'NC_ConnectEquipmentController', 'createEquipmentAndEquipmentRequest');
            upsert decision.getRecords();
            upsertEquipments = decision.getRecords();
            
            for(Equipment__c eqp: upsertEquipments) {
                if(!bibRecObjSFMap.containsKey(eqp.BibRecObj__c)) {
                    bibRecObjSFMap.put(eqp.BibRecObj__c, eqp);
                }
            }
        }

        for(Request_Equipment__c reqEqp: reqEqpMap.values()) {
            if(bibRecObjSFMap.containsKey(reqEqp.BibRecObj_Text__c)) {
                reqEqp.Equipment__c = bibRecObjSFMap.get(reqEqp.BibRecObj_Text__c).id;
                lineItemsToInsert.add(reqEqp);
            }
        }

        if(caseToInsert.size() > 0) {
           // insert caseToInsert;
           SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', caseToInsert, 'insert', true,'NC_FetchEquipmentHistory','createEquipmentRequest');
           insert decision.getRecords();
           caseToInsert = decision.getRecords();

            Map<String, String> caseIdMap = new Map<String, String>();
            for(Case caseObj: caseToInsert) {
                caseIdMap.put(caseObj.MatRequestID__c, caseObj.id);
            }

            for(Request_Equipment__c reqEqp: lineItemsToInsert) {
                if(reqEqpCaseMap.containsKey(reqEqp.BibRecObj_Text__c) && caseIdMap.containsKey(reqEqpCaseMap.get(reqEqp.BibRecObj_Text__c))) {
                    reqEqp.Request__c = caseIdMap.get(reqEqpCaseMap.get(reqEqp.BibRecObj_Text__c));//caseIdMap.get(reqEqp.BibRecObj_Text__c);
                }
            }
        }

        if(lineItemsToInsert.size() > 0) {
            //insert lineItemsToInsert;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Contact', lineItemsToInsert, 'insert', true,'NC_FetchEquipmentHistory','createEquipmentRequest');
            insert decision.getRecords();
            lineItemsToInsert = decision.getRecords();
        }
       
    }

    /*
    *********************************************************
    @Method Name    : updateContact
    @description    : update contact data
    @param          : String contactId
    @return         : void
    ********************************************************
    */
    public static void updateContact(String contactId) {
        Contact contactObj = new Contact();
        contactObj.id = contactId;
        contactObj.Equipment_History_Retrieved__c = true;
       // update contactObj;
       SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Contact', new List<Contact>{contactObj}, 'update', true,'NC_FetchEquipmentHistory','updateContact');
       update decision.getRecords();
    }
}