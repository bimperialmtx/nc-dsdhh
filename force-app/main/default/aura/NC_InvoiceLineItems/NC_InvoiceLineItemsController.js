({
    doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.getRecordTypeForInvoice", calloutParams, true, true)
        .then( $A.getCallback(result => {
            console.log('Result ' + result  );
            component.set('v.isCommunicationAccess',result);
        }),
        $A.getCallback(error => {
            helper.showMessage('Error', 'error', error );
            $A.get("e.force:closeQuickAction").fire();
        }));
    }
})