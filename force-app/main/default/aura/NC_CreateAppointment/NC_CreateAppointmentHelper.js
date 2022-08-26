({
    doInitHelper : function(component, event, helper) {
        let calloutParams = {
            authorizationId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.retrieveVendor", calloutParams, true, true)
        .then( $A.getCallback(result => {
            $A.get("e.force:closeQuickAction").fire();
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Appointment__c",
                "defaultFieldValues": {
                    'Authorization__c' : component.get("v.recordId"),
                    'Order__c': result.order
                }
            });
            createRecordEvent.fire();
        }),
            $A.getCallback(error => {
            console.log(error);
        }));
    }
})