({
	doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.retrieveDefaults", calloutParams, true, true)
        .then( $A.getCallback(result => {
            var createRecordEvent = $A.get("e.force:createRecord");
            let params = {
                "entityApiName": "Contact_Attempt__c",
                "recordTypeId" : result.recordTypeId
            }
            if(result.forAsset){
                params.defaultFieldValues = {
                    'Asset__c' : component.get("v.recordId")
                };
            } else {
                params.defaultFieldValues = {
                    'Request__c' : component.get("v.recordId")
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