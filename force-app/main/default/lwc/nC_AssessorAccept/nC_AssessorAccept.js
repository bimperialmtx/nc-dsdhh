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
import getProfileName from '@salesforce/apex/AssessorResult.getProfileName';
export default class NC_AssessorAccept extends LightningElement {

   
    @track result;
    @track recordIdValue;
    @track caseNumber;
    @track wrongRequest;
    @track response =false;
    @track responseCaptured =false;
    @track requestURL;
    @api recordId;
    @track Assessor=false;

    label = {
        Site_Base_URL
    };


    connectedCallback() {
       
        //let url = new URL(window.location.href);
        //let recordId = url.searchParams.get("Id");
        // this.recordIdValue= url.searchParams.get("Id");
        
        this.recordIdValue=this.recordId;
       if(this.recordIdValue!=null){
        //this.requestURL=window.location.origin+'/'+recordId;
        console.log('this.recordIdValue 2',this.recordIdValue);
        this.checkAssessorUser();
        this.getCase();
        this.getCaseNumbers();
        
     }
    }
    getCase(){
        getAssessorResult({requestId:this.recordIdValue})
        .then(res => {
            console.log('res11',res);
            this.response=res;
            this.responseCaptured = res;
        })
        .catch(error => {
            console.log(error);
        });

        getProfileName()
        .then((result) => {
            console.log('test '+JSON.stringify(result));
            this.Profile = result;
            if(this.Profile=='NDBEDP Assessor'){
                this.Assessor=true;
            }
            else{
                this.Assessor=false;
            }
        })
        .catch((error) => {
            let message = error.message || error.body.message;
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
            console.log('res',res);
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
            this.setDataIdFocus('messageDiv');
            console.log('res',res);
    })
    .catch(error => {
        console.log(error);
    });
        
            // const fields = {};
            // fields[ID_FIELD.fieldApiName] = this.recordIdValue;
            // fields[ASSESSOR_RESULT.fieldApiName] = this.result;
            // const recordInput = { fields };
            // updateRecord(recordInput)
            //     .then(() => {
            //         this.dispatchEvent(
            //              new ShowToastEvent({
            //             title: 'Success',
            //             message: 'Result Recorded',
            //             variant: 'success'
            //         })
            //     );
            // })
            // .catch(error => {
            //     console.log(error);
            // });
        }
    
    setDataIdFocus(dataId) {
        setTimeout(() => {
            let element = this.template.querySelector('[data-id="'+dataId+'"]');
            if(element) {
                element.focus();
            }
        }, 500);
    }
}