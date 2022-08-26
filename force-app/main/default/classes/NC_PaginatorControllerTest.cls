/**
* @description       : Test class for NC_PaginatorController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_PaginatorControllerTest {
	
    /*
    *********************************************************
    @Method Name    : retrieveRecordsTest
    @description    : Verify records to be retreived using dynamic query
    ********************************************************
    */
    static testmethod void retrieveRecordsTest() {
        
        Case caseObj2 = TestDataUtility.createNDBEDPCase(true);
        Case caseObj = [SELECT CaseNumber, Status, Contact.Birthdate FROM Case WHERE Id =: caseObj2.id];
        
        Map<String,Object> params = new Map<String,Object>();
        params.put('objectName', 'Case');
        params.put('fields', new List<String>{'CaseNumber', 'Contact.Birthdate', 'Status'});
        params.put('searchStr', caseObj.CaseNumber+'');
        params.put('whereClause', 'CaseNumber != \''+caseObj.CaseNumber+'\'');
        params.put('previousPageNo', 0);
        params.put('newPageNo', 2);
        params.put('limit', 10000);
        params.put('sortBy', 'CaseNumber');
        params.put('sortDir', 'ASC');
        params.put('recId', '');
        params.put('recVal', '');
        params.put('maxPageNo', 1);
        params.put('sharing', 'With');
        params.put('searchableFields', new List<String>{'CaseNumber', 'Contact.Birthdate', 'Status'});
        params.put('distinctField', '');
        params.put('showRecordsOnSearchOnly', true);
        Map<Object,Object> idMap = new Map<Object,Object>{'Id'=> caseObj.id};
        params.put('recordIdList', new List<Object>{idMap});
        
        Map<String,Object> resultMap = NC_PaginatorController.retrieveRecords(params);
        System.assertEquals(0, resultMap.get('totalCount'));
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveRecords2Test
    @description    : Verify records to be retreived validation using dynamic query
    ********************************************************
    */
    static testmethod void retrieveRecords2Test() {
        
        Case caseObj2 = TestDataUtility.createNDBEDPCase(true);
        Case caseObj = [SELECT CaseNumber, Status, Contact.Birthdate FROM Case WHERE Id =: caseObj2.id];
        
        Map<String,Object> params = new Map<String,Object>();
        params.put('objectName', 'Case');
        params.put('fields', new List<String>{'CaseNumber', 'Contact.Birthdate', 'Status'});
        params.put('searchStr', caseObj.CaseNumber+'');
        params.put('whereClause', 'CaseNumber = \''+caseObj.CaseNumber+'\'');
        params.put('previousPageNo', 0);
        params.put('newPageNo', 1);
        params.put('limit', 10);
        params.put('sortBy', 'CaseNumber');
        params.put('sortDir', 'ASC');
        params.put('recId', '');
        params.put('recVal', '');
        params.put('maxPageNo', 1);
        params.put('sharing', 'With');
        params.put('searchableFields', new List<String>{'CaseNumber', 'Contact.Birthdate', 'Status'});
        params.put('distinctField', 'CaseNumber');
        params.put('showRecordsOnSearchOnly', false);
        
        Map<String,Object> resultMap = NC_PaginatorController.retrieveRecords(params);
        System.assertEquals(1, resultMap.get('totalCount'));
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveRecords3Test
    @description    : Verify records to be retreived validation using dynamic query
    ********************************************************
    */
    static testmethod void retrieveRecords3Test() {
        
        Case caseObj2 = TestDataUtility.createNDBEDPCase(true);
        Case caseObj = [SELECT CaseNumber, Status, Contact.Birthdate FROM Case WHERE Id =: caseObj2.id];
        
        Map<String,Object> params = new Map<String,Object>();
        params.put('objectName', 'Case');
        params.put('fields', new List<String>{'CaseNumber', 'Contact.Birthdate', 'Status'});
        params.put('searchStr', '');
        params.put('whereClause', 'CaseNumber != \''+caseObj.CaseNumber+'\'');
        params.put('previousPageNo', 0);
        params.put('newPageNo', 2);
        params.put('limit', 10000);
        params.put('sortBy', 'CaseNumber');
        params.put('sortDir', 'ASC');
        params.put('recId', '');
        params.put('recVal', '');
        params.put('maxPageNo', 1);
        params.put('sharing', 'With');
        params.put('searchableFields', new List<String>{'CaseNumber', 'Contact.Birthdate', 'Status'});
        params.put('distinctField', '');
        params.put('showRecordsOnSearchOnly', true);
        Map<Object,Object> idMap = new Map<Object,Object>{'Id'=> caseObj.id};
        params.put('recordIdList', new List<Object>{idMap});
        
        Map<String,Object> resultMap = NC_PaginatorController.retrieveRecords(params);
        System.assertEquals(0, resultMap.get('totalCount'));
    }
}