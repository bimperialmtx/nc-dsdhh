import { LightningElement,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import checkPermissions from '@salesforce/apex/NC_CommunicationAccessRequestHomeCtrl.checkPermissions';
import getRecordTypeId from '@salesforce/apex/NC_CommunicationAccessRequestHomeCtrl.returnRecordTypeId';
import getResourceLoanRecordTypeId from '@salesforce/apex/NC_CommunicationAccessRequestHomeCtrl.getResourceLoanRecordTypeId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NC_CreateCommunicationAccessRequestonHome extends NavigationMixin(LightningElement) {
    @track recordTypeId;
    @track isCreateCommunicationVisible = false;
    @track isCreateResourceLoanVisible = false;

    connectedCallback() {
      checkPermissions({}).then(result => {
          if (result) {
              if(result.isCommunicationCretable == true) {
                  this.isCreateCommunicationVisible = true;
              }
              if(result.isResourceLoanCretable == true) {
                  this.isCreateResourceLoanVisible = true;
              }
          }
      }).catch(error => {
          this.showToast('Error', error.message || error.body.message, 'error');
      });
    }

    handleClick(){
        // getRecordTypeId({}).then(res => {
        //     this.recordTypeId = res;
        //     console.log('id',JSON.stringify(res))
        //     this[NavigationMixin.Navigate]({
        //         type: 'standard__objectPage',
        //         attributes: {
        //             objectApiName: 'Communication_Access_Request__c',
        //             actionName: 'new'
        //         },
        //         state: {
        //             RecordTypeId: this.recordTypeId
        //         }
        //     });
        // }).catch(error => {
        //     console.error(error);
        // });
        this[NavigationMixin.Navigate]({
            type : 'standard__webPage',
            attributes: {
                url: '/lightning/o/Communication_Access_Request__c/new?nooverride=1&useRecordTypeCheck=1'
            }
        });
    }

    handleCreateResourceLoan() {

        this[NavigationMixin.Navigate]({
            type : 'standard__webPage',
            attributes: {
                url: '/lightning/o/Resource_Loan__c/new?nooverride=1&useRecordTypeCheck=1'
            }
        });
        /*
        getResourceLoanRecordTypeId({}).then(result => {
            if (result) {
                let resourceRecordTypeId = result;
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Resource_Loan__c',
                        actionName: 'new'
                    },
                    state: {
                        recordTypeId: resourceRecordTypeId
                    }
                });
            }
        }).catch(error => {
            this.showToast('Error', error.message || error.body.message, 'error');
        });*/
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