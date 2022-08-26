({
    doInit : function(component, event, helper) {
        let filesOptions = [];
        if(component.get('v.fileInfo1'))
            filesOptions.push(component.get('v.fileInfo1'));
        if(component.get('v.fileInfo2'))
            filesOptions.push(component.get('v.fileInfo2'));
        if(component.get('v.fileInfo3'))
            filesOptions.push(component.get('v.fileInfo3'));
        if(component.get('v.fileInfo4'))
            filesOptions.push(component.get('v.fileInfo4'));
        if(component.get('v.fileInfo5'))
            filesOptions.push(component.get('v.fileInfo5'));
        if(component.get('v.fileInfo6'))
            filesOptions.push(component.get('v.fileInfo6'));
        if(component.get('v.fileInfo7'))
            filesOptions.push(component.get('v.fileInfo7'));
        if(component.get('v.fileInfo8'))
            filesOptions.push(component.get('v.fileInfo8'));
        if(component.get('v.fileInfo9'))
            filesOptions.push(component.get('v.fileInfo9'));
        if(component.get('v.fileInfo10'))
            filesOptions.push(component.get('v.fileInfo10'));
        if(component.get('v.fileInfo11'))
            filesOptions.push(component.get('v.fileInfo11'));
        if(component.get('v.fileInfo12'))
            filesOptions.push(component.get('v.fileInfo12'));
        component.set("v.fileInfo",filesOptions);
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