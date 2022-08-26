public without sharing class NC_ServiceRequestHelper {
    /*
    *********************************************************
    @Method Name    : saveData
    @description    : save case data without sharing
    @param          : Case caseObj
    @return         : Case
    ********************************************************
    */
    public static Case saveData(Case caseObj){
        try {
            insert caseObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return caseObj;
    }
}