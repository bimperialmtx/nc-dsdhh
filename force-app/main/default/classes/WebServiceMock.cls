/**
* @description       : Test class mock responses for integrations
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class WebServiceMock {
    
    public class GetEquipmentCatalogMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            
            NC_ConnectEquipmentWrapper.TtEqp ttEqp = new NC_ConnectEquipmentWrapper.TtEqp();
            ttEqp.Annotations = 'Test';
            ttEqp.Author = 'Test';
            ttEqp.BibRecObj = 'Test';
            ttEqp.KlasID = 'Test';
            ttEqp.Medcode = 'Test';
            ttEqp.ReplaceCost = '100';
            ttEqp.Titl = 'Test';
            ttEqp.ManPartNum = 'Test';
            ttEqp.URL = '';
            ttEqp.ImageURL = '';
            ttEqp.ImageFileName = '';
            ttEqp.quantity = '1';
            ttEqp.OPACSup = 'false';
            
            NC_ConnectEquipmentWrapper.Eqp eqp = new NC_ConnectEquipmentWrapper.Eqp();
            eqp.ttEqp = new List<NC_ConnectEquipmentWrapper.TtEqp>{ttEqp};
                
                NC_ConnectEquipmentWrapper.EquipmentResponse resp = new NC_ConnectEquipmentWrapper.EquipmentResponse();
            resp.STATUS = '200';
            resp.ERROR_DESCRIPTION = '';
            resp.offset = 0;
            resp.count = 1;
            resp.eqp = eqp;
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
    public class GetEquipmentHistoryMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            
            if(request.getEndpoint().contains('migration') || request.getEndpoint().contains('matrequests')) {
             	NC_NDBEDPEquipmentCatalog.ResponseWrapper resp = new NC_NDBEDPEquipmentCatalog.ResponseWrapper();
                resp.STATUS = 200;
                resp.ERROR_DESCRIPTION = 'ACTIONCOMPLETEDSUCCESSFULLY';
                
                NC_NDBEDPEquipmentCatalog.ResponseMatRequests matReq = new NC_NDBEDPEquipmentCatalog.ResponseMatRequests();
                matReq.MatReqStatus = 'Closed';
                matReq.MatReqStatusDate = '2022-09-09';
                matReq.MatReqType = 'Eqp';
                matReq.MatRequestID = '210909-001';
                matReq.MatRequestObj = '54645937.9532';
                
                NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine ttMatReq = new NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine();
                ttMatReq.BibRecObj = '575390.9532';
                ttMatReq.LastActionCode = 'CAN';
                ttMatReq.ActionCodeDesc = 'Cancelled';
                ttMatReq.LineNum = 1;
                ttMatReq.LineStatus = 'Closed';
                ttMatReq.LineStatusDate = '2022-09-09';
                ttMatReq.MatRequestLineObj = '54645944.9532';
                ttMatReq.QtyOrdered = '1';
                ttMatReq.QtyShipped = '0';
                ttMatReq.Shipping = '0';
                ttMatReq.Total = '0';
                ttMatReq.UnitPrice = '0';
                matReq.ttMatRequestLine = new List<NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine>{ttMatReq};
                resp.matRequests = new List<NC_NDBEDPEquipmentCatalog.ResponseMatRequests>{matReq};
                
                response.setBody(JSON.serialize(resp));   
            } else if(request.getEndpoint().contains('catalog')) {
                NC_ConnectEquipmentWrapper.TtEqp ttEqp = new NC_ConnectEquipmentWrapper.TtEqp();
                ttEqp.Annotations = 'Test';
                ttEqp.Author = 'Test';
                ttEqp.BibRecObj = '575390.9532';
                ttEqp.KlasID = 'Test';
                ttEqp.Medcode = 'Test';
                ttEqp.ReplaceCost = '100';
                ttEqp.Titl = 'Test';
                ttEqp.ManPartNum = 'Test';
                ttEqp.URL = '';
                ttEqp.ImageURL = '';
                ttEqp.ImageFileName = '';
                ttEqp.quantity = '1';
                ttEqp.OPACSup = 'false';
                
                NC_ConnectEquipmentWrapper.Eqp eqp = new NC_ConnectEquipmentWrapper.Eqp();
                eqp.ttEqp = new List<NC_ConnectEquipmentWrapper.TtEqp>{ttEqp};
                    
                NC_ConnectEquipmentWrapper.EquipmentResponse resp = new NC_ConnectEquipmentWrapper.EquipmentResponse();
                resp.STATUS = '200';
                resp.ERROR_DESCRIPTION = '';
                resp.offset = 0;
                resp.count = 1;
                resp.eqp = eqp;
                
                response.setBody(JSON.serialize(resp));
            }
            return response;
        }
    }
    
    public class GetEquipmentDemoHistoryMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            
            if(request.getEndpoint().contains('migration') || request.getEndpoint().contains('matrequests')) {
             	NC_NDBEDPEquipmentCatalog.ResponseWrapper resp = new NC_NDBEDPEquipmentCatalog.ResponseWrapper();
                resp.STATUS = 200;
                resp.ERROR_DESCRIPTION = 'ACTIONCOMPLETEDSUCCESSFULLY';
                
                NC_NDBEDPEquipmentCatalog.ResponseMatRequests matReq = new NC_NDBEDPEquipmentCatalog.ResponseMatRequests();
                matReq.MatReqStatus = 'Closed';
                matReq.MatReqStatusDate = '2022-09-09';
                matReq.MatReqType = 'Demo';
                matReq.MatRequestID = '210909-001';
                matReq.MatRequestObj = '54645937.9532';
                
                NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine ttMatReq = new NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine();
                ttMatReq.BibRecObj = '575390.9532';
                ttMatReq.LastActionCode = 'CAN';
                ttMatReq.ActionCodeDesc = 'Cancelled';
                ttMatReq.LineNum = 1;
                ttMatReq.LineStatus = 'Closed';
                ttMatReq.LineStatusDate = '2022-09-09';
                ttMatReq.MatRequestLineObj = '54645944.9532';
                ttMatReq.QtyOrdered = '1';
                ttMatReq.QtyShipped = '0';
                ttMatReq.Shipping = '0';
                ttMatReq.Total = '0';
                ttMatReq.UnitPrice = '0';
                matReq.ttMatRequestLine = new List<NC_NDBEDPEquipmentCatalog.Response_ttMatRequestLine>{ttMatReq};
                resp.matRequests = new List<NC_NDBEDPEquipmentCatalog.ResponseMatRequests>{matReq};
                
                response.setBody(JSON.serialize(resp));   
            } else if(request.getEndpoint().contains('catalog')) {
                NC_ConnectEquipmentWrapper.TtEqp ttEqp = new NC_ConnectEquipmentWrapper.TtEqp();
                ttEqp.Annotations = 'Test';
                ttEqp.Author = 'Test';
                ttEqp.BibRecObj = '575390.9532';
                ttEqp.KlasID = 'Test';
                ttEqp.Medcode = 'Test';
                ttEqp.ReplaceCost = '100';
                ttEqp.Titl = 'Test';
                ttEqp.ManPartNum = 'Test';
                ttEqp.URL = '';
                ttEqp.ImageURL = '';
                ttEqp.ImageFileName = '';
                ttEqp.quantity = '1';
                ttEqp.OPACSup = 'false';
                
                NC_ConnectEquipmentWrapper.Eqp eqp = new NC_ConnectEquipmentWrapper.Eqp();
                eqp.ttEqp = new List<NC_ConnectEquipmentWrapper.TtEqp>{ttEqp};
                    
                NC_ConnectEquipmentWrapper.EquipmentResponse resp = new NC_ConnectEquipmentWrapper.EquipmentResponse();
                resp.STATUS = '200';
                resp.ERROR_DESCRIPTION = '';
                resp.offset = 0;
                resp.count = 1;
                resp.eqp = eqp;
                
                response.setBody(JSON.serialize(resp));
            }
            return response;
        }
    }
    
    public class GetEquipmentRequestStatusMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            
            NC_NDBEDPEquipmentCatalog.MatRequestStatus_TtMatRequestLine ttMatRequestLine = new NC_NDBEDPEquipmentCatalog.MatRequestStatus_TtMatRequestLine();
            ttMatRequestLine.BibRecObj = 'TEST';
            ttMatRequestLine.LastActionCode = 'TEST';
            ttMatRequestLine.ActionCodeDesc = 'TEST';
            ttMatRequestLine.LineNum = 'TEST';
            ttMatRequestLine.LineStatus = 'TEST';
            ttMatRequestLine.LineStatusDate = System.today() + 'TEST';
            ttMatRequestLine.MatRequestLineObj = 'TEST';
            ttMatRequestLine.QtyOrdered = '1';
            //ttMatRequestLine.OPACSup = 'false';
            
            NC_NDBEDPEquipmentCatalog.MatRequests matRequest = new NC_NDBEDPEquipmentCatalog.MatRequests();
            matRequest.MatReqStatus = 'cancelled';
            matRequest.MatReqStatusDate = SYSTEM.today() + '';
            matRequest.MatReqType = 'TEST';
            matRequest.MatRequestID = 'TEST';
            matRequest.MatRequestObj = 'TEST';
            matRequest.ttMatRequestLine = new List<NC_NDBEDPEquipmentCatalog.MatRequestStatus_TtMatRequestLine>{ttMatRequestLine};
                
            NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse matRequestStatusResp = new NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse();
            matRequestStatusResp.STATUS = 200;
            matRequestStatusResp.ERROR_DESCRIPTION = '';
            matRequestStatusResp.count = 0;
            matRequestStatusResp.hasMoreResults = false;
            matRequestStatusResp.matRequests = new List<NC_NDBEDPEquipmentCatalog.MatRequests>{matRequest};
                
                HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(matRequestStatusResp));
            response.setStatusCode(200);
            return response; 
        }
    }
    
    public class GetCNDSConsumerMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            
            NC_CNDSWrapper.PersonUpdateResponse resp = new NC_CNDSWrapper.PersonUpdateResponse();
            resp.STATUS = '200';
            resp.ERROR_DESCRIPTION = '';
            resp.IDENTIFIER = '';
            resp.CHECK_DIGIT = '';
            // resp.eqp = eqp;
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
     public class GetCNDSPersonSearchMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            
            NC_CNDSWrapper.PersonaSearchResponse personaSearch = new NC_CNDSWrapper.PersonaSearchResponse();
            personaSearch.IDENTIFIER = 'test';
            personaSearch.CHECK_DIGIT = 'test';
            personaSearch.CURRENT_STATUS_CODE = 'test';
            personaSearch.SOUNDEX_ID = 'test';
            personaSearch.LAST_NAME = 'TESTCON';
            personaSearch.FIRST_NAME = 'TEST';
            personaSearch.MIDDLE_INITIAL = 'T';
            personaSearch.PRIMARY_SSN = '1234';
            personaSearch.DATE_OF_BIRTH = '19861209';
            personaSearch.SEX_CODE = 'Male';
            personaSearch.ETHNICITY = 'test';
            personaSearch.LANGUAGE_PREFRENCE = 'test';
            personaSearch.RACE_CODE1 = 'test';
            personaSearch.RACE_CODE2 = 'test';
            personaSearch.RACE_CODE3 = 'test';
            personaSearch.RACE_CODE4 = 'test';
            personaSearch.RACE_CODE5 = 'test';
            
            NC_CNDSWrapper.PersonaSearchResponse personaSearch1 = new NC_CNDSWrapper.PersonaSearchResponse();
            personaSearch1.IDENTIFIER = 'test';
            personaSearch1.CHECK_DIGIT = 'test';
            personaSearch1.CURRENT_STATUS_CODE = 'test';
            personaSearch1.SOUNDEX_ID = 'test';
            personaSearch1.LAST_NAME = 'TESTCON';
            personaSearch1.FIRST_NAME = 'TEST';
            personaSearch1.MIDDLE_INITIAL = 'T';
            personaSearch1.PRIMARY_SSN = '1234';
            personaSearch1.DATE_OF_BIRTH = '19861209';
            personaSearch1.SEX_CODE = 'Male';
            personaSearch1.ETHNICITY = 'test';
            personaSearch1.LANGUAGE_PREFRENCE = 'Thai';
            personaSearch1.RACE_CODE1 = 'White';
            personaSearch1.RACE_CODE2 = 'Asian';
            personaSearch1.RACE_CODE3 = 'Black or African American';
            personaSearch1.RACE_CODE4 = 'Native Hawaiian or other Pacific Islander';
            personaSearch1.RACE_CODE5 = 'American Indian or Alaska Native';
            
            List<NC_CNDSWrapper.PersonaSearchResponse> responseList = new List<NC_CNDSWrapper.PersonaSearchResponse>();
            responseList.add(personaSearch);
            responseList.add(personaSearch1);
            
            NC_CNDSWrapper.PearsonSearchWrapper resp = new NC_CNDSWrapper.PearsonSearchWrapper();
            resp.STATUS = '200';
            resp.ERROR_DESCRIPTION = '';
            resp.CCIPR82I_Person_Search_Response = responseList;
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
    public class GetNCNDBEDPPatronSearch implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            
            NC_NDBEDPWrapper.PatronContacts ttMatRequestLine = new NC_NDBEDPWrapper.PatronContacts();
            ttMatRequestLine.ContactType = 'ADDR';
            ttMatRequestLine.ContactValue = '1234567890';
            ttMatRequestLine.ContactSubType = 'HomeA';
            ttMatRequestLine.Address = 'Test';
            ttMatRequestLine.City = 'Test';
            ttMatRequestLine.PostalCode = '12345';
            ttMatRequestLine.CountyCode = '37049';
            ttMatRequestLine.CountryCode = '37049';
            ttMatRequestLine.StateCode = 'NC';
            ttMatRequestLine.AltContactEmail = '';
            ttMatRequestLine.AltContactPhone = '';
            ttMatRequestLine.ContactMode = '1';
            ttMatRequestLine.PatronContactObj = 'false';
            ttMatRequestLine.AddressLinkObj = 'false';
            
            NC_NDBEDPWrapper.patrons ttEqp = new NC_NDBEDPWrapper.patrons();
            ttEqp.PatronObj = 'Test';
            ttEqp.PatronID = 'Test';
            ttEqp.BirthDate = String.valueOf(Date.newInstance(1986, 12, 9));
            ttEqp.FirstName = 'test';
            ttEqp.LastName = 'TestCon';
            ttEqp.MI = 'test';
            ttEqp.RegExpDate = 'Test';
            ttEqp.StatusCode = 'T';
            ttEqp.SuffixCode = '';
            ttEqp.Ethnicity = '';
            ttEqp.PatronType = '';
            ttEqp.GenderCode = 'M';
            ttEqp.PatronUserID = 'false';
            ttEqp.LanguageCode = 'EN';
            ttEqp.LibraryId = 'false';
            ttEqp.PatronContacts = new List <NC_NDBEDPWrapper.PatronContacts>{ttMatRequestLine};
                
                
            NC_NDBEDPWrapper resp = new NC_NDBEDPWrapper();
            resp.STATUS = 200;
            resp.ERROR_DESCRIPTION = '';
            resp.count = 1;
            resp.patrons = new List<NC_NDBEDPWrapper.patrons>{ttEqp};
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
    public class GetNCNDBEDPResponseWrapper implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            
            NC_NDBEDPResponseWrapper.PatronContacts ttMatRequestLine = new NC_NDBEDPResponseWrapper.PatronContacts();
            ttMatRequestLine.STATUS = 200;
            ttMatRequestLine.ERROR_DESCRIPTION = 'Test';
            ttMatRequestLine.AddressLinkObj = 'HomeA';
            ttMatRequestLine.PatronContactObj = 'Test';
            ttMatRequestLine.ContactType = 'ADDR';
            ttMatRequestLine.ContactSubType = 'HomeA';
            
            NC_NDBEDPResponseWrapper.Patron ttEqp = new NC_NDBEDPResponseWrapper.Patron();
            ttEqp.PatronObj = 'Test';
            ttEqp.PatronID = 'Test';
            ttEqp.AddressLinkObj = 'Test';
            ttEqp.PatronContacts = new List <NC_NDBEDPResponseWrapper.PatronContacts>{ttMatRequestLine};
                
                
                
                // ttEqp.LibraryId = 'false';
                
            NC_NDBEDPResponseWrapper resp = new NC_NDBEDPResponseWrapper();
            resp.STATUS = 200;
            resp.ERROR_DESCRIPTION = '';
            resp.Patron = /*new List <NC_NDBEDPResponseWrapper.patrons>{ttEqp};*/ttEqp;
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
    public class ExceptionMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Exception');
            throw e;
        }
    }
}