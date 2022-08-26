(function(win) {

    var utilMethods = {
        "showToast":showToast
    };

    function showToast(title, type, message, mode, duration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "mode": mode,
            "message": message,
            "duration": duration
        });
        toastEvent.fire();
    }
    win.util = utilMethods;
})(window);