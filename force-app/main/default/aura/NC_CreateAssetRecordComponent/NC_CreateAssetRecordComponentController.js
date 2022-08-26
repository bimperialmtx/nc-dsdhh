({
    doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.cloneAssetRecord", calloutParams, true, true)
        .then( $A.getCallback(result => {
            if(result.length > 18){
                helper.showMessage('ERROR', 'error', result);
                $A.get("e.force:closeQuickAction").fire();
            }else{
                var naviagteToChildAsset = $A.get("e.force:navigateToSObject");
                naviagteToChildAsset.setParams({
                "recordId": result ,
                "slideDevName": "detail"
                });
                naviagteToChildAsset.fire();
            }
            
        }),
        $A.getCallback(error => {
            console.log(error);
        }));
    }
})