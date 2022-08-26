({
    Init : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    erase:function(component, event, helper){
        helper.eraseHelper(component, event, helper);
    },
    save:function(component, event, helper){
        var isBlank = helper.isCanvasBlank(component.find('can').getElement());
        // console.log('Is Canvas Sign Blank ->'+isBlank);
        if(!isBlank){
            helper.saveHelper(component, event, helper);
        }
        else{
            helper.errorToastMessage(component,event);
        }
    },

    OpenPdf : function(component, event, helper){
        console.log('Open URL Fucntion');
        var id = component.get('v.recordId');
        var url = 'https://ncdsdhh--qa--c.visualforce.com/apex/NC_DocumentViewer?id=' + id;
        console.log('URL : ' + url);
        window.open(url,'_blank');
    }
})