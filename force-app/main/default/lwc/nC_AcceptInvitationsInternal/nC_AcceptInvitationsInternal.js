import { LightningElement,api,track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Case.Id';
import ASSESSOR_RESULT from '@salesforce/schema/Case.Assessor_Result__c';
import assessorResult from '@salesforce/apex/AssessorResult.assessorResult';
import getAssessorResult from '@salesforce/apex/AssessorResult.getAssessorResult';
import Site_Base_URL from '@salesforce/label/c.Site_Base_URL';
import getCaseNumber from '@salesforce/apex/AssessorResult.getCaseNumber';
import checkAssessor from '@salesforce/apex/AssessorResult.checkAssessor';

export default class NC_AcceptInvitationsInternal extends NavigationMixin(LightningElement) {
    @track result;
    @track recordIdValue;
    @track caseNumber;
    @track wrongRequest;
    @api recordId;
    @track response =false;
    label = {
        Site_Base_URL
    };


    connectedCallback() {
       
        let url = new URL(window.location.href);
       // let recordId =  url.searchParams.get("assessor");
        this.recordIdValue= url.searchParams.get("Id") ;
       // let
        console.log('this.record',this.recordId);
      //  console.log('this.recordIdValue',this.recordIdValue);
       // if(this.recordIdValue == null){
            this.recordIdValue=this.recordId;
      //  }
        this.checkAssessorUser();
        this.getCase();
        this.getCaseNumbers();
    }
    getCase(){
        console.log('this.recordIdValue',this.recordIdValue);
        getAssessorResult({requestId:this.recordIdValue})
        .then(res => {
            console.log('res11',res);
            this.response=res;
        })
        .catch(error => {
            console.log(error);
        });
    }
    getCaseNumbers(){
        getCaseNumber({requestId:this.recordIdValue})
        .then(res => {
            this.caseNumber=res;
        }).catch(error =>{
            console.error(error);
        })
    }

    checkAssessorUser(){
        checkAssessor({requestId:this.recordIdValue})
        .then(res => {
            this.wrongRequest=res;
        })
        .catch(error => {
            console.log(error);
        });
    }
    handleClick(event){
        this.result=event.target.name;
        console.log('this.result',this.result);
        this.updateCase();
    }
    updateCase(){
        assessorResult({requestId:this.recordIdValue,assesserResult:this.result})
        .then(res => {
            this.response=true;
            console.log('res',res);
    })
    .catch(error => {
        console.log(error);
    });
}
    
}