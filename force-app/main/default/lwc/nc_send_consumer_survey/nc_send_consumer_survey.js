import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createSurveyInvitaions from '@salesforce/apex/NC_SendConsumerSurvey.createSurveyInvitaions';



export default class Nc_send_consumer_survey extends NavigationMixin(LightningElement) {
  @api recordId;

  @track showSpinner;
  @track whereClause = ' Email != NULL ';
  @track resetTable = false;
  @track reloadTable = false;
  @track recordIdValue = '';
  @track selectedIdList = [];
  @track recordIdList = [];
  @track objData = {};
  @track showDetailsForConfirmation = false;

  @track columnsList = [
    { label: 'Consumer', name: 'Name', type: 'text', action: 'navigateToContact', isSearchable: true , isSortable: true },
    { label: 'Email', name: 'Email', type: 'text', action: '', isSearchable: true , isSortable: true },
    { label: 'Region', name: 'Region__c', type: 'text', action: '', isSearchable: true , isSortable: true },
    { label: 'County', name: 'County__c', type: 'text', action: '', isSearchable: true , isSortable: true },
    { label: 'Reginal Center Office', name: 'Regional_Center_Office__r.Name', type: 'text', action: '', isSearchable: true , isSortable: true },
    { label: 'Hearing Status', name: 'Hearing_Disability__c', type: 'text', action: '', isSearchable: true , isSortable: true },
  ];

  resetFlag(event) {
    // this.resetTable = event.detail;
  }

  connectedCallback() {
  }

  handlePaginatorAction(event) {
    let data = event.detail;
    if (data.actionName == 'navigateToContact') {
      if (data.recordId) {
        this.navigateToViewObjectPage(data.recordId, 'Contact');
      }
    }
  }

  updateSelectedValueList(event) {
    let data = event.detail;
    console.log('data -', JSON.stringify(data));
    if (data.selectedRecordId) {
      this.selectedIdList = data.selectedRecordId;
    }
    console.log('data -', JSON.stringify(this.selectedIdList));
  }

  handleSurveySend(){
    if(this.selectedIdList.length == 0){
      this.showToastMessage("Error!", 'Select atleast one contact to send survey!', "error");
    }else{
      this.showDetailsForConfirmation = true;
    }
  }

  closeModal() {
    this.showDetailsForConfirmation = false;
    this.dispatchEvent(new CustomEvent('refresh'));
  }

  handleSave(){
    this.createSurveyInvitaion();
  }
  
  handleInputChange(event){
    if(event.target.type == 'checkbox'){
      this.objData[event.target.name] = event.target.checked;
    }else{
      this.objData[event.target.name] = event.target.value;
    }
    console.log('this.objData - ', JSON.stringify(this.objData));
  }

  //As soon as survey invitation will be create Process builder will send it to consumer
  createSurveyInvitaion(){
      this.showSpinner = true;
      createSurveyInvitaions({ recordId: this.recordId, contactIds : this.selectedIdList ,data : this.objData}).then(
        result => {
          if(result.success){
            this.showToastMessage("Success!", 'Survey sended successfully!', "success");
          }
          this.showDetailsForConfirmation = false;
          this.selectedIdList = [];
          this.dispatchEvent(new CustomEvent('refresh'));
          this.showSpinner = false;
        }).catch(
          error => {
            this.showErrorToastAndConsole(error);
            this.showDetailsForConfirmation = false;
            this.showSpinner = false;
      });
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

  // for showing toast message
  showToastMessage(title, message, variant) {
    const event = new ShowToastEvent({
      "title": title,
      "message": message,
      "variant": variant,
    });
    this.dispatchEvent(event);
  }

  // navigate to view page
  navigateToViewObjectPage(recordId, objectApiName) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        objectApiName: objectApiName,
        actionName: 'view'
      },
    });
  }
}