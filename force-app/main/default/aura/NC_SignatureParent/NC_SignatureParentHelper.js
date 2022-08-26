({
	validateFilter : function(component, event, helper) {
		var action = component.get("c.checkFilter");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            filter : component.get("v.filter")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state-->'+state);
            if (state === "SUCCESS") {
                console.log('response-->'+JSON.stringify(response.getReturnValue()));
                var response = response.getReturnValue();
                if(response && response == true) {
                    component.set("v.isVisible", true);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
	}
})