({
    /*
    * @description :Use this method to call any apex class method
    * @params :  component : instance of component
    *         : method : name of apex class method (for ex. 'c.getAccount')
    *         : params : params needs to be passed to apex class. should be in json format. for example {'nameString' : 'testName'}
    * @return : promise with either results or error
    */
    doCallout : function (component, method, params, showLoading, toastError) {
        let _this = this;
        console.log('in action');
        return new Promise($A.getCallback(function (resolve, reject) {
            // Set action and param
            let action = component.get(method);
            if (params != null) {
                action.setParams(params);
            }
            // Callback
            action.setCallback(component, function (response) {
                let state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    console.log('action completed');
                    resolve(response.getReturnValue());
                } else {
                    let errors = response.getError();
                    if(toastError) {
                        let errors = response.getError();
                        let message = 'Unknown error'; // Default error message
                        // Retrieve the error message sent by the server
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            if(typeof errors[0].message != 'Undefined' && !$A.util.isEmpty(errors[0].message))
                                message = errors[0].message;
                            else
                                message = errors[0].pageErrors[0].message;
                        }
                        _this.showMessage("Error!","error",message);
                    }
                    reject(errors);
                }
                component.set("v.isLoading", false);
            });
            if(showLoading)
                component.set("v.isLoading", true);
            $A.enqueueAction(action);
        }));
    },
    /*
    * @description : Use this method to show any toast message
    * @params : title : title for toast
    *         : message : message to show in toast
    *         : type : type can be info , success,warning,error
    * @return : promise with either results or error
    */
    showMessage : function(title, type, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title" : title,
            "message" : message,
            "type" : type
        });
        toastEvent.fire();
    },
    /*
    * @description : Use this method to open any custom component in modal
    * @params : component : instance of component
    *         : componentName : name of custom component to open in modal
    *         : attributes : attributes of custom component in json format
    *         : customClasses : any custom classes to apply on modal
    * @return : promise with either results or error
    */
    openModal : function(component,componentName,attributes,customClasses) {
        return new Promise(function(resolve,reject) {
            let overlayLib = component.find('overlayLib');
            //if component has overlay library, then only go ahead otherwise show error
            if(componentName  && componentName.trim() !== '') {
                if(overlayLib) {
                    $A.createComponent(
                        componentName,
                        attributes || {},
                        function(content, status, errorMessage) {
                            if (status === "SUCCESS") {
                                component.find('overlayLib').showCustomModal({
                                    body : content || '',
                                    cssClass : customClasses || ''
                                }).then(function(modal) {
                                    resolve(modal);
                                },function(error) {
                                    reject();
                                    console.log('ERROR::BASE::Error while creating overlay '+ error);
                                })
                            } else { //error while creating new component
                                reject();
                                console.log('ERROR::BASE::Error while creating new component '+ errorMessage);
                            }
                        }
                    );
                } else {
                    reject();
                    console.log('ERROR::BASE::Please add "<lightning:overlayLibrary aura:id="overlayLib" />" in child component ');
                }
            } else {
                reject();
                console.log('ERROR::BASE::Custom component name not provided ');
            }
        });

    },
    /*
    * @description : Use this method to check if required fields are valid or not
                   : use only for fields which doesnt have standard checkValidity for ex. lightning:inputField
                   : it will assign them a class that is passed as parameter if its not valid
    * @params : component : instance of component
    *         : errorClass : css class to assign if field is not valid
    *         : listOfFields : list of aura ids of fields to validate
    *
    * @return : returns true if even a single field is not valid
    */
    checkRequired : function(component,errorClass,listOfFields) {
        let validSoFar = true;
        let _this = this;

        for(let x=0;x<listOfFields.length;x++) {
            if(!_this.checkRequiredFieldById(component,errorClass,listOfFields[x]))
                validSoFar = false;
        }
        return validSoFar;
    },


    //check required on individual fields
    checkRequiredFieldById : function(component,errorClass,auraId) {
        let _this = this;
        let field = component.find(auraId);
        if(field) {
            if(field.constructor === Array) {
                let validSoFar = true;
                for(let x = 0; x < field.length; x++) {
                    if(!_this.checkRequiredIndividualField(errorClass,field[x]))
                        validSoFar = false;
                }
                return validSoFar;
            } else {
                return _this.checkRequiredIndividualField(errorClass,field);
            }
        } else {
            return true;
        }
    },

    //check required on individual fields
    checkRequiredIndividualField : function(errorClass,field) {
        let value = field.get("v.value");
        if(!value || value.trim().length == 0) {
            $A.util.addClass(field, errorClass);
            return false;
        } else {
            $A.util.removeClass(field, errorClass);
            return true;
        }
    },
    editRecord : function(recordToEditId) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordToEditId
        });
        editRecordEvent.fire();
    },

    //doWhat - show / hide
    toggleLoader : function(component, doWhat) {
        component.set("v.isLoading", doWhat == 'show');
    },

})