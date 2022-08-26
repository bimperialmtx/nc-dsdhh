import { LightningElement, track, api } from 'lwc';
import getEquipmentCategories from '@salesforce/apex/NC_ConnectEquipmentController.getEquipmentCategories';
import retrieveEquipments from '@salesforce/apex/NC_ConnectEquipmentController.retrieveEquipments';
import createEquipmentAndEquipmentRequest from '@salesforce/apex/NC_ConnectEquipmentController.createEquipmentAndEquipmentRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import NC_DSDHH_Resource from '@salesforce/resourceUrl/NC_DSDHH_Resource';

export default class NC_ConnectEquipment extends LightningElement {

    @api parentRecordId;
    @api isPortal = false;
    showSpinner = false;
    productData;
    @track
    categoryOptions = [];
    selectedCategory;
    @track
    equipmentResult = [];
    @track
    equipmentResultMaster = [];
    @track
    equipmentCategoryResult = []; 
    @track
    equipmentCategoryMap = {};
    @track
    equipmentCategoryList = [];
    equipmentCategoryMap = {};

    connectedCallback() {
        this.showSpinner = true;
        loadStyle(this, NC_DSDHH_Resource + '/styles/a11y.css');
        if(!this.parentRecordId) {
            this.parentRecordId = this.getUrlParamValue(window.location.href, 'parentRecordId');
            this.isPortal = this.getUrlParamValue(window.location.href, 'isPortal');
        }
        this.getEquipments();
    }

    handleConnectedCallback() {
        this.showSpinner = true;
        this.productData = null;
        this.selectedCategory = null;
        this.categoryOptions = [];
        this.equipmentResult = [];
        this.equipmentResultMaster = [];
        this.equipmentCategoryResult = [];
        this.equipmentCategoryMap = {};
        this.equipmentCategoryList = [];
        if(!this.parentRecordId) {
            this.parentRecordId = this.getUrlParamValue(window.location.href, 'parentRecordId');
            this.isPortal = this.getUrlParamValue(window.location.href, 'isPortal');
        }
        this.getEquipments();
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    getEquipments() {
        getEquipmentCategories({
            "requestId": this.parentRecordId
        }).then(result => {
            if(result) {
                console.log('equipmentCategoryMap-->'+result);
                if(result.errorMessage) {
                    var error = {};
                    error.message = result.errorMessage;
                    this.showErrorToast(error);
                    this.closeWindow();
                } else if(result.equipmentDetails) {
                    var equipmentDetails = result.equipmentDetails
                    for(var eqp in equipmentDetails) {
                        this.equipmentCategoryMap[eqp] = equipmentDetails[eqp].Equipment_Name__c;
                    }
                    this.fetchEquipments();
                }
            }
        }).catch(error => {
            this.showErrorToast(error);
            //this.closeWindow();
        });
    }

    fetchEquipments() {
        retrieveEquipments().then(result => {
            if(result) {
                this.equipmentResult = result.eqp.ttEqp;
                this.equipmentResultMaster = this.equipmentResult;
                this.categoryOptions.push({value: 'All', label: 'All Categories'});

                var categories = [];
                for(var i in this.equipmentResult) {
                    this.equipmentResult[i].isSelected = false;
                    this.equipmentResult[i].quantity = null;
                    var categoryCode = this.equipmentResult[i].Medcode;
                    if(this.equipmentCategoryMap[categoryCode] && !categories.includes(categoryCode)) {
                        categories.push(categoryCode);
                        this.categoryOptions.push({label: this.equipmentCategoryMap[categoryCode], value: categoryCode});   
                    }
                }
                this.selectedCategory = 'All';
                this.equipmentCategoryResult = this.equipmentResult;
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.showErrorToast(error);
            this.closeWindow();
        });
    }

    handleCategoryChange(event) {
        var selectedCategory = event.detail.value;
        this.selectedCategory = selectedCategory;
        if(selectedCategory && selectedCategory == 'All') {
            this.equipmentResult = this.equipmentResultMaster;
            this.equipmentCategoryResult = this.equipmentResult;
        } else if(selectedCategory) {
            var filterEquipments = [];
            for(var i in this.equipmentResultMaster) {
                if(this.equipmentResultMaster[i].Medcode == selectedCategory) {
                    filterEquipments.push(this.equipmentResultMaster[i]);
                }
            }
            this.equipmentResult = filterEquipments;
            this.equipmentCategoryResult = this.equipmentResult;
        }
    }

    handleEquipmentSearch(event) {
        var searchKey = event.target.value;
        searchKey = searchKey.replace(/\\/g, "\\\\");
        var searchResult = [];
        if(searchKey && searchKey.length > 2) {
            for(var i in this.equipmentCategoryResult) {
                if(this.equipmentCategoryResult[i].Titl.toLowerCase().search(searchKey.toLowerCase()) != -1) {
                    searchResult.push(this.equipmentCategoryResult[i]);
                }
            }
            this.equipmentResult = searchResult;
        } else {
            this.equipmentResult = this.equipmentCategoryResult;
        }
    }

    handleSaveClick() {
        var selectedEquipments = [];
        for(var i in this.equipmentResultMaster) {
            if(this.equipmentResultMaster[i].isSelected) {
                selectedEquipments.push(this.equipmentResultMaster[i]);
            }
        }
       if(selectedEquipments.length > 0) {
           this.createEquipmentRequest(selectedEquipments);
       } else {
           var error = {};
           error.message = 'Select at least one Equipment';
           this.showErrorToast(error);
       }
    }

    createEquipmentRequest(selectedEquipments){
        this.showSpinner = true;
        createEquipmentAndEquipmentRequest({
            'equipmentDetails': JSON.stringify(selectedEquipments),
            'requestId': this.parentRecordId
        }).then(result => {
            if(result) {
                this.showSuccessToast('Equipment added to the Cart');
                this.closeWindow();
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.showErrorToast(error);
        });
    }
    
    handleEquipmentSelected(event) {
        if(event.detail) {
            this.productData = event.detail.product;
            var isSelected = event.detail.isSelected;
            var quantity = event.detail.quantity;

            for(var i in this.equipmentResultMaster) {
                if(this.equipmentResultMaster[i].KlasID == this.productData.KlasID) {
                    this.equipmentResultMaster[i].isSelected = isSelected;
                    this.equipmentResultMaster[i].quantity = quantity;
                }
            }
        }
    }

    closeWindow() {
        var close = true;
        const closeWindowEvent = new CustomEvent('closewindow', {
            detail: { close },
        });
        this.dispatchEvent(closeWindowEvent); 
        if(this.isPortal && this.isPortal == 'true') {
            window.close();
        }
    }

    showErrorToast(error) {
        const event = new ShowToastEvent({
            "title": 'ERROR',
            "message": error.message || error.body.message,
            "variant": 'error'
        });
        this.dispatchEvent(event);
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            "title": 'SUCCESS',
            "message": message,
            "variant": 'success'
        });
        this.dispatchEvent(event);
    }
}