({
	doInit : function(component, event, helper) {
		var url = window.location.href;
        var oureachId;
        if(url.indexOf('inContextOfRef') != -1) {
            var value = helper.getParameterByName(component , event, 'inContextOfRef');
            var context = JSON.parse(window.atob(value));
            oureachId = context.attributes.recordId;
            component.set("v.outreachId", oureachId);
        } else if(url.split('/Outreach_Request__c/').length > 1){
            oureachId = url.split('/Outreach_Request__c/')[1].split('/')[0];
            component.set("v.outreachId", oureachId);
        } else if(url.split('%2FOutreach_Request__c%2F').length > 0) {
            oureachId = url.split('%2FOutreach_Request__c%2F')[1].split('%2F')[0];
            component.set("v.outreachId", oureachId);
        }
        helper.getRecordTypes(component, event, helper);
	},
    
    handleNextClick : function(component, event, helper) {
    	helper.createRecord(component, event, component.get("v.outreachId"), component.get("v.recordTypeId"));
	},
 
    handleCancelClick : function(component, event, helper) {
        helper.closeTab(component, event);
    }
})