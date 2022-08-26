import {
    LightningElement,
    track
} from 'lwc';
import getCasesFromAccount from '@salesforce/apex/AssessorResult.getCasesFromAccount';
import getProfileName from '@salesforce/apex/AssessorResult.getProfileName';
import {
    NavigationMixin
} from 'lightning/navigation';

export default class NC_AcceptInvitations extends NavigationMixin(LightningElement) {

    @track caseList;
    @track showCase = false;
    @track Assessor = false;
    connectedCallback() {
        this.getvalues();
    }
    getvalues() {
        getCasesFromAccount({})
            .then(res => {
                //let result=res;
                if (res.length == 0) {
                    this.showCase = false;
                } else {
                    this.showCase = true;
                }
                this.caseList = [];
                for (let i = 0; i < res.length; i++) {
                    this.caseList.push(res[i]);
                }
            }).catch(error => {
                console.error(error);
            });

        getProfileName()
            .then((result) => {
                console.log('test ' + JSON.stringify(result));
                this.Profile = result;
                if (this.Profile == 'NDBEDP Assessor') {
                    this.Assessor = true;
                } else {
                    this.Assessor = false;
                }
            })
            .catch((error) => {
                let message = error.message || error.body.message;
            });
    }
    getInvitation(event) {
        console.log('event.target.Id', event.target.dataset.value);
        let usedInCommunity = false;
        if (location.href.indexOf('/s/') > 0) {
            usedInCommunity = true;
        }
        if (usedInCommunity) {
            // this[NavigationMixin.Navigate]({
            //     type: 'comm__namedPage',
            //     attributes: {
            //         name: 'AssessorAcceptance__c'
            //     },
            //     state: {
            //         Id: event.target.dataset.value
            //     }
            // });
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.dataset.value,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.dataset.value,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
        }
    }
}