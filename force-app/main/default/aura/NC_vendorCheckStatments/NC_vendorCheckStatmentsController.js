({
    doInit : function(component, event, helper) {},

    viewfileData : function(component, event, helper) {
        console.log('hiiii viewfile ',JSON.stringify(event.getParam("id")));
        let recordid = event.getParam("id") != null ? event.getParam("id") : '';

        if (recordid != undefined) {
            $A.get('e.lightning:openFiles').fire({
                recordIds: [ event.getParam("id")]
            });
        }
    },

    downloadFileData : function(component, event, helper) {
        console.log('hiiii downloadFile  ',JSON.stringify(event.getParam("id")));
        let recordid = event.getParam("id") != null ? event.getParam("id") : '';
        if (recordid != undefined) {
            $A.get('e.lightning:downloadFiles').fire({
                recordIds: [ event.getParam("id")]
            });
        }
    },
})