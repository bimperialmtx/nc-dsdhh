import { LightningElement,wire,api,track } from 'lwc';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import REQUEST_AUDIENCE from '@salesforce/schema/Case.Request_Audience__c';
import REQUEST_TYPE from '@salesforce/schema/Case.Request_Type__c';
import REQUEST_SUBTYPE from '@salesforce/schema/Case.Request_Sub_type__c';
import CONTACT_ID from '@salesforce/schema/Case.ContactId';
import RECORDTYPE_ID from '@salesforce/schema/Case.RecordTypeId';
import PARENT_NDBEDP from '@salesforce/schema/Case.Parent_NDBEDP__c';
import saveData from '@salesforce/apex/nc_ServiceRequest.saveData';
import getParentCaseNumber from '@salesforce/apex/nc_ServiceRequest.getParentCaseNumber';
import getParentCaseNumberId from '@salesforce/apex/nc_ServiceRequest.getParentCaseNumberId';
import checkNDBEDP from '@salesforce/apex/nc_ServiceRequest.checkNDBEDP';
import { NavigationMixin } from 'lightning/navigation';
import {
    ShowToastEvent
  } from 'lightning/platformShowToastEvent';

export default class Nc_CreateServiceRequest extends NavigationMixin(LightningElement) {
        @api recordId;
        @track requestObj = {};
        @track usedInCommunity;
        @track consumerName;
        @track parentCase;
        @track showModel = false;
        @track contactIdExisting;
        @track requestAudience ='Consumer';
        @track requestType ='NDBEDP';
        @track options=[{label:'Follow-up', value:'Follow-up'},
                        {label:'Additional Part',value:'Additional Part'},
                        {label:'Repair Request',value:'Repair Request'},
                        {label:'Additional Training',value:'Additional Training'}];
        @track parentOptions;   
        @track audienceOptions=[{label:'Consumer', value:'Consumer'}];    
        @track typeOptions=[{label:'NDBEDP', value:'NDBEDP'}];  
        connectedCallback(){
          this.setDataIdFocus('close');
          if (location.href.indexOf('/s/') > 0) {
            this.usedInCommunity = true;
        } else {
            this.usedInCommunity = false;
        }
          checkNDBEDP({recordId: this.recordId})
          .then(res => {
            console.log('res',JSON.stringify(res));
            if(!res){
              this.showModel= res;
              this.showToastMessage('Error', 'You cannot create a service Request.', 'Error');
              let value = true;
                  const valueChangeEvent = new CustomEvent("valuechange", {
                    detail: {
                      value
                    }
                  });
                  this.dispatchEvent(valueChangeEvent);
            }
          }).catch(error => {
            this.showToastMessage('Error', " You're not allowed to create service request. Contact Administartor.", 'Error');
          });
        //  console.log('tes');
        }       
  //    @wire(checkNDBEDP,{recordId: '$recordId'})
  //    checkNDBEDP({ data, error }) {
  //      if(data){
  //       this.showModel = data;
  //      }
  //      if(error){
  //          console.error(error);
  //      }
  //  }
   @wire(getParentCaseNumber,{recordId: '$recordId'})
   getParentCaseNumber({ data, error }) {
     if(data){
       this.parentOptions= [{label:data, value:data}];
       this.requestObj.parentName= data;
      // this.requestObj.parentId = data.Id;
        console.log('this.requestObj.parentId',this.requestObj.parentId);
     }
     if(error){
         console.error(error);
     }
 }

 @wire(getParentCaseNumberId,{recordId: '$recordId'})
 getParentCaseNumberId({ data, error }) {
   if(data){
     this.requestObj.ContactId = data.ContactId;
      console.log('this.requestObj.parentId',this.requestObj.parentId);
   }
   if(error){
       console.error(error);
   }
}

        handleChange(event){
            this.requestObj[event.target.name] = event.target.value;
        }

        handleSave() {
            const allValid = [...this.template.querySelectorAll('lightning-combobox')]
              .reduce((validSoFar, inputCmp) => {
                          inputCmp.reportValidity();
                          if(inputCmp.checkValidity() === false && validSoFar === true) {
                            this.setFocusOnError(inputCmp);
                          }
                          return validSoFar && inputCmp.checkValidity();
              }, true);
          if (allValid) {
      
              this.requestObj.parentCaseId = this.recordId;
              this.requestObj.requestAudience = this.requestAudience;
              this.requestObj.requestType = this.requestType;
              console.log('this.requestObj',JSON.stringify(this.requestObj));
              this.showSpinner=true;
          
              saveData({
                  dataObj: JSON.stringify(this.requestObj)
                })
                .then(res => {
                  this.newCaseId = res.Id;
                  console.log('newCaseId',this.newCaseId);
                  this.showSpinner=false;
                  this.showToastMessage('success', 'Request saved Sucessfully', 'success');
                  let value = true;
                  const valueChangeEvent = new CustomEvent("valuechange", {
                    detail: {
                      value
                    }
                  });
                  // Fire the custom event
                  this.navigateToRecordPage();
                  this.dispatchEvent(valueChangeEvent);
                }).catch(error => {
                  let message=error.message||error.body.message;
                 // console.log('message+++++',message);
                  this.showToastMessage('error',message , 'error');
                  this.showSpinner=false;
                });
      
          
          
          } 
      }

      navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.newCaseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
      }
      showToastMessage(title, message, variant) {
        const event = new ShowToastEvent({
          "title": title,
          "message": message,
          "variant": variant,
        });
        this.dispatchEvent(event);
      }
       
        
        cancelEvent(){
            let value = true;
            const valueChangeEvent = new CustomEvent("valuechange", {
              detail: {
                value
              }
            });
            // Fire the custom event
            this.dispatchEvent(valueChangeEvent);
          }

          setDataIdFocus(dataId) {
            setTimeout(() => {
              let closeButton = this.template.querySelector('[data-id="' + dataId + '"]');
              if (closeButton) {
                closeButton.focus();
              }
            }, 500);
          }

          setFocusOnError(inputCmp) {
            setTimeout(() => {
                inputCmp.focus();
            }, 100);
          }
}