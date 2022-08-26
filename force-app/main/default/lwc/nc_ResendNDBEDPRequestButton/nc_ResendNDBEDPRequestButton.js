/**
 * Created by ashishpandey on 24/09/21.
 */

import { LightningElement, wire, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getStatus from '@salesforce/apex/NC_ResendEquipmentRequest.getStatus';
import validateEquipment from '@salesforce/apex/NC_ResendEquipmentRequest.validateEquipment';

export default class NcResendNdbedpRequestButton extends LightningElement {

    @api recordId;
    @track isUpdate=false;
    @track spinner=false;
    @track isSyncFailed=false;
    @track isDisabled=false;
    @track requestObj={};

    connectedCallback() {
        this.currentRecordId = this.recordId;
        if(this.currentRecordId){
            this.getStatus();
        }
    }
    getStatus(){
        this.spinner=true;
        getStatus({recordId: this.currentRecordId})
        .then(results => {
            this.spinner=false;
            console.log('getStatus;',JSON.stringify(results));
            this.requestObj=results;
            if(results.Allow_NDBEDP_Request_resync__c){
                this.isSyncFailed=true;
            }
        })
        .catch(error => {
             this.spinner=false;
             console.log('error',JSON.stringify(error));
        });
    }
    validateEquipment(){
        console.log('resend...',this.currentRecordId);
        this.showToast('request has been re-submitted to KLAS. Please check back later.','Success','Success','sticky');
        this.isDisabled=true;
        this.spinner=true;
        validateEquipment({requestId: this.currentRecordId})
        .then(results => {
            this.spinner=false;
            console.log('send;',JSON.stringify(results));
            //this.showToast('Sync Successful. Please refresh this page.','Success','Success','sticky');

        })
        .catch(error => {
             this.spinner=false;
             console.log('error',JSON.stringify(error));
             this.showToast('Something went wrong.','Error','Error','sticky');
        });
    }
    showToast(str,variant,title,mode){
        const errorEvt = new ShowToastEvent({
            title: title,
            message: str,
            variant: variant,
        });
        this.dispatchEvent(errorEvt);
    }

}