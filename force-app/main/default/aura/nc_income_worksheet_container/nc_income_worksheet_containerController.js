({
    onPageReferenceChange: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        console.log('myPageRef - ', myPageRef.state.c__request);
        var request = myPageRef.state.c__request;
        cmp.set("v.request", request);
        console.log('Record Id - ', cmp.get("v.request"));
        
        window.setTimeout(
            $A.getCallback(function() {
                helper.setTabInfo(cmp, evt, helper);
            }), 500
        );
    }
})