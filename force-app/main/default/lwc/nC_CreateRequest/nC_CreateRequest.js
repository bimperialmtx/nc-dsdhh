import { LightningElement,api,track ,wire} from 'lwc';
import saveData from '@salesforce/apex/NC_Request.saveData';

import getConsumerName from '@salesforce/apex/NC_Request.getConsumerName';
import getRecordTypeId from '@salesforce/apex/NC_Request.getRecordTypeId';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import {
    ShowToastEvent
  } from 'lightning/platformShowToastEvent';

export default class NC_CreateRequest extends NavigationMixin(LightningElement) {
    @api recordId;
    @track newCaseId;
    @track requestObj = {};
    @track consumerName;
    @track showSpinner=false;
    @track showEquipmentTypes=false;
    @track requestStatus;
    @track recordTypeId;
    @track consumerValue ='Consumer';
    @track options=[{label:'EDS', value:'EDS'},
                   {label:'NDBEDP',value:'NDBEDP'}];
            
    connectedCallback(){
      this.setDataIdFocus('close');
       this.consumerValue='Consumer';
        console.log('this.recordId',this.recordId);
        // fetchPicklist({
        //     objectName: "Case",
        //     fieldName: "Equipment_Types__c"
        //   })
        //   .then(res => {
        //     this.picklistOptions = res;
        //     console.log('picklist', JSON.stringify(this.picklistOptions));
        //   }).catch(error => {
        //     console.error(error);
        //   });
          getRecordTypeId({
            requestRecordTypeName :'Equipment'
          })
          .then(res => {
            this.recordTypeId = res;
            console.log('recordTypeId', this.recordTypeId);
          }).catch(error => {
            console.error(error);
          });
    getConsumerName({
            contactId: this.recordId
          })
          .then(res => {
            this.consumerName = res.Name;
            this.requestObj.consumerName=res.Name;
            if(res.EDS && res.NDBEDP){
              this.options=[{label:'EDS', value:'EDS'},
                   {label:'NDBEDP',value:'NDBEDP'}];
            }
            else if(res.EDS){
              this.options=[{label:'EDS', value:'EDS'}];
            }
            else if(res.NDBEDP){
              this.options=[{label:'NDBEDP', value:'NDBEDP'}];
            }
          }).catch(error => {
            console.error(error);
          });
          
      }
      @wire(getPicklistValuesByRecordType, { objectApiName: 'Case', recordTypeId: '$recordTypeId' }) 
      IndustryPicklistValues({error, data}) {
          if(data) {
           // console.log('data',data);
              this.picklistOptions = data.picklistFieldValues.Equipment_Types__c.values;
          }
          else if(error) {
              window.console.log('error =====> '+JSON.stringify(error));
          }
      }
    handleChange(event){
        this.requestObj[event.target.name] = event.target.value;
        if(event.target.name == 'requestType'){
          if( event.target.value == 'EDS'){
          this.showEquipmentTypes =true;
        }
        else{
          this.showEquipmentTypes =false;
          this.requestObj.EquipmentTypes=null;
        }
      }
    }
   // handleSave()
    handleSave() {
      const allValid = [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    if(inputCmp.checkValidity() === false && validSoFar === true) {
                      this.setFocusOnError(inputCmp);
                    }
                    return validSoFar && inputCmp.checkValidity();
        }, true);
      const allValid1 = [...this.template.querySelectorAll('lightning-dual-listbox')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    if(inputCmp.checkValidity() === false && validSoFar === true) {
                      this.setFocusOnError(inputCmp);
                    }
                    return validSoFar && inputCmp.checkValidity();
        }, true);
    if (allValid && allValid1) {
       // alert('All form entries look valid. Ready to submit!');

        this.requestObj.contactId = this.recordId;
        console.log('this.requestObj',JSON.stringify(this.requestObj));
        this.showSpinner=true;
    
        saveData({
            dataObj: JSON.stringify(this.requestObj)
          })
          .then(res => {
           // console.log('res',JSON.stringify(res));
            for(var key in res){
              this.requestStatus = res[key];
              this.newCaseId = key;
              // console.log('key',JSON.stringify(key));
              // console.log('val',JSON.stringify(res[key]));
            }
            if(this.requestStatus){
           // this.newCaseId = res.Id;
            this.navigateToRecordPage();
            //console.log('newCaseId',this.newCaseId);
           this.showToastMessage('success', 'Request saved Sucessfully', 'success');
            }
            else{
              this.showToastMessage('Error', 'An NDBEDP Request is inProgress', 'Error');
            }
            // console.log('res',JSON.stringify(res.));
            // console.log('res',JSON.stringify(res[1]));
            this.showSpinner=false;
            
            let value = true;
            const valueChangeEvent = new CustomEvent("valuechange", {
              detail: {
                value
              }
            });
            // Fire the custom event
            // this.navigateToRecordPage();
            this.dispatchEvent(valueChangeEvent);
          }).catch(error => {
            let message=error.message||error.body.message;
            if(message.includes('Regional center is required on related consumer record')){
              message=' Regional center is required on related consumer record.';
            }
            this.showToastMessage('error',message , 'error');
            this.showSpinner=false;
          });

    
    
    } 
}
    
      showToastMessage(title, message, variant) {
        const event = new ShowToastEvent({
          "title": title,
          "message": message,
          "variant": variant,
        });
        this.dispatchEvent(event);
      }

      navigateToRecordPage() {
        console.log('test');
        console.log('test',this.newCaseId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.newCaseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
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