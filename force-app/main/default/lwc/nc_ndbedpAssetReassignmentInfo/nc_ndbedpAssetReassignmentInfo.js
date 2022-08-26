import { LightningElement,api } from 'lwc';
import getAssetReassignmentInfo from '@salesforce/apex/NC_NDBEDPAssetReassignmentInfoController.getAssetReassignmentInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Nc_ndbedpAssetReassignmentInfo extends LightningElement {

    @api recordId;
    isLoading = false;
    reassignmentData = [];

    connectedCallback() {
        this.getReassignmentInfo();
    }

    getReassignmentInfo() {
        this.isLoading = true;
        getAssetReassignmentInfo({
            'recordId': this.recordId
        }).then(result => {
            console.log('result-->'+JSON.stringify(result));
            if(result) {
                if(result.isError) {
                    this.reassignmentData = [];
                    this.showToast('Equipment Reassignment', 'Equipment will be not be reassigned from the Inventory', 'success');
                } else if(result.isError === false && result.data && result.data.length > 0) {
                    this.reassignmentData = result.data;
                    this.showToast('Equipment Reassignment', 'Equipment will be reassigned from the Inventory', 'success');
                } else {
                    this.reassignmentData = [];
                }
            }            
            this.isLoading = false;
        }).catch(error => {
            this.showToast('ERROR', error.message || error.body.message, 'error');
            this.isLoading = false;
        });
    }

    handleRefresh() {
        this.getReassignmentInfo();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant
        });
        this.dispatchEvent(event);
    }
}