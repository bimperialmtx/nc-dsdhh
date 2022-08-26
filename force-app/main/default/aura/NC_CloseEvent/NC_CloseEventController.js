({
    doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.closeEvent", calloutParams, true, true)
        .then( $A.getCallback(result => {
            if(result.updated){
                helper.showMessage('SUCCESS!','success', 'Event Closed Successfully.');
            } else {
                helper.showMessage('ERROR!','error', result.message);
            }
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire()
        }),
            $A.getCallback(error => {
            console.log(error);
        }));
    }
})