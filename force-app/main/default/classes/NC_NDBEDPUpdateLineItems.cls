/**
 * Created by ashishpandey on 14/07/21.
 * Send updated line items to KLAS
 */

public  class NC_NDBEDPUpdateLineItems implements Queueable,Database.AllowsCallouts {
    public Set<Id> requestEquipmentIds;
    public String caseId;
    public NC_NDBEDPUpdateLineItems(Set<Id> equipmentIds){
        requestEquipmentIds = equipmentIds ;

    }
    public void execute(QueueableContext qc){

        NC_NDBEDPEquipmentCatalog.RequestWrapper requestWrapper = new NC_NDBEDPEquipmentCatalog.RequestWrapper();
        List<NC_NDBEDPEquipmentCatalog.TtMatRequestLine> ttMatRequestLines = new List<NC_NDBEDPEquipmentCatalog.TtMatRequestLine>();

        Map<String,String> matObjVsCaseId = new Map<String,String>();

        for(Request_Equipment__c obj :[SELECT Id,UnitPrice__c,LineStatus__c,Equipment__c,LineNum__c,Quantity__c,Request__r.Contact.Name,Request__r.Contact.OtherCountryCode,Request__r.Contact.OtherStateCode,Request__r.Contact.OtherStreet,Request__r.Contact.OtherCity,Request__r.Contact.OtherPostalCode,
            Request__r.Contact.Patron_Id__c,Request__r.MatReqType__c,Request__r.Contact.FirstName,Request__r.Contact.LastName,Request__r.Contact.MiddleName,Request__r.Contact.Library_Id__c,
            Equipment_Amount_Authorized__c,Equipment_Justification__c,Request__r.MatReqStatus__c,KLASID__c,BibRecObj__c,LastActionCode__c,
            Request__r.External_Assessor__r.First_Name__c,Request__r.External_Assessor__r.Middle_Name__c,Request__r.External_Assessor__r.Last_Name__c,
            Request__r.External_Assessor__r.Patron_ID__c,Request__r.External_Assessor__c,Request__r.MatRequestObj__c,MatRequestLineObj__c,
            Request__r.External_Assessor_User__r.Address_Link_Obj__c,Request__r.External_Assessor_User__r.Patron_Obj__c,Request__r.External_Assessor_User__r.Patron_ID__c,Request__r.External_Assessor_User__r.Name,
            Request__r.External_Assessor__r.BillingStreet,Request__r.External_Assessor__r.BillingStateCode,Request__r.External_Assessor__r.BillingCity,Request__r.External_Assessor__r.BillingCountryCode,Request__r.External_Assessor__r.BillingPostalCode,
            Request__r.Internal_Assessor__c,Request__r.Internal_Assessor__r.Address_Link_Obj__c,Request__r.External_Assessor__r.Address_Link_Obj__c,
            Request__r.Internal_Assessor__r.CountryCode,Request__r.Internal_Assessor__r.Street,Request__r.Internal_Assessor__r.StateCode,Request__r.Internal_Assessor__r.City,Request__r.Internal_Assessor__r.PostalCode,
            Equipment_Name__c,Equipment_Type__c,Request__c,Sub_Equipment__c,Sub_Equipment_Equipment_Amount__c,Sub_Equipment_Equipment_Name__c,Sub_Equipment_Type__c,Unique_Id__c, Request__r.Contact.Patron_Obj__c, 
            Request__r.External_Assessor__r.Patron_Obj__c, Request__r.Internal_Assessor__r.Patron_Obj__c, Request__r.CirPattern__c, Request__r.Internal_Assessor__r.Patron_ID__c, Request__r.Internal_Assessor__r.Name
            FROM Request_Equipment__c WHERE Id IN:requestEquipmentIds]) {

            String externalShipToAddress = '';
            String internalShipToAddress = '';
            String userTRCShipToAddress = ''; //demo type request
            caseId=obj.Request__c;
            matObjVsCaseId.put(obj.Request__r.MatRequestObj__c,obj.Request__c);

            if (obj.Request__r.MatReqType__c!='Demo') {
                if (obj.Request__r.External_Assessor__c != null && obj.Request__r.External_Assessor__r.BillingStreet != null) {
                    externalShipToAddress = obj.Request__r.External_Assessor__r.BillingStreet +' '+ obj.Request__r.External_Assessor__r.BillingCity +' '+ obj.Request__r.External_Assessor__r.BillingStateCode +' '+ obj.Request__r.External_Assessor__r.BillingCountryCode +' '+ obj.Request__r.External_Assessor__r.BillingPostalCode;
                }else if (obj.Request__r.Internal_Assessor__c!=null && obj.Request__r.Internal_Assessor__r.Street!=null) {
                    internalShipToAddress = obj.Request__r.Internal_Assessor__r.Street +' '+ obj.Request__r.Internal_Assessor__r.City +' '+ obj.Request__r.Internal_Assessor__r.StateCode +' '+ obj.Request__r.Internal_Assessor__r.CountryCode +' '+ obj.Request__r.Internal_Assessor__r.PostalCode;
                }
            }else {
                userTRCShipToAddress = obj.Request__r.External_Assessor_User__r.Street +' '+ obj.Request__r.External_Assessor_User__r.City +' '+ obj.Request__r.External_Assessor_User__r.StateCode +' '+ obj.Request__r.External_Assessor_User__r.CountryCode +' '+ obj.Request__r.External_Assessor_User__r.PostalCode;
            }


            //********************Construct the Request******************
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
                requestWrapper.Resp1PatronObj= obj.Request__r.External_Assessor_User__r.Patron_Obj__c;
                requestWrapper.Resp1PatronID= obj.Request__r.External_Assessor_User__r.Patron_ID__c;
                requestWrapper.Resp1PatronName= obj.Request__r.External_Assessor_User__r.Name;
            }


            requestWrapper.ShipToAddressDesc = 'Home Address';

            requestWrapper.ShipToAddressDesc = 'Home Address';
            requestWrapper.CirPattern=obj.Request__r.CirPattern__c;
            requestWrapper.LibraryID= obj.Request__r.Contact.Library_Id__c;
            requestWrapper.MatReqType=obj.Request__r.MatReqType__c;
            requestWrapper.MatReqStatus= obj.Request__r.MatReqStatus__c;
            requestWrapper.MatRequestObj= obj.Request__r.MatRequestObj__c;

            //****Line Items***************************
            requestLine.BibRecObj= obj.BibRecObj__c;
            requestLine.LineNum= obj.LineNum__c;
            requestLine.LineStatus= obj.LineStatus__c;
            requestLine.QtyOrdered= String.valueOf(obj.Quantity__c);
            requestLine.UnitPrice = String.valueOf(obj.UnitPrice__c);
            requestLine.TitleInfo='';
            requestLine.MatRequestLineObj = obj.MatRequestLineObj__c;
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


        //********************Send******************
        Map<String,String> lineItemMap = new Map<String, String>();
        for(Request_Equipment__c item :[SELECT Id,Request__c,MatRequestLineObj__c,BibRecObj__c,KLASID__c FROM Request_Equipment__c WHERE Id IN :requestEquipmentIds]){
            lineItemMap.put(item.MatRequestLineObj__c,item.Id);
        }

        String api_key = String.valueOf(Label.NDBEDP_Key);
        String endPoint = String.valueOf(Label.NDBEDP_MatRequest_N4_N5);
        //String endPoint= ' https://eis.dhstst.nc.gov/ws/rest/klas/matrequests/';

        Http h = new Http();
        HttpResponse res;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint);
        httpReq.setBody(JSON.serialize(requestWrapper));

