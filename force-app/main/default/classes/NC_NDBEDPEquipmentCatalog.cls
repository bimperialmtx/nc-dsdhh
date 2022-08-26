/**
 * Created by ashishpandey on 08/07/21.
 */

public without sharing class NC_NDBEDPEquipmentCatalog {

    /*
    *********************************************************
    @Method Name    : getEquipmentCatalog
    @description    : get Equipment catalog
    @param          : 
    @return         : String
    ********************************************************
    */
    public Static String getEquipmentCatalog(){
        String api_key = String.valueOf(Label.NDBEDP_Key);
        //String endPoint= 'https://eis.dhstst.nc.gov/ws/rest/klas/catalog/';
        String endPoint = String.valueOf(Label.NDBEDP_Catalog_N3);

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
    @Method Name    : sendEquipmentRequest
    @description    : Construct the Request Wrapper
    @param          : Set<Id> requestEquipmentIds, String caseId
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public Static void sendEquipmentRequest(Set<Id> requestEquipmentIds, String caseId){

        NC_NDBEDPEquipmentCatalog.RequestWrapper requestWrapper = new NC_NDBEDPEquipmentCatalog.RequestWrapper();

        List<NC_NDBEDPEquipmentCatalog.TtMatRequestLine> ttMatRequestLines = new List<NC_NDBEDPEquipmentCatalog.TtMatRequestLine>();
        Integer i=0;
        for(Request_Equipment__c obj :[SELECT Id,Equipment__c,Quantity__c,Request__r.Contact.Name,Request__r.Contact.OtherCountryCode,Request__r.Contact.OtherStateCode,Request__r.Contact.OtherStreet,Request__r.Contact.OtherCity,Request__r.Contact.OtherPostalCode,
                Request__r.Contact.Patron_Id__c,MatRequestLineObj__c,LastActionCode__c,Request__r.Contact.Patron_Obj__c,Request__r.Contact.FirstName,Request__r.Contact.LastName,Request__r.Contact.MiddleName,Request__r.Contact.Library_Id__c,
                Equipment_Amount_Authorized__c,Request__r.Internal_Assessor__r.Patron_Obj__c,Equipment_Justification__c,Request__r.MatReqStatus__c,KLASID__c,BibRecObj__c,
                Request__r.External_Assessor__r.First_Name__c,Request__r.External_Assessor__r.Middle_Name__c,Request__r.External_Assessor__r.Last_Name__c,
                Request__r.External_Assessor_User__r.Street, Request__r.External_Assessor_User__r.City, Request__r.External_Assessor_User__r.StateCode, Request__r.External_Assessor_User__r.CountryCode, Request__r.External_Assessor_User__r.PostalCode,
                Request__r.External_Assessor__r.Patron_ID__c,Request__r.External_Assessor__c,Request__r.MatRequestObj__c,LineStatus__c,Request__r.External_Assessor_User__c,
                Request__r.External_Assessor_User__r.Address_Link_Obj__c,Request__r.External_Assessor_User__r.Patron_Obj__c,Request__r.External_Assessor_User__r.Patron_ID__c,Request__r.External_Assessor_User__r.Name,
                Request__r.External_Assessor__r.BillingStreet,Request__r.External_Assessor__r.BillingStateCode,Request__r.External_Assessor__r.BillingCity,Request__r.External_Assessor__r.BillingCountryCode,Request__r.External_Assessor__r.BillingPostalCode,
                Request__r.Internal_Assessor__c,Request__r.CirPattern__c,Request__r.External_Assessor__r.Patron_Obj__c,Request__r.Internal_Assessor__r.Patron_ID__c,Request__r.Internal_Assessor__r.Name,Request__r.Internal_Assessor__r.Address_Link_Obj__c,Request__r.External_Assessor__r.Address_Link_Obj__c,
                Request__r.Internal_Assessor__r.CountryCode,Request__r.MatReqType__c,Request__r.Internal_Assessor__r.Street,Request__r.Internal_Assessor__r.StateCode,Request__r.Internal_Assessor__r.City,Request__r.Internal_Assessor__r.PostalCode,
                Equipment_Name__c,Equipment_Type__c,Request__c,Sub_Equipment__c,Sub_Equipment_Equipment_Amount__c,Sub_Equipment_Equipment_Name__c,Sub_Equipment_Type__c,Unique_Id__c
                FROM Request_Equipment__c WHERE Id IN:requestEquipmentIds]){//WITH SECURITY_ENFORCED

            i++;
            String externalShipToAddress = '';//NDBEDP request
            String internalShipToAddress = '';//NDBEDP request
            String userTRCShipToAddress = ''; //demo type request

            if (obj.Request__r.MatReqType__c!='Demo') {
                if (obj.Request__r.External_Assessor__c != null && obj.Request__r.External_Assessor__r.BillingStreet != null) {
                    externalShipToAddress = obj.Request__r.External_Assessor__r.BillingStreet +' '+ obj.Request__r.External_Assessor__r.BillingCity +' '+ obj.Request__r.External_Assessor__r.BillingStateCode +' '+ obj.Request__r.External_Assessor__r.BillingCountryCode +' '+ obj.Request__r.External_Assessor__r.BillingPostalCode;
                }else if (obj.Request__r.Internal_Assessor__c!=null && obj.Request__r.Internal_Assessor__r.Street!=null) {
                    internalShipToAddress = obj.Request__r.Internal_Assessor__r.Street +' '+ obj.Request__r.Internal_Assessor__r.City +' '+ obj.Request__r.Internal_Assessor__r.StateCode +' '+ obj.Request__r.Internal_Assessor__r.CountryCode +' '+ obj.Request__r.Internal_Assessor__r.PostalCode;
                }
            }else {
                userTRCShipToAddress = obj.Request__r.External_Assessor_User__r.Street +' '+ obj.Request__r.External_Assessor_User__r.City +' '+ obj.Request__r.External_Assessor_User__r.StateCode +' '+ obj.Request__r.External_Assessor_User__r.CountryCode +' '+ obj.Request__r.External_Assessor_User__r.PostalCode;
            }



            NC_NDBEDPEquipmentCatalog.TtMatRequestLine requestLine = new NC_NDBEDPEquipmentCatalog.TtMatRequestLine();
            if (obj.Request__r.MatReqType__c!='Demo') {
                requestWrapper.Resp1PatronObj= obj.Request__r.Contact.Patron_Obj__c;
                requestWrapper.Resp1PatronID= obj.Request__r.Contact.Patron_Id__c;
                requestWrapper.Resp1PatronName= obj.Request__r.Contact.Name;

                if (String.isNotBlank(externalShipToAddress)) {
                    requestWrapper.ShipToAddress = externalShipToAddress;
                    requestWrapper.ShipAddressLinkObj = obj.Request__r.External_Assessor__r.Address_Link_Obj__c;
                    requestWrapper.Resp2PatronObj=obj.Request__r.External_Assessor__r.Patron_Obj__c;
                    requestWrapper.Resp2PatronID= obj.Request__r.External_Assessor__r.Patron_ID__c;
                    requestWrapper.Resp2PatronName= obj.Request__r.External_Assessor__r.First_Name__c+' '+obj.Request__r.External_Assessor__r.Middle_Name__c+' '+obj.Request__r.External_Assessor__r.Last_Name__c;
                }else {
                    requestWrapper.ShipToAddress = internalShipToAddress;
                    requestWrapper.ShipAddressLinkObj = obj.Request__r.Internal_Assessor__r.Address_Link_Obj__c;
                    requestWrapper.Resp2PatronObj= obj.Request__r.Internal_Assessor__r.Patron_Obj__c;
                    requestWrapper.Resp2PatronID= obj.Request__r.Internal_Assessor__r.Patron_ID__c;
                    requestWrapper.Resp2PatronName= obj.Request__r.Internal_Assessor__r.Name;
                }
            }else {

                requestWrapper.Resp1PatronObj= '678210.953200';
                requestWrapper.Resp1PatronID= 'NC-GREEN37';
                requestWrapper.Resp1PatronName= String.valueOf(Label.Resp1PatronName);

                //****Setting up for Demo request*************
                requestWrapper.ShipToAddress = userTRCShipToAddress;
                requestWrapper.ShipAddressLinkObj = obj.Request__r.External_Assessor_User__r.Address_Link_Obj__c;
                requestWrapper.Resp2PatronObj= obj.Request__r.External_Assessor_User__r.Patron_Obj__c;
                requestWrapper.Resp2PatronID= obj.Request__r.External_Assessor_User__r.Patron_ID__c;
                requestWrapper.Resp2PatronName= obj.Request__r.External_Assessor_User__r.Name;
            }


            requestWrapper.ShipToAddressDesc = 'Home Address';
            requestWrapper.CirPattern=obj.Request__r.CirPattern__c;
            requestWrapper.LibraryID= obj.Request__r.Contact.Library_Id__c;
            requestWrapper.MatReqType=obj.Request__r.MatReqType__c;
            requestWrapper.MatReqStatus= obj.Request__r.MatReqStatus__c;
            requestWrapper.MatRequestObj= obj.Request__r.MatRequestObj__c;

            //****Line Items***************************
            requestLine.BibRecObj= obj.BibRecObj__c;
            requestLine.LineNum= String.valueOf(i);
            requestLine.LineStatus= obj.LineStatus__c;
            requestLine.QtyOrdered= String.valueOf(obj.Quantity__c);
            requestLine.TitleInfo='';
            if(obj.Request__r.MatRequestObj__c==null || obj.MatRequestLineObj__c==null){
                requestLine.LastActionCode='APPROV';
            }else if (obj.LineStatus__c=='Cancelled') {
                requestLine.LastActionCode = 'CAN';
            }else {
                requestLine.LastActionCode = obj.LastActionCode__c;
            }

            requestLine.KLASID= obj.KLASID__c;
            requestLine.Titl= obj.Equipment_Name__c;

            ttMatRequestLines.add(requestLine);

            requestWrapper.ttMatRequestLine = ttMatRequestLines;

        }
        sendRequestToNDBEDP(requestWrapper,requestEquipmentIds, caseId);

    }

    /*
    *********************************************************
    @Method Name    : sendRequestToNDBEDP
    @description    : Send Request to KLAS
    @param          : NC_NDBEDPEquipmentCatalog.RequestWrapper body, Set<Id> requestEquipmentIds, String caseId
    @return         : void
    ********************************************************
    */
    public Static void sendRequestToNDBEDP(NC_NDBEDPEquipmentCatalog.RequestWrapper body, Set<Id> requestEquipmentIds, String caseId){

        Map<String,Request_Equipment__c> lineItemMap = new Map<String, Request_Equipment__c>();
        for(Request_Equipment__c item :[SELECT Id,Request__c,MatRequestLineObj__c,BibRecObj__c,KLASID__c FROM Request_Equipment__c WHERE Id IN :requestEquipmentIds]){//WITH SECURITY_ENFORCED
            lineItemMap.put(item.BibRecObj__c,item);
        }

        String api_key = String.valueOf(Label.NDBEDP_Key);
        //String endPoint= ' https://eis.dhstst.nc.gov/ws/rest/klas/matrequests/';
        String endPoint = String.valueOf(Label.NDBEDP_MatRequest_N4_N5);

        Http h = new Http();
        HttpResponse res;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint);
        httpReq.setBody(JSON.serialize(body));

        try{
            res = h.send(httpReq);
            Case caseObj = new Case();
            List<Request_Equipment__c> lineItemsToUpdate = new List<Request_Equipment__c>();
            ResponseWrapper responseWrapper = (ResponseWrapper)JSON.deserialize(res.getBody(),ResponseWrapper.class);
            if(responseWrapper.STATUS==200){
                if(responseWrapper.matRequests != null){
                    for(ResponseMatRequests req :responseWrapper.matRequests){
                        caseObj.Id= caseId;
                        caseObj.MatReqStatus__c= req.MatReqStatus;
                        caseObj.MatReqStatusDate__c= Date.valueOf(req.MatReqStatusDate);
                        caseObj.MatRequestID__c= req.MatRequestID;
                        caseObj.MatRequestObj__c= req.MatRequestObj;
                        caseObj.MatReqType__c=req.MatReqType;

                        for (Response_ttMatRequestLine reqLine :req.ttMatRequestLine){
                            Request_Equipment__c reqEuip = new Request_Equipment__c();
                            if(lineItemMap.get(reqLine.BibRecObj)!=null || Test.isRunningTest()){
                                reqEuip.Id= lineItemMap.get(reqLine.BibRecObj).Id;
                                reqEuip.MatRequestLineObj__c= reqLine.MatRequestLineObj;
                                reqEuip.LastActionCode__c= reqLine.LastActionCode;
                                reqEuip.ActionCodeDesc__c= reqLine.ActionCodeDesc;
                                reqEuip.LineNum__c= String.valueOf(reqLine.LineNum);
                                reqEuip.LineStatus__c= reqLine.LineStatus;
                                reqEuip.LineStatusDate__c= Date.valueOf(reqLine.LineStatusDate);

                                if (reqLine.LastShipDate!=null) {
                                    reqEuip.LastShipDate__c= Date.valueOf(reqLine.LastShipDate);
                                }
                                reqEuip.MRLineUserRef3__c= reqLine.MRLineUserRef3;
                                reqEuip.QtyShipped__c= reqLine.QtyShipped;
                                reqEuip.Total__c= Decimal.valueOf(reqLine.Total);
                                reqEuip.Shipping__c= Decimal.valueOf(reqLine.Shipping);
                                reqEuip.PublicNote__c= reqLine.PublicNote;

                                lineItemsToUpdate.add(reqEuip);
                            }
                        }
                    }
                    update caseObj;
                    //SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Case', new List<Case>{caseObj}, 'update', true,'NC_NDBEDPEquipmentCatalog','sendRequestToNDBEDP');
                	//update decision.getRecords();
                    if (lineItemsToUpdate.size()>0) {
                        MAP<Id,Request_Equipment__c> reqEqpMap = new MAP<Id,Request_Equipment__c>();
                        reqEqpMap.putall(lineItemsToUpdate);
                        if(reqEqpMap.size()>0){
                            update reqEqpMap.values();
                        }
                        //update lineItemsToUpdate;
                    }
                }
            }else{
                //Insert Error Object records
                NC_CNDSUtility.insertNDBEDPRequestError(endPoint,JSON.serialize(body),res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),caseId);
                update new Case(Id = caseId,Send_to_KLAS__c=false,Allow_NDBEDP_Request_resync__c=true,InActive_Equipments__c=false,In_Active_Equipments_Name__c=null);
                //Case updateCase = new Case(Id = caseId,Send_to_KLAS__c=false,Allow_NDBEDP_Request_resync__c=true,InActive_Equipments__c=false,In_Active_Equipments_Name__c=null);
                //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', new List<Case>{updateCase}, 'update', true,'NC_NDBEDPEquipmentCatalog','sendRequestToNDBEDP');
                //update decision.getRecords();
            }
        }catch (Exception e){
            //Insert Error Object records
            NC_CNDSUtility.insertNDBEDPRequestError(endPoint,JSON.serialize(body),e.getMessage(),e.getMessage(),'503',caseId);
            update new Case(Id = caseId,Send_to_KLAS__c=false,Allow_NDBEDP_Request_resync__c=true,InActive_Equipments__c=false,In_Active_Equipments_Name__c=null);
            //Case updateCase = new Case(Id = caseId,Send_to_KLAS__c=false,Allow_NDBEDP_Request_resync__c=true,InActive_Equipments__c=false,In_Active_Equipments_Name__c=null);
			//SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', new List<Case>{updateCase}, 'update', true,'NC_NDBEDPEquipmentCatalog','sendRequestToNDBEDP');
            //update decision.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : validateEquipment
    @description    : Check if added equipment is still active or not in KLAS//not used now instead used this NC_NDBEDP_ValidateEquipments
    @param          : String requestId
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public Static void validateEquipment(String requestId){
        String equipmentNames;
        List<String> inActiveEquipmentNames= new List<String>();
        Boolean inActive=false;
        NC_ConnectEquipmentWrapper.EquipmentResponse response;
        String responseStr = getEquipmentCatalog();
        response = (NC_ConnectEquipmentWrapper.EquipmentResponse)JSON.deserialize(responseStr, NC_ConnectEquipmentWrapper.EquipmentResponse.class);

        Map<String,Object> catalogEquipmentMap = new Map<String, Object>();
        Map<String,Request_Equipment__c> lineItemMap = new Map<String, Request_Equipment__c>();
        for(Request_Equipment__c item :[SELECT Id,Equipment_Name__c,Request__c,MatRequestLineObj__c,BibRecObj__c,KLASID__c FROM Request_Equipment__c WHERE Request__c =:requestId]){//WITH SECURITY_ENFORCED
            lineItemMap.put(item.BibRecObj__c,item);
        }

        for(NC_ConnectEquipmentWrapper.TtEqp equipment: response.eqp.ttEqp) {
            if(String.isNotBlank(equipment.OPACSup) && equipment.OPACSup.toLowerCase() == 'false'){
                catalogEquipmentMap.put(equipment.BibRecObj,equipment);
            }
        }
        for(Request_Equipment__c eqp:lineItemMap.values()){
            if (!catalogEquipmentMap.containsKey(eqp.BibRecObj__c)) {
                inActiveEquipmentNames.add(eqp.Equipment_Name__c);
                inActive=true;
            }
        }
        if(inActiveEquipmentNames.size()>0){
            equipmentNames = string.join(inActiveEquipmentNames,',');
            update new Case(Id = requestId, In_Active_Equipments_Name__c = equipmentNames,InActive_Equipments__c=inActive,Send_to_KLAS__c=false);
            //Case updateCase = new Case(Id = requestId, In_Active_Equipments_Name__c = equipmentNames,InActive_Equipments__c=inActive,Send_to_KLAS__c=false);
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', new List<Case>{updateCase}, 'update', true,'NC_NDBEDPEquipmentCatalog','validateEquipment');
            //update decision.getRecords();
        }else {
            update new Case(Id = requestId,Send_to_KLAS__c=true,InActive_Equipments__c=false,In_Active_Equipments_Name__c=null);
            //Case updateCase = new Case(Id = requestId,Send_to_KLAS__c=true,InActive_Equipments__c=false,In_Active_Equipments_Name__c=null);
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Case', new List<Case>{updateCase}, 'update', true,'NC_NDBEDPEquipmentCatalog','validateEquipment');
            //update decision.getRecords();
        }

    }

    /*
    *********************************************************
    @Method Name    : getEquipmentRequestStatus
    @description    : get equipment request status
    @param          : String recordId
    @return         : String
    ********************************************************
    */
    public Static String getEquipmentRequestStatus(String recordId){

        List<Case> requestList = new List<Case>();
        requestList = [SELECT MatRequestID__c FROM Case WHERE id =: recordId];
        if(requestList.size() > 0 && String.isNotBlank(requestList[0].MatRequestID__c)) {
            String api_key = String.valueOf(Label.NDBEDP_Key);
            String endPointTemp = String.valueOf(Label.NDBEDP_MatRequest_N4_N5);
            //https://eis.dhstst.nc.gov/ws/rest/klas/matrequests/QA?MatRequestId=' '
            //String endPoint= 'https://eis.dhstst.nc.gov/ws/rest/klas/matrequests/MatRequestId='+requestList[0].MatRequestID__c;
            String endPoint= endPointTemp+'?MatRequestId='+requestList[0].MatRequestID__c;

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
                throw new AuraHandledException('Error: '+e.getMessage());
                        }
            return String.valueOf(res.getBody());
        } else {
            String returnStr = '{"STATUS" : 404, "ERROR_DESCRIPTION" : "MatRequestID not present for the request"}';
            return returnStr;
        }
    }

    public class  RequestWrapper{
        public String ShipAddressLinkObj;
        public String ShipToAddressDesc;
        public String ShipToAddress;
        public String Resp1PatronObj;
        public String Resp1PatronID;
        public String Resp1PatronName;
        public String CirPattern;
        public String LibraryID;
        public String MatReqType;
        public String MatReqStatus;
        public String MatRequestObj;
        public String Resp2PatronObj;
        public String Resp2PatronID;
        public String Resp2PatronName;
        public List<TtMatRequestLine> ttMatRequestLine;
    }
    public class TtMatRequestLine {
        public String BibRecObj;
        public String LastActionCode;
        public String MatRequestLineObj;
        public String LineNum;
        public String LineStatus;
        public String QtyOrdered;
        public String TitleInfo;
        public String KLASID;
        public String Titl;
        public String UnitPrice;
    }

    //Response Wrapper**********
    public class ResponseWrapper{
        public Integer STATUS;
        public String ERROR_DESCRIPTION;
        public List<ResponseMatRequests> matRequests;
    }
    public class ResponseMatRequests {
        public String MatReqStatus;
        public String MatReqType;
        public String MatReqStatusDate;
        public String MatRequestID;
        public String MatRequestObj;
        public List<Response_ttMatRequestLine> ttMatRequestLine;
    }
    public class Response_ttMatRequestLine {
        public String MatRequestLineObj;
        public String LastActionCode;
        public String ActionCodeDesc;
        public Integer LineNum;
        public String LineStatus;
        public String LineStatusDate;
        public String BibRecObj;
        //new Fields
        public String PublicNote;
        public String Shipping;
        public String Total;
        public String QtyOrdered;
        public String QtyShipped;
        public String MRLineUserRef3;
        public String LastShipDate;
        public String UnitPrice;
        public String TitleInfo;
        public String MedCodeDesc;
        public String Titl;
        public String KLASID;
        public String ManPartNum;
        public String Medcode;
        public String LastActionDate;
    }
    public class MatRequestStatusResponse {
        public Integer STATUS;
        public String ERROR_DESCRIPTION;
        public Integer count;
        public Boolean hasMoreResults;
        public List<MatRequests> matRequests;
    }

    public class MatRequestStatus_TtMatRequestLine {
        public String BibRecObj;
        public String LastActionCode;
        public String ActionCodeDesc;
        public String LineNum;
        public String LineStatus;
        public String LineStatusDate;
        public String MatRequestLineObj;
        public String QtyOrdered;
    }

    public class MatRequests {
        public String MatReqStatus;
        public String MatReqStatusDate;
        public String MatReqType;
        public String MatRequestID;
        public String MatRequestObj;
        public List<MatRequestStatus_TtMatRequestLine> ttMatRequestLine;
    }

}