import { LightningElement, wire, api, track } from 'lwc';
import retrieveCheckStatements from '@salesforce/apex/VendorCheckStatementController.retrieveCheckStatements';
import markStatementPrintedAndMailed from '@salesforce/apex/VendorCheckStatementController.markStatementPrintedAndMailed';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const actions = [
    { label: 'Download', name: 'download' },
    { label: 'View File Details', name: 'viewFileDetails' },
    { label: 'Mark Printed', name: 'markPrinted' },
    { label: 'Mark Mailed', name: 'markMailed' },
];


const dateFormat = {
    day: 'numeric',
    month: 'numeric',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: true
};

const columns = [
    {
        label: 'Check Number', sortable: true,
        fieldName: 'titleUrl', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Title',
              //  name: 'Title', 
                
            },
            
          // target: '_blank'
          // rowActions: actions
         // target: this.showRowDetails(this.fieldName);
        }
        

    },
    { label: 'Printed', fieldName: 'Printed', type: 'boolean', sortable: true },
    { label: 'Mailed', fieldName: 'Mailed', type: 'boolean', sortable: true },
    { label: 'Create Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: dateFormat, sortable: true },
    { label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date', typeAttributes: dateFormat, sortable: true },
    { label: 'Size', fieldName: 'ContentSize', sortable: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },

];


export default class VendorCheckStatements extends NavigationMixin(LightningElement) {

    @api recordId;

    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy = '';
    offset;
    limit;
    fromNumber;
    toNumber;
    checkStatementList = [];

    @track usedInCommunity;
    @track searchKeyTitle;
    @track searchKeyMonth;
    @track searchKeyYear;
    @track searchKeyIsPrinted;
    @track totalRecountCount = 0;
    @track data = [];
    @track showSpinner = true;
    @track monthsPicklistValues = [
        { label: 'January', value: '1' },
        { label: 'February', value: '2' },
        { label: 'March', value: '3' },
        { label: 'April', value: '4' },
        { label: 'May', value: '5' },
        { label: 'June', value: '6' },
        { label: 'July', value: '7' },
        { label: 'August', value: '8' },
        { label: 'September', value: '9' },
        { label: 'October', value: '10' },
        { label: 'November', value: '11' },
        { label: 'December', value: '12' },
    ];
    @track allOrPrintedValues = [
        { label: 'All', value: 'all'},
        { label: 'Printed', value: 'printed'},
        { label: 'Mailed', value: 'mailed'},
        { label: 'Electronic', value: 'electronic'}
    ];

    get yearPicklistValues() {
        let year = new Date().getFullYear();
        const yearPicklistValues = [];
        for (let counter = year; counter >= 2021; counter--) {
            yearPicklistValues.push({ label: year + '', value: year  + '' });
        }
        return yearPicklistValues;
    }

    connectedCallback() {
        this.searchKeyTitle = '';
        this.searchKeyYear = new Date().getFullYear() + '';
        this.searchKeyMonth = (new Date().getMonth() + 1) + '';
        this.searchKeyIsPrinted = 'all';
        this.setDefault();
        this.retrieve();

        if (location.href.indexOf('/s/') > 0) {
            this.usedInCommunity = true;
        } else {
            this.usedInCommunity = false;
        }
    }

    setDefault() {
        this.offset = 0;
        this.limit = 5;
    }

    retrieve() {
        this.showSpinner = true;
        let isPrinted = null;
        let isMailed = null;
        let isElectronic = null;
        if(this.searchKeyIsPrinted == 'printed') {
            isPrinted = true;
        } else if (this.searchKeyIsPrinted == 'mailed') {
            isMailed = true;
        } else if (this.searchKeyIsPrinted == 'electronic') {
            isElectronic = true;
        }

        let param = {
            vendorId: this.recordId,
            offset: this.offset,
            recordLimit: this.limit,
            searchFilter: this.searchKeyTitle,
            month: this.searchKeyMonth,
            year: this.searchKeyYear,
            isPrinted: isPrinted,
            isMailed: isMailed,
            isElectronic: isElectronic
        };
        console.log('vendorId1');
        console.log('vendorId1',this.recordId);
       // console.log('vendorId2',JSON.stringify(vendorId));
        console.log('param',JSON.stringify(param));
        retrieveCheckStatements(param).then(result => {
            console.log('result',JSON.stringify(result));
            if (result) {
                let records = result.records;
                this.totalRecountCount = result.total;
                let preparedDataList = [];
                
                records.forEach(wrap => {
                    let preparedData = {};
                    preparedData.Id = wrap.cv.ContentDocumentId;
                  //  preparedData.titleUrl = contentVersion.ContentDocumentId;
                    preparedData.titleUrl = `${window.location.hostname}/${wrap.cv.ContentDocumentId}`;
                    preparedData.Title = wrap.cv.Title;
                    preparedData.Printed = wrap.checkStatement.Printed__c;
                    preparedData.Mailed = wrap.checkStatement.Mailed__c;
                    preparedData.checkStatementId = wrap.checkStatement.Id;
                    this.checkStatementList.push(wrap.checkStatement);
                    preparedData.CreatedDate = wrap.cv.CreatedDate;
                    preparedData.LastModifiedDate = wrap.cv.LastModifiedDate;
                    preparedData.ContentSize = this.formatBytes(wrap.cv.ContentSize, 2);
                    preparedDataList.push(preparedData);
                });

                this.data = preparedDataList;
                this.fromNumber = this.offset + 1;
                this.toNumber = this.offset + this.limit;
                if(this.toNumber > this.totalRecountCount) {
                    this.toNumber = this.totalRecountCount;
                }
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            const event = new ShowToastEvent({
                "title": 'ERROR',
                "message": error.message || error.body.message,
                "variant": 'error',
            });
            this.dispatchEvent(event);
        });
    }

    handleChange(event) {
        if (event.target.name == 'title') {
            this.searchKeyTitle = event.target.value;
        }
        if (event.target.name == 'dateValue') {
            this.searchKeyDate = event.target.value;
        }
        if (event.target.name == 'monthSearch') {
            this.searchKeyMonth = event.target.value;
        }
        if (event.target.name == 'yearSearch') {
            this.searchKeyYear = event.target.value;
        }
        if (event.target.name == 'IsPrintedSearch') {
            this.searchKeyIsPrinted = event.target.value;
        }
        // searchKeyYear

    }
    updateSearch() {
        this.showSpinner = true;
        this.setDefault();
        this.retrieve();
    }

    get disablePrevious() {
        return this.offset <= 1;
    }

    get disableNext() {
        return this.totalRecountCount == this.toNumber;
    }

    get noRecords() {
        return this.totalRecountCount == 0;
    }

    //clicking on next button this method will be called
    nextHandler() {
        this.showSpinner = true;
        this.offset = this.offset + this.limit;
        this.retrieve();
    }


    previousHandler() {
        this.showSpinner = true;
        this.offset = this.offset - this.limit;
        this.retrieve();
    }

    handleRowAction(event) {
        // console.log('hello');
        const actionName = event.detail.action.name;
         console.log('actionName',actionName);
        window.console.log(JSON.stringify(event.detail.row));
        const row = event.detail.row;
        console.log('row',event.detail.id);
        switch (actionName) {
            case 'download':
                this.downloadFile(row.Id);
                break;
            case 'viewFileDetails':
                this.showRowDetails(row.Id, row.FileId);
                break;
            case 'Title':
                this.showRowDetails(row.Id, row.FileId);
                break;
            case 'markPrinted':
                this.markPrintedAndMailed(row.checkStatementId, true, false);
                break;
            case 'markMailed':
                this.markPrintedAndMailed(row.checkStatementId, false, true);
                break;
            default:
        }
    }

    downloadFile(id) {
        let baseUrl = 'https://' + location.host;

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: baseUrl + '/sfc/servlet.shepherd/document/download/'+id
            }
        }, false);
    }

    showRowDetails(id) {
        if (!this.usedInCommunity) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
            
                attributes: {
                    pageName: 'filePreview',
                    target: '_blank'
                },
            
                state: {

                    recordIds: id
                }
            });
        } else if (this.usedInCommunity) {
            try {
                this.dispatchEvent(new CustomEvent("viewfile",{ 
                    detail: {id}
                }) );
            } catch(ex) {
               
            }
           
        }
    }

    markPrintedAndMailed(checkStatementId, markPrinted, markMailed) {

        let checkStatement = {};
        for(var i=0; i<this.checkStatementList.length; i++) {
            if(this.checkStatementList[i].Id == checkStatementId) {
                checkStatement = this.checkStatementList[i];
                break;
            }
        }

        if(checkStatement && markPrinted === true) {
            if(checkStatement.Printed__c === true) {
                this.showToast('Info', checkStatement.Name + ' is already Printed', 'info');
            } else {
                this.setPrintedOrMailed(checkStatementId, true, null);
            }
        } else if(checkStatement && markMailed === true) {
            if(checkStatement.Mailed__c === true) {
                this.showToast('Info', checkStatement.Name + ' is already Mailed', 'info');
            } else {
                this.setPrintedOrMailed(checkStatementId, null, true);
            }
        }
    }
    
    setPrintedOrMailed(checkStatementId, markPrinted, markMailed) {
        let message = '';
        if(markPrinted === true) {
            message = ' is Printed ';
        } else if(markMailed === true) {
            message = ' is Mailed ';
        }
        markStatementPrintedAndMailed({
            'checkStatementId': checkStatementId,
            'markPrinted': markPrinted,
            'markMailed': markMailed
        }).then(result => {
            console.log('checkStatement Result:',JSON.stringify(result));
            if (result) {
                this.retrieve();
                let checkStatementName;
                
                if(this.checkStatementList && this.checkStatementList.length > 0) {
                    for(var i=0; i<this.checkStatementList.length; i++) {
                        if(this.checkStatementList[i].Id == checkStatementId) {
                            checkStatementName = this.checkStatementList[i].Name;
                        }
                    }
                    this.showToast('Success', checkStatementName + message, 'success');
                }
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showToast('Error', error.message || error.body.message, 'error');
            this.showSpinner = false;
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant
        });
        this.dispatchEvent(event);
    }

    formatBytes(bytes, decimals) {
        if (bytes == 0) return '0 bytes';
        let k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}