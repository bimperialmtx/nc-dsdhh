import { LightningElement,api, track } from 'lwc';
import getPicklistValues from '@salesforce/apex/NC_LwcCustomPathController.getPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class NC_LwcCustomPath extends LightningElement {

  @api fieldApiName;
  @api recordId;
  @api recordTypesNames;
  @api seeSuccessSate;
  @track steps = [];
  @track completedCssClass = 'slds-path__item slds-is-complete';

  connectedCallback() {
      getPicklistValues({fieldApiName : this.fieldApiName, 
                         recordId : this.recordId, 
                         recordTypesNames : this.recordTypesNames}).then(
          result=>{
            this.steps = result;
          }
      ).catch(
          error=>{
            this.showErrorToastAndConsole(error);
          }
      );
      this.completedCssClass = this.seeSuccessSate ? this.completedCssClass : 'slds-path__item slds-is-incomplete';
  }

    // show error
  showErrorToastAndConsole(error) {
      console.log('error :', JSON.stringify(error));
      if (error && error.body && error.body.pageErrors && error.body.pageErrors.length > 0 && error.body.pageErrors[0].message) {
        this.showToastMessage("Error!", error.body.pageErrors[0].statusCode + ' : ' + error.body.pageErrors[0].message, "error");
      } else if(error && error.body && error.body.fieldErrors && error.body.fieldErrors[Object.keys(error.body.fieldErrors)].length > 0 && error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].statusCode && error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].message){
        this.showToastMessage("Error!", error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].statusCode + ' : ' + error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].message , "error");
      } else {
        this.showToastMessage("Error!", JSON.stringify(error), "error");
      }
  }
  //for showing toast message
  showToastMessage(title, message, variant) {
    const event = new ShowToastEvent({
        "title": title,
        "message": message,
        "variant": variant,
    });
    this.dispatchEvent(event);
}
}