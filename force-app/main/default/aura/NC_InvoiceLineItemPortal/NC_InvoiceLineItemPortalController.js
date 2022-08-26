({
    initHandler : function(component, event, helper) {
            var action = component.get("c.checkRecordType");
            action.setParams({
                invoiceId: component.get("v.recordId")
            });
        
            action.setCallback(this, function (response) {
            var result;
            result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                //dismissActionPanel.fire();
                if(result && result.NDBEDPLineItem && result.NDBEDPLineItem == true) {
                    component.set("v.NDBEDPLineItem",true);
                } else if (result && result.CommunicationLineItem && result.CommunicationLineItem == true) {
                    component.set("v.CommunicationLineItem",true);
                } else if (result && result.EDSLineItem && result.EDSLineItem == true) {
                    component.set("v.EDSLineItem",true);
                } else if (result && result.Error) {
                    console.log('error-->'+result.Error);
                }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();

                    console.log("Error message: " + JSON.stringify(errors));
                } else {
                    console.log("Unknown error");
                }
            }
        })
        $A.enqueueAction(action);
		/*
        setTimeout(() => {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }, 100)*/
    }
  

    
})