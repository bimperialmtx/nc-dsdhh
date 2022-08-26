import { LightningElement,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getApplicationRecords from '@salesforce/apex/nc_DSDHHUnsubscribeController.getApplicationRecords';
import saveData from '@salesforce/apex/nc_DSDHHUnsubscribeController.saveData';
import fatchMultiPicklist from '@salesforce/apex/nc_DSDHHUnsubscribeController.fatchMultiPicklist';

export default class Nc_DSDHHUnsubscribePage extends LightningElement {

    @track showSpinner;

    @track subscriptionOption = [];
    @track reasonsForSubscription = [];
    @track contactId = '';
    @track contactRecord = {};
    @track showOtherReason = false;
    @track showThankYou = false;
    @track showReasons = true;
    @track showError = false;

    get getSubscriptionValues(){
        let unsubscribedFrom = ''
        if(typeof this.contactRecord.Communications_Type__c == 'string'){
            unsubscribedFrom = this.contactRecord.Communications_Type__c.split(';').join(', ');
        }else{
            unsubscribedFrom = this.contactRecord.Communications_Type__c.join(', ');
        }
        if(unsubscribedFrom == ''){
            unsubscribedFrom = 'all';
        }
        return unsubscribedFrom;
    }

    connectedCallback() {
        // Get id from url
        let url_string = window.location.href;
        let url = new URL(url_string);
        this.contactId = url.searchParams.get("id");

        // Get picklist values
        this.fetchPicklistValues("Contact", "Communications_Type__c");
        this.fetchPicklistValues("Contact", "Why_You_Unsubscribed__c");

        // Get initial value of contact
        this.getInitialData();
    }

    fetchPicklistValues(objectName, fieldName) {
        this.showSpinner = true;
        fatchMultiPicklist({
            objectName: objectName,
            fieldName: fieldName
        })
        .then((result) => {
            if (fieldName == "Communications_Type__c") {
                this.subscriptionOption = result;
            } else if (fieldName == "Why_You_Unsubscribed__c") {
                this.reasonsForSubscription = result;
            }
        }).catch((error) => {
            this.showSpinner = false;
            this.showErrorToastAndConsole(error);
        });
    }

    getInitialData() {
        this.showSpinner = true;
        getApplicationRecords({ contactId: this.contactId })
        .then((result) => {
            this.contactRecord = result;
            if(this.contactRecord.Id == undefined){
                this.showError = true;
            }else{
                if (this.contactRecord.Communications_Type__c == undefined) {
                    this.contactRecord.Communications_Type__c = '';
                }
                if (this.contactRecord.Why_You_Unsubscribed__c == undefined) {
                    this.contactRecord.Why_You_Unsubscribed__c = '';
                }
                if (this.contactRecord.Other_Reason_For_Unsubscribe__c == undefined) {
                    this.contactRecord.Other_Reason_For_Unsubscribe__c = '';
                }
                this.updateCommunicationType();
                if (this.contactRecord.Communications_Type__c.includes("Unsubscribe from all")) {
                    //this.showReasons = true;
                } else {
                    //this.showReasons = false;
                }
                this.getShowOtherReason();
            }
            
            this.showSpinner = false;
        })
        .catch((error) => {
            this.showErrorToastAndConsole(error);
            this.showSpinner = false;
        });
    }

    updateCommunicationType(){
        if(this.contactRecord.Communications_Type__c != undefined && this.contactRecord.Communications_Type__c != 'Unsubscribe from all'){
            let comuType = this.contactRecord.Communications_Type__c;
            let finalCom = '';
            this.subscriptionOption.forEach(element => {
                if(!comuType.includes(element.value) && element.value != 'Unsubscribe from all'){
                    finalCom = finalCom != '' ? finalCom + ';' + element.value : element.value;
                }
            });
            this.contactRecord.Communications_Type__c = finalCom;
        }
    }
    
    getShowOtherReason() {
        if (this.contactRecord.Why_You_Unsubscribed__c != undefined &&
            this.contactRecord.Why_You_Unsubscribed__c == 'Other (please type in reason below)') {
            this.showOtherReason = true;
        } else {
            this.showOtherReason = false;
            this.contactRecord.Other_Reason_For_Unsubscribe__c = '';
        }
    }

    handleChange(event) {
        if (event.target.name === "subscription") {
            if (this.contactRecord.Communications_Type__c == "Unsubscribe from all" && event.target.value.length > 0) {
                let communicationType = event.target.value;
                const index = communicationType.indexOf("Unsubscribe from all");
                if (index > -1) {
                    communicationType.splice(index, 1);
                }
                this.contactRecord.Communications_Type__c = communicationType;
                this.contactRecord.Other_Reason_For_Unsubscribe__c = '';
                this.contactRecord.DSDHH_Mailing_List__c = true;
                //this.showReasons = false;
            } else {
                if (event.target.value.includes("Unsubscribe from all")) {
                    this.contactRecord.Communications_Type__c = "Unsubscribe from all";
                    this.contactRecord.DSDHH_Mailing_List__c = false;
                    //this.showReasons = true;
                } else {
                    this.contactRecord.Communications_Type__c = event.target.value;
                    this.contactRecord.Other_Reason_For_Unsubscribe__c = '';
                    this.contactRecord.DSDHH_Mailing_List__c = true;
                    //this.showReasons = false;
                }
            }
        } else if (event.target.name === 'resonForUnsubscription') {
            this.contactRecord.Why_You_Unsubscribed__c = event.target.value;
            this.getShowOtherReason();
        } else if (event.target.name === 'otherReason') {
            this.contactRecord.Other_Reason_For_Unsubscribe__c = event.target.value;
        }
    }

    insertContactData() {
        
        if (this.isValid()) {
            this.showSpinner = true;
            this.updateCommunicationType();
            saveData({ contactRecord: this.contactRecord })
            .then(result => {
                this.showThankYou = true;
                this.showToastMessage("Success!", 'Your changes are saved, Thank you!', "success");
                this.showSpinner = false;
            })
            .catch(error => {
                this.showErrorToastAndConsole(error);
                this.showSpinner = false;
            });
        } else {
            this.showToastMessage("Error!", 'Required field missing!', "error");
        }

    }

     // show error
  showErrorToastAndConsole(error) {
    console.log('error :', JSON.stringify(error));
    if (error && error.body && error.body.pageErrors && error.body.pageErrors.length > 0 && error.body.pageErrors[0].message) {
      this.showToastMessage("Error!", error.body.pageErrors[0].statusCode + ' : ' + error.body.pageErrors[0].message, "error");
    } else if(error && error.body && error.body.fieldErrors && error.body.fieldErrors[Object.keys(error.body.fieldErrors)].length > 0 && error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].statusCode && error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].message){
      this.showToastMessage("Error!", error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].statusCode + ' : ' + error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].message , "error");
    } else {
      this.showToastMessage("Error!", JSON.stringify(error), "error");
    }
  }

    isValid(){
        let isAllValid = false;
        isAllValid = [...this.template.querySelectorAll('lightning-combobox, lightning-dual-listbox, lightning-textarea, lightning-radio-group, lightning-checkbox-group ,lightning-input')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if(isAllValid === false){
             return isAllValid;
        }
        return isAllValid;
    }

    //for showing toast message
    showToastMessage(title, message, variant) {
        const event = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant,
        });
        this.dispatchEvent(event);
    }

}