({
     onPageReferenceChange: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var consumerId = myPageRef.state.c__consumerid;
        cmp.set("v.consumerId", consumerId);
        console.log('Record Id - ', cmp.get("v.consumerId"));
        
        window.setTimeout(
            $A.getCallback(function() {
                helper.setTabInfo(cmp, evt, helper);
            }), 500
        );
    }
})