        try{
            res = h.send(httpReq);
            Case caseObj = new Case();
            List<Request_Equipment__c> lineItemsToUpdate = new List<Request_Equipment__c>();
            NC_NDBEDPEquipmentCatalog.ResponseWrapper responseWrapper = (NC_NDBEDPEquipmentCatalog.ResponseWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPEquipmentCatalog.ResponseWrapper.class);
            if(responseWrapper.STATUS==200){
                for(NC_NDBEDPEquipmentCatalog.ResponseMatRequests req :responseWrapper.matRequests){
                    //Update Mat Request
                    caseObj.Id= matObjVsCaseId.get(req.MatRequestObj);
                    caseObj.MatReqStatus__c= req.MatReqStatus;
                    caseObj.MatReqStatusDate__c= Date.valueOf(req.MatReqStatusDate);

                    //Update Line Items
                    for (NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine reqLine :req.ttMatRequestLine){
                        Request_Equipment__c reqEuip = new Request_Equipment__c();
                        if(lineItemMap.get(reqLine.MatRequestLineObj)!=null){
                            reqEuip.Id= lineItemMap.get(reqLine.MatRequestLineObj);
                            reqEuip.RecordTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
                            //reqEuip.MatRequestLineObj__c= reqLine.MatRequestLineObj;
                            reqEuip.LastActionCode__c= reqLine.LastActionCode;
                            reqEuip.ActionCodeDesc__c= reqLine.ActionCodeDesc;
                            //reqEuip.LineNum__c= String.valueOf(reqLine.LineNum);
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
                            reqEuip.UnitPrice__c = String.isNotBlank(reqLine.UnitPrice) ? Decimal.valueOf(reqLine.UnitPrice) : 0;

                            lineItemsToUpdate.add(reqEuip);
                        }
                    }
                }
                Map<Id,Request_Equipment__c> reqMap = new Map<Id,Request_Equipment__c>();
                reqMap.putall(lineItemsToUpdate);
                if(reqMap.size()>0){
                    update reqMap.values();
                }
                update caseObj;
            }
        }catch (Exception e){
            throw new AuraHandledException('Error: '+e.getMessage());
        }
    }

}