/**
 * Created by ashishpandey on 12/05/21.
 */

import { LightningElement, wire, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getCNDSSyncStatus from '@salesforce/apex/NC_SyncCndsButtonController.getCNDSSyncStatus';
import getCommentFromError from '@salesforce/apex/NC_SyncCndsButtonController.getCommentFromError';
import sendRequest from '@salesforce/apex/NC_SyncCndsButtonController.sendLookupRequest';
import sendUpdateRequest from '@salesforce/apex/NC_SyncCndsButtonController.sendUpdateRequest';

export default class NcSyncCndsButton extends LightningElement {
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
            console.log('getCNDSSyncStatus;',JSON.stringify(results));
            if(results.Allow_Resync__c){
                this.isSyncFailed=true;
            }
            if(results.Allow_CNDS_Update_Sync__c){
                this.isUpdate=true;
                this.isSyncFailed=true;
            }
            if(results.Cnds_Identifier__c!=null && !this.isUpdate){
                this.isSyncFailed=false;
            }
            console.log('isSyncFailed>>',this.isSyncFailed);
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
                this.showToast('Please check the latest created error record for this consumer and add comment first then click on Re-sync.','Error','Error','sticky');
                return;
            }else{
                 this.spinner=true;
                 this.showToast('Details have been re-submitted to CNDS. Please check back later.','Success','Success','sticky');
                 this.sendRequest();
                 this.spinner=false;
                 this.isDisabled=true;
            }
        }).catch(error => {
           this.spinner=false;
           console.log('error',JSON.stringify(error));
           this.showToast('Error in submitting the request to CNDS. Please try again later.','Error','Error','sticky');
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
    handleUpdateSync(event){
        this.spinner=true;
        getCommentFromError({recordId: this.currentRecordId})
        .then(results => {
            console.log('results',JSON.stringify(results));
            if(!results.Comments__c){
                this.spinner=false;
                this.showToast('Please check the latest created error record for this consumer and add comment first then click on Re-sync.','Error','Error','sticky');
                return;
            }else{
                 this.spinner=true;
                 this.showToast('Details have been re-submitted to CNDS. Please check back later.','Success','Success','sticky');
                 this.sendUpdateRequest();
                 this.spinner=false;
                 this.isDisabled=true;
            }
        }).catch(error => {
           this.spinner=false;
           console.log('error',JSON.stringify(error));
           this.showToast('Error in submitting the request to CNDS. Please try again later.','Error','Error','sticky');
        });
    }
    sendUpdateRequest(){
        this.spinner=true;
        sendUpdateRequest({recordId: this.currentRecordId})
        .then(results => {
            console.log('results',JSON.stringify(results));
             this.spinner=false;
             this.showToast('Details have been re-submitted to CNDS. Please check back later.','Success','Success','sticky');
             this.isDisabled=true;
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