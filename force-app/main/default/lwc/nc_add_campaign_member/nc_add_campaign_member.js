import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createCampaignMember from '@salesforce/apex/NC_CampaignMemberController.createCampaignMember';
import getCampgaignMember from '@salesforce/apex/NC_CampaignMemberController.getCampgaignMember';



export default class Nc_add_campaign_member extends NavigationMixin(LightningElement) {
  @api recordId;

  @track showSpinner;
  @track whereClause = ' DSDHH_Mailing_List__c = true ';
  @track campaignRecord = {};
  @track resetTable = false;
  @track reloadTable = false;
  @track recordIdValue = '';
  @track selectedIdList = [];
  @track recordIdList = [];
  @track showComponent = false;

  @track columnsList = [
    { label: 'Consumer', name: 'Name', type: 'text', action: 'navigateToContact', isSearchable: true, isSortable: true },
    { label: 'Email', name: 'Email', type: 'text', action: '', isSearchable: true, isSortable: true },
    { label: 'Communications Type', name: 'Communications_Type__c', type: 'text', action: '', isSearchable: true, isSortable: false },
    { label: 'Region', name: 'Region__c', type: 'text', action: '', isSearchable: true, isSortable: true },
    { label: 'County', name: 'County__c', type: 'text', action: '', isSearchable: true, isSortable: true },
    { label: 'Reginal Center Office', name: 'Regional_Center_Office__r.Name', type: 'text', action: '', isSearchable: true, isSortable: true },
    { label: 'Hearing Status', name: 'Hearing_Disability__c', type: 'text', action: '', isSearchable: true, isSortable: true },
  ];

  resetFlag(event) {
    // this.resetTable = event.detail;
  }

  connectedCallback() {
   this.getInitials();
  }

  getInitials(){
    this.showComponent = false;
    this.showSpinner = true;
    getCampgaignMember({ recordId: this.recordId }).then(
      result => {
        if(result.contactList){
            this.recordIdList = result.contactList;
            this.whereClause = this.whereClause + ' AND Id NOT IN: recordIdList ';
        }
        if(result.campaignRecord){
          this.campaignRecord = result.campaignRecord;
          if(this.campaignRecord.Regional_Center_Office__c != undefined && this.campaignRecord.Regional_Center_Office__c !=  'Home Office'){
            this.whereClause = this.whereClause + ' AND Regional_Center_Office__r.Name = ' + '\'' + this.campaignRecord.Regional_Center_Office__c + '\' ';
          }
          if(this.campaignRecord.Communications_Type__c != undefined){
            this.whereClause = this.whereClause + ' AND Communications_Type__c INCLUDES ' + '(\'' + this.campaignRecord.Communications_Type__c + '\') ';
          }
        }
        this.showComponent = true;
        this.showSpinner = false;
      }).catch(
        error => {
          this.showErrorToastAndConsole(error);
          this.showSpinner = false;
    });
  }

  handlePaginatorAction(event) {
    let data = event.detail;
    if (data.actionName == 'navigateToContact') {
      if (data.recordId) {
        this.navigateToViewObjectPage(data.recordId, 'Contact');
      }
    }
  }

  handleAddToCampaign(){
    if(this.selectedIdList.length == 0){
      this.showToastMessage("Error!", 'Select atleast one contact to add!', "error");
    }else{
      this.showSpinner = true;
      createCampaignMember({ recordId: this.recordId, contactIds : this.selectedIdList }).then(
        result => {
          if(result.success){
            this.showToastMessage("Success!", 'Members added to the campaign successfully!', "success");
          }
          this.getInitials();
          this.selectedIdList = [];
          this.dispatchEvent(new CustomEvent('refresh'));
          this.showSpinner = false;
        }).catch(
          error => {
            this.showErrorToastAndConsole(error);
            this.showSpinner = false;
      });
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