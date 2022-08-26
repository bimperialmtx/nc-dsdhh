({
    doInit : function(component, event, helper) {
        let calloutParams = {
            accountId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.retrieveVendorFilesList", calloutParams, true, true)
        .then( $A.getCallback(result => {
            console.log('result',result.filesOptions);
            component.set("v.fileInfo",result.filesOptions);
            component.set('v.showFileDoc',true);
        }),
            $A.getCallback(error => {
            console.log(error);
        }));
    },
    refreshView : function(component, event, helper) {
        $A.get('e.force:refreshView').fire()
    },
    viewfile : function(component, event, helper) {
        console.log('hiiii',JSON.stringify(event.getParam("value")));
        $A.get('e.lightning:openFiles').fire({
		    recordIds: [event.getParam("value").value]
		});
    },
})