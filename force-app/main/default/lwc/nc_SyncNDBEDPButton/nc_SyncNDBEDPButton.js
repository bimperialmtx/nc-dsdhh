/**
 * Created by ashishpandey on 08/07/21.
 */

import { LightningElement, wire, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getCNDSSyncStatus from '@salesforce/apex/NC_SyncNDBEDPButtonController.getNDBEDPSyncStatus';
import getCommentFromError from '@salesforce/apex/NC_SyncNDBEDPButtonController.getCommentFromError';
import sendRequest from '@salesforce/apex/NC_SyncNDBEDPButtonController.sendLookupRequest';

export default class NcSyncNdbedpButton extends LightningElement {
    @api recordId;
    @track isUpdate=false;
    @track spinner=false;
    @track isSyncFailed=false;
    @track isDisabled=false;

    connectedCallback() {
        this.currentRecordId = this.recordId;
        if(this.currentRecordId){
            this.getSyncStatus();
        }
    }
    getSyncStatus(){
        this.spinner=true;
        getCNDSSyncStatus({recordId: this.currentRecordId})
        .then(results => {
            this.spinner=false;
            console.log('getNDBEDP SyncStatus;',JSON.stringify(results));
            if(results.Allow_NDBEDP_Resync__c){
                this.isSyncFailed=true;
            }
        })
        .catch(error => {
             this.spinner=false;
             console.log('error',JSON.stringify(error));
        });
    }
    handleSync(event){
        this.spinner=true;
        getCommentFromError({recordId: this.currentRecordId})
        .then(results => {
            console.log('results',JSON.stringify(results));
            if(!results.Comments__c){
                this.spinner=false;
                this.showToast('Please check the latest created error record of Type NDBEDP for this consumer and add comment first then click on Re-sync.','Error','Error','sticky');
                return;
            }else{
                 this.spinner=true;
                 this.showToast('Details have been re-submitted to NDBEDP. Please check back later.','Success','Success','sticky');
                 this.sendRequest();
                 this.spinner=false;
                 this.isDisabled=true;
            }
        }).catch(error => {
           this.spinner=false;
           console.log('error',JSON.stringify(error));
           this.showToast('Error in submitting the request to NDBEDP. Please try again later.','Error','Error','sticky');
        });
    }
    sendRequest(){
        sendRequest({recordId: this.currentRecordId})
        .then(results => {
            console.log('results',JSON.stringify(results));
        })
        .catch(error => {
             this.spinner=false;
             console.log('error',JSON.stringify(error));
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