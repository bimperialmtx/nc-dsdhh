import { LightningElement, track } from 'lwc';
import getSubmittedRecords from '@salesforce/apex/NC_ItemsToApproveController.getSubmittedRecords';
import processRecords from '@salesforce/apex/NC_ItemsToApproveController.processRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import NC_DSDHH_Resource from '@salesforce/resourceUrl/NC_DSDHH_Resource';

const columns = [
    {
        label : 'Name',
        fieldName : 'recordId',
        type : 'url',
        typeAttributes : {label:{fieldName:'recordName'},target:'_blank'}
    },
    {
        label : 'Related to',
        fieldName : 'relatedTo',
        type : 'text'
    },
    {
        label : 'Submitted by',
        fieldName : 'submittedBy',
        type : 'text'
    },
    {
        label : 'Submitted date',
        fieldName : 'submittedDate',
        type : 'date',
        //typeAttributes : {year:"2-digit",month:"short",day:"2-digit"}
    }
];

export default class nc_itemsToApprove extends LightningElement {
    
    isRequestPending;
    columns = columns;
    data = [];
    showSpinner = false;
    toastMessage;

    connectedCallback() {
        this.getPendingRequest();
        loadStyle(this, NC_DSDHH_Resource + '/styles/a11y.css');
    }

    getPendingRequest() {
        this.isRequestPending = false;
        getSubmittedRecords({}).then(result => {
            if(result) {
                console.log('result-->'+JSON.stringify(result));
                result.forEach(function(record){
                    record.recordId = '/'+record.recordId;
                });
                this.data = result;
                this.isRequestPending = this.data && this.data.length > 0 ? true : false;
            }
        }).catch(error => {
            this.showToast('ERROR', error.message || error.body.message, 'error');
        });
    }

    handleApproveAction() {
        this.approveRejectAction('Approve');
    }

    handleRejectAction() {
        this.approveRejectAction('Reject');
    }

    approveRejectAction(processType) {
        this.showSpinner = true;
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecords-->'+JSON.stringify(selectedRecords));

        if(selectedRecords && selectedRecords.length > 0) {
            var workItemIds = [];
            for(var i in selectedRecords) {
                workItemIds.push(selectedRecords[i].workItemId);
            }
            processRecords({
                'lstWorkItemIds': workItemIds,
                'processType': processType
            }).then(result => {
                if(result && result.includes('success')) {
                    this.showToast('Success', result, 'success');
                    this.getPendingRequest();
                } else {
                    this.showToast('Error', result, 'error');
                }
                this.showSpinner = false;
            }).catch(error => {
                this.showToast('Error', error.message || error.body.message, 'error');
                this.showSpinner = false;
            });
        } else {
            this.showToast('Error', 'Select a record to proceed', 'error');
            let dataId = processType === 'Approve' ? 'approveButton' : 'rejectButton';
            this.setDataIdFocus(dataId);
            this.toastMessage = 'Select a record to proceed';
            this.resetErrorMessage();
            this.showSpinner = false;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant
        });
        this.dispatchEvent(event);
    }

    setDataIdFocus(dataId) {
        setTimeout(() => {
            let element = this.template.querySelector('[data-id="'+dataId+'"]');
            if(element) {
                element.focus();
            }
        }, 500);
    }

    resetErrorMessage() {
        setTimeout(() => {
            this.toastMessage = '';
        }, 10000);
    }
}