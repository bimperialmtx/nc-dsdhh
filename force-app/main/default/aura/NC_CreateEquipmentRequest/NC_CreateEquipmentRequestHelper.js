({
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    createRecord: function(component, event, caseId, recordTypeId) {
        var createRecordEvent = $A.get("e.force:createRecord");
        let params = {
            "entityApiName": "Request_Equipment__c",
            "recordTypeId" : recordTypeId,
            "defaultFieldValues": {
                'Request__c' : caseId
            }
        }
        createRecordEvent.setParams(params);
        createRecordEvent.fire();
        //$A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire();
    }
})