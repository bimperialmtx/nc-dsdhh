import {
    LightningElement,
    track,
    api
} from 'lwc';
import getUserList from '@salesforce/apex/NC_StaffInvitationComponentController.fetchUserList';
import sendEmailTouser from '@salesforce/apex/NC_StaffInvitationComponentController.sendEmailInviation';
import fetchCountRegionalCenter from '@salesforce/apex/NC_StaffInvitationComponentController.fetchCountRegionalCenter';


import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class Nc_staff_invitation_component extends LightningElement {

    @track userList;
    @track oldUserList;
    @api recordId;
    @track searchInput;
    @track isExternalRecord;
    @track isInterpreter;
    @track isNDBEDPTraining;
    @track countyOptionList = [];
    @track regionalCenterOptionList = [];

    @track LicenceTypeList = [];
    @track SpecialityList = [];

    @track regionalCenterSelected = 'All';
    @track countySelected = 'All';
    @track LicenceTypeSelected = 'All';
    @track SpecialitySelected = 'All';
    @track showSpinner = false;

    get sendInvitationDivClass() {
        if(this.isNDBEDPTraining) {
            return 'slds-col slds-size_1-of-1 slds-medium-size_2-of-4 slds-large-size_2-of-4 slds-float_right slds-p-top_small slds-m-top_x-small';
        } else {
            return 'slds-col slds-size_1-of-1 slds-medium-size_2-of-4 slds-large-size_2-of-4 slds-float_right';
        }
    }

    connectedCallback() {
        this.showSpinner = true;
        fetchCountRegionalCenter({
            'recordId': this.recordId
        }).then(
            result => {
                if (result.countyOptionList) {
                    this.countyOptionList = result.countyOptionList
                }
                if (result.regionalCenterOptionList) {
                    this.regionalCenterOptionList = result.regionalCenterOptionList
                }
                if (result.SpecialityList) {
                    this.SpecialityList = result.SpecialityList
                }
                if (result.LicenceTypeList) {
                    this.LicenceTypeList = result.LicenceTypeList
                }
                if (result.isNDBEDPTraining) {
                    this.isNDBEDPTraining = result.isNDBEDPTraining;
                }
            }
        ).catch(
            error => {
                this.showToastMessage("Error!", error, "error");
            }
        );

        this.getUserListData();

        this.showSpinner = false;
    }

    getUserListData() {
        this.showSpinner = true;
        getUserList({
            recordId: this.recordId,
            regionalCenter: this.regionalCenterSelected,
            County: this.countySelected,
            licenseType: this.LicenceTypeSelected,
            speciality: this.SpecialitySelected
        }).then(
            result => {
                if (result.error) {
                    this.userList = [];
                    this.oldUserList = this.userList;
                    this.showToastMessage("Error!", result.error, "error");
                } else {
                    this.userList = result.result;
                    this.oldUserList = this.userList;
                }
                this.isExternalRecord = result.isExternalRecord;
                this.isInterpreter = result.isInterpreter;

            }
        ).catch(
            error => {
                this.showToastMessage("Error!", error, "error");
            }
        );
        this.showSpinner = false;
    }

    handleRefresh() {
        this.regionalCenterSelected = 'All';
        this.countySelected = 'All';
        this.LicenceTypeSelected = 'All';
        this.SpecialitySelected = 'All';
        this.getUserListData();
    }

    handlePicklistChnage(event) {
        if (event.target.name == 'RegionalCenter') {
            this.regionalCenterSelected = event.target.value;
        } else if (event.target.name == 'County') {
            this.countySelected = event.target.value;
        } else if (event.target.name == 'LicenseType') {
            this.LicenceTypeSelected = event.target.value;
        } else if (event.target.name == 'Speciality') {
            this.SpecialitySelected = event.target.value;
        }

        console.log(event.target.value);
        this.getUserListData();
    }

    updateAll(event) {
        this.userList = this.userList.map(element => {
            element.isSelected = event.target.checked;
            return element;
        });
    }

    updateList(event) {
        let sampleList = [];
        this.searchInput = event.target.value.trim().toLowerCase();
        console.log('this.searchInput -- ' + this.searchInput);
        if (this.searchInput === '' || this.searchInput === undefined || this.searchInput === null) {
            this.userList = this.oldUserList;
        } else {
            for (let i = 0; i < this.oldUserList.length; i++) {
                console.log('this.oldUserList[i].userName -- ' + this.oldUserList[i].userName.toLowerCase());
                console.log('result -- ' + this.oldUserList[i].userName.toLowerCase().startsWith(this.searchInput));
                console.log('this.oldUserList[i].emailId -- ' + this.oldUserList[i].emailId);
                if (this.oldUserList[i].userName.toLowerCase().startsWith(this.searchInput) ||
                    ((this.oldUserList[i].emailId) && this.oldUserList[i].emailId.toLowerCase().startsWith(this.searchInput))) {
                    sampleList.push(this.oldUserList[i]);
                }
            }
            this.userList = sampleList;
        }
    }


    updateSelected(event) {
        this.userList = this.userList.map(element => {
            if (element.userId === event.target.name) {
                element.isSelected = event.target.checked;
            }
            return element;
        });
    }

    handleNumberChange(event) {
        /*
         for(var i=0; i < this.userList.length; i++){
           if(element.userId  === event.target.name){
             this.userList[i].numberOfMembersProving = event.target.value;
           }
         }
         */
        this.userList = this.userList.map(element => {
            if (element.userId === event.target.name) {
                element.numberOfMembersProving = Number(event.target.value);
            }
            return element;
        });
    }


    sendInvitation() {
        this.showSpinner = true;
        if(this.isNDBEDPTraining) {
            var selectedCount = 0;
            for(var i in this.userList) {
                this.userList[i].numberOfMembersProving = 1;
                if(this.userList[i].isSelected) {
                    selectedCount++;
                }
            }
            if(selectedCount == 0) {
                this.showToastMessage("Error!", "Select one NDBEDP Trainer to proceed", "error");
                this.showSpinner = false;
                this.setFocusOnCheckBox();
                return;
            } else if(selectedCount > 1) {
                this.showToastMessage("Error!", "Select only one NDBEDP Trainer", "error");
                this.showSpinner = false;
                this.setFocusOnCheckBox();
                return;
            }
        }
        sendEmailTouser({
            userdata: JSON.stringify(this.userList),
            recordId: this.recordId
        }).then(
            result => {
                if (result.error) {
                    this.showToastMessage("Error!", result.error, "error");
                    this.setFocusOnCheckBox();
                } else if (result.warning) {
                    this.showToastMessage("Warning!", result.warning, "warning");
                } else {
                    this.showToastMessage("Success!", result.success, "success");
                    this.dispatchEvent(new CustomEvent("refresh"));
                }
                this.showSpinner = false;
            }
        ).catch(
            error => {
                this.showToastMessage("Error!", error, "error");
                this.showSpinner = false;
            }
        );
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

    setFocusOnCheckBox() {
        setTimeout(() => {
            let checkBoxes = this.template.querySelectorAll("[data-id='checkBoxId']");
            checkBoxes[0].focus();
        }, 500);
    }
}