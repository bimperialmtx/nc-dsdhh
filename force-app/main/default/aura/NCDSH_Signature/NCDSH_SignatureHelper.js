({
    doInit: function(component, event, helper) {
   //     console.log("application id in edit value " + component.get("v.applicationId"));
        var canvas, ctx, flag = false,
            prevX = 0,
            currX = 0,
            prevY = 0,
            currY = 0,
            dot_flag = false;

        var x = "black",
            y = 2,
            w, h;
        canvas = component.find('can').getElement();
        var ratio = Math.max(window.devicePixelRatio || 1, 1);
        w = canvas.width * ratio;
        h = canvas.height * ratio;
        ctx = canvas.getContext("2d");
        // var background = new Image();
        // background.src = 'https://www.istockphoto.com/resources/images/Thinkstock/1095407386.jpg';
        // background.onload = function () {  
        //     ctx.drawImage(background, 0, 0);
        // };
        // ctx.globalCompositeOperation="destination-over";
        //  window.location = canvas.canvas.toDataURL('image/png');
      //  console.log('ctx:=' + ctx);

        canvas.addEventListener("mousemove", function(e) {
            findxy('move', e)
        }, false);
        canvas.addEventListener("mousedown", function(e) {
            findxy('down', e)
        }, false);
        canvas.addEventListener("mouseup", function(e) {
            findxy('up', e)
        }, false);
        canvas.addEventListener("mouseout", function(e) {
            findxy('out', e)
        }, false);
        // Set up touch events for mobile, etc
        canvas.addEventListener("touchstart", function(e) {
            var touch = e.touches[0];
        //    console.log('touch start:=' + touch);
            var mouseEvent = new MouseEvent("mousedown", {
                clientX: touch.clientX,
                clientY: touch.clientY
            });
            canvas.dispatchEvent(mouseEvent);
            e.preventDefault();
        }, false);
        canvas.addEventListener("touchend", function(e) {
            var mouseEvent = new MouseEvent("mouseup", {});
            canvas.dispatchEvent(mouseEvent);
        }, false);
        canvas.addEventListener("touchmove", function(e) {
            var touch = e.touches[0];
            var mouseEvent = new MouseEvent("mousemove", {
                clientX: touch.clientX,
                clientY: touch.clientY
            });
            canvas.dispatchEvent(mouseEvent);
            e.preventDefault();

        }, false);

        // Get the position of a touch relative to the canvas
        function getTouchPos(canvasDom, touchEvent) {
            var rect = canvasDom.getBoundingClientRect();
            return {
                x: touchEvent.touches[0].clientX - rect.left,
                y: touchEvent.touches[0].clientY - rect.top
            };
        }

        function findxy(res, e) {
            const rect = canvas.getBoundingClientRect();
            if (res == 'down') {
                prevX = currX;
                prevY = currY;
                currX = e.clientX - rect.left;
                currY = e.clientY - rect.top;

                flag = true;
                dot_flag = true;
                if (dot_flag) {
                    ctx.beginPath();
                    ctx.fillStyle = x;
                    ctx.fillRect(currX, currY, 2, 2);
                    ctx.closePath();
                    dot_flag = false;
                }
            }
            if (res == 'up' || res == "out") {
                flag = false;
            }
            if (res == 'move') {
                if (flag) {
                    prevX = currX;
                    prevY = currY;
                    currX = e.clientX - rect.left;
                    currY = e.clientY - rect.top;
                    draw(component, ctx);
                }
            }
        }

        function draw() {
            ctx.beginPath();
            ctx.moveTo(prevX, prevY);
            ctx.lineTo(currX, currY);
            ctx.strokeStyle = x;
            ctx.lineWidth = y;
            ctx.stroke();
            ctx.closePath();
        }

    },
    
    isCanvasBlank: function (canvas) {
        var blank = document.createElement('canvas');
        blank.width = canvas.width;
        blank.height = canvas.height;
        return canvas.toDataURL() == blank.toDataURL();
    },

    eraseHelper: function(component, event, helper) {
        //var m = confirm("Want to clear");
        //if (m) {
            var canvas = component.find('can').getElement();
            var ctx = canvas.getContext("2d");
            var w = canvas.width;
            var h = canvas.height;
            ctx.clearRect(0, 0, w, h);
            // ctx.globalCompositeOperation="destination-over";
            var background = new Image();
            // background.src = 'https://www.istockphoto.com/resources/images/Thinkstock/1095407386.jpg';
            // ctx.drawImage(background, 0, 0);
        //    component.find("overlayLib").notifyClose();
        //}
    },
    saveHelper: function(component, event, helper) {
        // component.set("v.attachmentId",null);
       
        var pad = component.find('can').getElement();
        var dataUrl = pad.toDataURL();
     // console.log('dataUrl:=' + dataUrl);
        var strDataURI = dataUrl.replace(/^data:image\/(png|jpg);base64,/, "");
        console.log('Signature Body ----> '+strDataURI);
        console.log('component.get("v.recordId")'+component.get("v.recordId"));
        var action = component.get("c.saveSignature");
       
        action.setParams({
            "signatureBody": strDataURI,
            "applicationId": component.get("v.recordId")
        });
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
                        title: "Success!",
                        message: "Signature saved under attachments in related section successfully!",
                        type: "success"
                    });
        
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                toastEvent.fire();
                // console.log("return id is" );
                    console.log(res.getReturnValue());
                // component.set('v.fileId',res.getReturnValue());
                    component.find("overlayLib").notifyClose();
                    var appEvent = $A.get("e.c:NCDSHSignEvent");
                // Set event attribute value
                    var recId = res.getReturnValue();
                    appEvent.setParams({
                        "attachmentId": recId
                    });
                    appEvent.fire();
                    // helper.eraseHelper(component, event, helper);
            } else {
            console.log("state is " + state)
            }
        });
        $A.enqueueAction(action);
    },
    errorToastMessage: function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Error Message',
            message: 'Please Enter A Signature',
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overridden',
            duration: '300',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Signature Updated',
            duration:' 300',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
})