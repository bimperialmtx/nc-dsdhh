({
    doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.getPageURL", calloutParams, true, true)
        .then( $A.getCallback(result => {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
            "url": result
            });
            urlEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        }),
            $A.getCallback(error => {
            console.log(error);
        }));
    }
})