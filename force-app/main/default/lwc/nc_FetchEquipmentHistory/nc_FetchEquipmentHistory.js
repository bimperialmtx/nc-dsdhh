/**
 * Created by ashishpandey on 05/10/21.
 */
import { LightningElement, wire, track, api } from 'lwc';
import fetchEquipmentHistory from '@salesforce/apex/NC_FetchEquipmentHistory.fetchEquipmentHistory';
import { CloseActionScreenEvent } from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import NC_DHHS_LWC from '@salesforce/resourceUrl/NC_DHHS_LWC';
//import { getRecordNotifyChange } from 'lightning/uiRecordApi';
 
export default class Nc_FetchEquipmentHistory extends LightningElement {
    @track spinner=false;
    @track delayTimeout;
    @api recordId;

    connectedCallback() {
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.getEquipmentHistory();
        }, 0);

        Promise.all([
            loadStyle( this, NC_DHHS_LWC + '/NC_FetchEquipmentHistory.css' )
            ]).then(() => {
                console.log( 'Files loaded' );
            })
            .catch(error => {
                console.log( error.body.message );
        });
    }

    getEquipmentHistory(){
        this.spinner=true;
        fetchEquipmentHistory({contactId: this.recordId})
        .then(results => {
            if(results && results.Success) {
                this.showErrorToast('Success', results.Success, 'success');
            } else if(results && results.Error) {
                this.showErrorToast('Error', results.Error, 'error');
            } else {
                this.showErrorToast('Error', 'Something went wrong', 'error');
            }
            console.log('result-->',JSON.stringify(results));
            // this.requestObj=results;
            // if(results.Allow_NDBEDP_Request_resync__c){
            //     this.isSyncFailed=true;
            // }
            //getRecordNotifyChange([{recordId: this.recordId}]);
            this.closeQuickAction();
            this.spinner=false;
         })
        .catch(error => {
            this.showErrorToast('Error', error.message || error.body.message, 'error');
            this.closeQuickAction();
            this.spinner=false;
            console.log('error',JSON.stringify(error));
        });
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showErrorToast(title, message, variant) {
        const event = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant
        });
        this.dispatchEvent(event);
    }
}