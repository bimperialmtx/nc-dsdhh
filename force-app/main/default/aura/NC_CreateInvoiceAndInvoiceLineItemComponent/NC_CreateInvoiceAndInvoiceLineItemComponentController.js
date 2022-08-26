({
    doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.createInvoiceAndInvoiceLineItem", calloutParams, true, true)
        .then( $A.getCallback(result => {
            if(result.result == 'Success'){
                helper.showMessage('Success', 'success', 'Invoice is Created');
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }else if(result.result){
                helper.showMessage('Error', 'error', result.result);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            
        }),
        $A.getCallback(error => {
            helper.showMessage('Error', 'error', error );
            $A.get("e.force:closeQuickAction").fire();
        }));
    }
})