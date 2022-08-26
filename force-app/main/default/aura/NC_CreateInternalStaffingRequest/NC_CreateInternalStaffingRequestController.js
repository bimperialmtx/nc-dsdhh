({
	doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.retrieveDefaultsForInternal", calloutParams, true, true)
        .then( $A.getCallback(result => {
            var createRecordEvent = $A.get("e.force:createRecord");
            let params = {
                "entityApiName": "Staffing_Request__c",
                "recordTypeId" : result.recordTypeId
            }
            if(result.forCommunication){
                params.defaultFieldValues = {
                    'Communication_Access_Request__c' : component.get("v.recordId")
                };
            } 
            createRecordEvent.setParams(params);
            createRecordEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire()
        }),
            $A.getCallback(error => {
            console.log(error);
        }));
    }
})