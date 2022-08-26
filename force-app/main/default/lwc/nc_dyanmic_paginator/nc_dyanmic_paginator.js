import {
  LightningElement,
  api,
  track
} from 'lwc';
import getRecords from '@salesforce/apex/NC_PaginatorController.retrieveRecords';

export default class Nc_dyanmic_paginator extends LightningElement {
    selectedRecordId = [];

    @track columns = [];
    @track records = [];
    @track rows = [];
    @track fromCount;
    @track toCount;
    @track totalCount;
    @track newPageNo = 1;
    @track maxPageNo = 1;
    @track showSpinner;
    @track query = '';
    @track allSelected = false;
    @track whereClauseValue;
    @track objectNameValue;
    @track recordIdToAddInQuery = [];
    @track showRecordsWithSearchOnly = false;

    @api lockComponent = false;
    @api pageSize = 10;
    @api columnsFromParent = [];
    @api selectedRecordsIds = [];
    @api buttonsLabel = [];
    @api pageSizeOptions = [ 10, 25, 50, 100, 200 ];
    @api numberofcolumns;
    @api previousPageNo = 0;
    @api recId = "";
    @api recVal = "";
    @api placeholder = "Search..";
    @api searchStr = "";
    @api sortBy = "";
    @api sortDir = "ASC";
    @api sharing = "With";
    @api norecordMessage = "No records found.";
    @api showAllPaginatorButtons = false;
    @api tableBodyId = "tableBody";
    @api tableClass = "property-table slds-table slds-table_cell-buffer slds-table_bordered";
    @api showQuery = false;
    @api checkboxButtonClass;
    @api checkboxButtonVariant;
    @api checkboxButtonLabel = '';
    @api showCheckbox = false;
    @api showNewButton = false;
    @api newButtonLabel = "New";
    @api distinctField = '';
    @api showRefreshButton = false;
    @api refreshButtonLabel = 'Refresh';
    @api showTableOnly = false;

    @api get objectName() {
        return this.objectNameValue;
    }
    set objectName(value) {
        this.objectNameValue = value;
    }

    @api get recordIdList() {
        return this.recordIdToAddInQuery;
    }
    set recordIdList(value) {
        this.recordIdToAddInQuery = value;
    }
    
    @api get whereClause() {
        return this.whereClauseValue;
    }
    set whereClause(value) {
        this.whereClauseValue = value;
    }

    @api get showRecordsOnSearchOnly(){
        return this.showRecordsWithSearchOnly;
    }
    set showRecordsOnSearchOnly(value) {
        this.showRecordsWithSearchOnly = value;
    }

    @api
    get resetTable() {
        return false;
    }
    set resetTable(val) {
        if (val) {
            this.retrieveRecords();
        }
    }
    @api
    get reloadTable() {
        return false;
    }
    set reloadTable(val) {
        if (val) {
            this.resetPagination();
        }
    }

    get norows() {
        return this.rows.length > 0;
    }

    connectedCallback() {
        this.retrieveRecords();
    }
    @api
    handleTableRefresh() {
        this.resetPagination();
    }

    @api
    retrieveRecords() {
        this.showSpinner = true;
        this.columns = JSON.parse(JSON.stringify(this.columnsFromParent)); //[...this.columnsFromParent];
        this.columns.forEach(column => {
            if (this.sortBy === column.name) {
                column.sorted = true;
                if (this.sortDir === 'ASC') {
                    column.sortedAscending = true;
                }
            } else {
                column.sorted = false;
                column.sortedAscending = false;
            }
        });
        let columns = this.columns;
        let fields = [];
        let searchableFields = [];
        columns.forEach(function (column, index) {
            if (column.name)
                fields.push(column.name);
            if (column.isSearchable)
                searchableFields.push(column.name);
        });
        let parameters = {
            'objectName': this.objectNameValue,
            'fields': fields,
            'searchStr': this.searchStr,
            'whereClause': this.whereClauseValue,
            'previousPageNo': this.previousPageNo,
            'newPageNo': this.newPageNo,
            'limit': this.pageSize,
            'sortBy': this.sortBy,
            'sortDir': this.sortDir,
            'recId': this.recId,
            'recVal': this.recVal,
            'maxPageNo': this.maxPageNo,
            'sharing': this.sharing,
            'searchableFields': searchableFields,
            'distinctField': this.distinctField,
            'showRecordsOnSearchOnly' : this.showRecordsWithSearchOnly,
        };
        if(this.recordIdToAddInQuery.length > 0){
            //parameters.push({ 'recordIdList': this.recordIdToAddInQuery});
            parameters.recordIdList = this.recordIdToAddInQuery;
        }

        let calloutParams = {
            "parameters": parameters
        };

        getRecords(calloutParams).then(result => {
                this.records = result.records;
                this.totalCount = result.totalCount;
                this.query = result.query;
                this.setFooter();
                this.createTable();
                this.resetFlag();
                console.log('this.query', this.query);
            })
            .catch(error => {
                this.error = error;
                console.log('param ', JSON.stringify(parameters));
                console.log('error ', error);
            });
    }


    handleSorting(event) {
        this.columns.forEach(column => {
            if (event.target.dataset.id == column.name) {
                column.sorted = true;
                this.sortBy = column.name;
                if (column.sortedAscending) {
                    this.sortDir = 'DESC';
                    column.sortedAscending = false;
                } else {
                    this.sortDir = 'ASC';
                    column.sortedAscending = true;
                }
            } else {
                column.sorted = false;
                column.sortedAscending = false;
            }
        });

        this.resetPagination();
    }

    searchRecords(event) {
        this.searchStr = event.target.value;
        this.resetPagination();
        /*
        if(event.keyCode === 13 && typeof event.keyCode != 'undefined') {
            this.retrieveRecords();
        } 
        else if(this.searchStr == '') {
            this.retrieveRecords();
        }*/
    }
    setPageSize(event) {
        this.pageSize = event.target.value;
        this.resetPagination();
    }
    handleButtonClick(event) {
        let buttonLabel = event.target.label;
        if (buttonLabel != this.newPageNo) {
            this.previousPageNo = this.newPageNo;
            let records = this.records;
            if (buttonLabel == 'Next') {
                this.newPageNo = this.newPageNo + 1;
                if (records) {
                    this.recId = records[records.length - 1].Id;
                    this.recVal = records[records.length - 1][this.sortBy];
                }
            } else if (buttonLabel == 'Previous') {
                this.newPageNo = this.newPageNo - 1;
                if (records) {
                    if (this.newPageNo == 1) {
                        this.previousPageNo = 0;
                        this.recId = '';
                        this.recVal = '';
                    } else if (records) {
                        this.recId = records[0].Id;
                        this.recVal = records[0][this.sortBy];
                    }
                }
            } else {
                this.newPageNo = parseInt(event.target.label);
                if (this.newPageNo == 1) {
                    this.previousPageNo = 0;
                    this.recId = '';
                    this.recVal = '';
                } else if (parseInt(this.previousPageNo) > parseInt(this.newPageNo)) {
                    if (records) {
                        this.recId = records[0].Id;
                        this.recVal = records[0][this.sortBy];
                    }
                } else {
                    if (records) {
                        this.recId = records[records.length - 1].Id;
                        this.recVal = records[records.length - 1][this.sortBy];
                    }
                }
            }
            this.retrieveRecords();
        }
    }
    handleAction(event) {
        let data = {
            record: this.getRecordById(event.target.dataset.id),
            recordId: event.target.dataset.id,
            actionName: event.target.dataset.action
        };
        this.customAction(data);
    }

    getRecordById(recordId) {
        let result = null;
        this.records.forEach(element => {
            if (element.Id == recordId) {
                result = element;
            }
        });
        return result;
    }

    handleCheckboxChange(event) {
        let temparr = [];
        temparr = [...this.selectedRecordId];
        if (event.target.checked) {
            if (temparr.indexOf(event.target.dataset.id) == -1) {
                temparr.push(event.target.dataset.id);
            }
        } else {
            if (temparr.indexOf(event.target.dataset.id) != -1) {
                temparr.splice(temparr.indexOf(event.target.dataset.id), 1);
            }
        }
        this.selectedRecordId = [...temparr];
        let data = {
            selectedRecordId: this.selectedRecordId,
        };
        this.handleCheckboxButton(data);
    }

    handleSelectAll(event) {
        let temparr = [];
        this.allSelected = true;
        temparr = [...this.selectedRecordId];
        if (event.target.checked) {
            this.rows.forEach(item => {
                item.isChecked = true;
                if (temparr.indexOf(item.id) == -1) {
                    temparr.push(item.id);
                }
            });
        } else {
            this.rows.forEach(item => {
                item.isChecked = false;
                if (temparr.indexOf(item.id) != -1) {
                    temparr.splice(temparr.indexOf(item.id), 1);
                }
            });
        }
        this.selectedRecordId = [...temparr];
        let data = {
            selectedRecordId: this.selectedRecordId,
        };
        this.handleCheckboxButton(data);
    }

    handleCheckboxButton(data) {
        this.dispatchEvent(new CustomEvent('selectunselectcheckbox', {
            detail: data
        }));
    }

    setFooter() {
        this.fromCount = ((parseInt(this.newPageNo) - 1) * parseInt(this.pageSize)) + 1;
        let toCount = parseInt(this.fromCount) + parseInt(this.pageSize) - 1;
        let totalCount = parseInt(this.totalCount);
        let maxPageNo = parseInt(totalCount / parseInt(this.pageSize)) + ((totalCount % parseInt(this.pageSize)) > 0 ? 1 : 0);
        if (maxPageNo == parseInt(this.newPageNo))
            toCount = totalCount
        this.maxPageNo = maxPageNo;
        this.toCount = toCount;
        let buttonsLabel = [];
        if (this.newPageNo <= 4) {
            buttonsLabel.push({
                label: 'Previous',
                disabled: this.newPageNo == 1,
                varient: 'Neutral'
            });
            for (let counter = 1; counter <= (maxPageNo > 5 ? 5 : maxPageNo); counter++) {
                buttonsLabel.push({
                    label: counter,
                    disabled: false,
                    varient: counter == parseInt(this.newPageNo) ? 'Brand' : 'Neutral'
                });
            }
            if (maxPageNo > 5) {
                if (maxPageNo != 6)
                    buttonsLabel.push({
                        label: '...',
                        disabled: true,
                        varient: 'Base'
                    });
                buttonsLabel.push({
                    label: maxPageNo,
                    disabled: false,
                    varient: this.newPageNo == maxPageNo ? 'Brand' : 'Neutral'
                });
            }
            buttonsLabel.push({
                label: 'Next',
                disabled: this.newPageNo == this.maxPageNo || this.maxPageNo < 2,
                varient: 'Neutral'
            });
        } else if (maxPageNo - this.newPageNo <= 3) {
            buttonsLabel.push({
                label: 'Previous',
                disabled: this.newPageNo == 1,
                varient: 'Neutral'
            });
            buttonsLabel.push({
                label: '1',
                disabled: false,
                varient: 1 == this.newPageNo ? 'Brand' : 'Neutral'
            });
            if (maxPageNo > 6)
                buttonsLabel.push({
                    label: '...',
                    disabled: true,
                    varient: 'Base'
                });
            for (let counter = maxPageNo - 4; counter <= maxPageNo; counter++) {
                if (counter != 1) {
                    buttonsLabel.push({
                        label: counter,
                        disabled: false,
                        varient: counter == this.newPageNo ? 'Brand' : 'Neutral'
                    });
                }
            }
            buttonsLabel.push({
                label: 'Next',
                disabled: this.newPageNo == this.maxPageNo || this.maxPageNo < 2,
                varient: 'Neutral'
            });
        } else {
            buttonsLabel.push({
                label: 'Previous',
                disabled: this.newPageNo == 1,
                varient: 'Neutral'
            });
            buttonsLabel.push({
                label: '1',
                disabled: false,
                varient: 1 == this.newPageNo ? 'Brand' : 'Neutral'
            });
            if (maxPageNo != 6)
                buttonsLabel.push({
                    label: '...',
                    disabled: true,
                    varient: 'Base'
                });
            buttonsLabel.push({
                label: this.newPageNo - 1,
                disabled: false,
                varient: (this.newPageNo - 1) == this.newPageNo ? 'Brand' : 'Neutral'
            });
            buttonsLabel.push({
                label: this.newPageNo,
                disabled: false,
                varient: (this.newPageNo) == this.newPageNo ? 'Brand' : 'Neutral'
            });
            buttonsLabel.push({
                label: this.newPageNo + 1,
                disabled: false,
                varient: (this.newPageNo + 1) == this.newPageNo ? 'Brand' : 'Neutral'
            });
            if (maxPageNo != 6)
                buttonsLabel.push({
                    label: '...',
                    disabled: true,
                    varient: 'Base'
                });
            buttonsLabel.push({
                label: maxPageNo,
                disabled: false,
                varient: this.newPageNo == maxPageNo ? 'Brand' : 'Neutral'
            });
            buttonsLabel.push({
                label: 'Next',
                disabled: this.newPageNo == this.maxPageNo || this.maxPageNo < 2,
                varient: 'Neutral'
            });
        }
        this.buttonsLabel = buttonsLabel;
    }
    @api
    resetPagination() {
        this.newPageNo = 1;
        this.previousPageNo = 0;
        this.recId = '';
        this.recVal = '';
        this.selectedRecordId = [];
        this.retrieveRecords();
    }
    createTable() {
        let records = this.records;
        let columns = this.columns;
        let rows = [];
        let _this = this;
        let count = (this.newPageNo - 1) * this.pageSize;
        let allSelected = -1;
        records.forEach(function (record, index) {
            let isSelected = _this.selectedRecordId.indexOf(record.Id) != -1;
            allSelected = allSelected == false ? false : isSelected;
            let row = {
                id: record.Id,
                columns: [],
                isChecked: isSelected
            };
            columns.forEach(function (column) {
                if(!column.dontShow){
                    let val = '';
                    let name = column.name;
                    let indexVal = 0;
                    let tempRecord = record;
                    if (column.name.indexOf('.') != -1) {
                        while (name.indexOf('.') != -1) {
                            if (tempRecord[name.split('.')[0]]) {
                                if (column.type == 'time')
                                    val = _this.msToTimeAMPM(tempRecord[name.split('.')[0]][name.split('.')[1]]);
                                else if (column.type == 'date')
                                    val = _this.getFormattedDate(tempRecord[name.split('.')[0]][name.split('.')[1]]);
                                else
                                    val = tempRecord[name.split('.')[0]][name.split('.')[1]];
                                tempRecord = tempRecord[name.split('.')[0]];
                            }
                            indexVal = ++indexVal;
                            name = name.split('.').slice(1, name.split('.').length).join('.');
                        }
                    } else if (column.type == 'time') {
                        val = _this.msToTimeAMPM(record[column.name]);
                    } else if (column.type == 'index') {
                        val = ++count;
                    } else if (column.type == 'date') {
                        val = _this.getFormattedDate(record[column.name]);
                    } else {
                        val = record[column.name];
                    }
                    let label = '';
                    if (column.type == 'text' || column.type == 'time' || column.type == 'date') {
                        label = column.label
                    }
                    let recordColumn = {
                        label: label,
                        value: val,
                        isText: column.type == 'text' || column.type == 'time' || column.type == 'index' || column.type == 'date',
                        isCheckbox: column.type == 'checkbox',
                        isButton: column.type == 'button',
                        isButtons: column.type == 'buttons',
                        action: column.action,
                        varient: column.varient,
                        buttonLabel: column.buttonlabel,
                        buttons: column.buttons,
                        iconname: column.iconname,
                        class: 'slds-truncate slds-col slds-cell-wrap ' + column.class
                    };
                    row.columns.push(recordColumn);
                }
            });
            rows.push(row);
        });
        this.rows = rows;
        _this.allSelected = allSelected == -1 ? false : allSelected;
        this.showSpinner = false;
    }
    customAction(data) {
        this.dispatchEvent(new CustomEvent('paginatoraction', {
            detail: data
        }));
    }

    resetFlag() {
        this.dispatchEvent(new CustomEvent('resetflag', {
            detail: false
        }));
    }

    handleCreateRecord() {
        this.dispatchEvent(new CustomEvent('createrecord'));
    }

    msToTimeAMPM(s) {
        if (s == '' || s == null || typeof s == 'undefined')
            return '';
        var ms = s % 1000;
        s = (s - ms) / 1000;
        var secs = s % 60;
        s = (s - secs) / 60;
        var mins = s % 60;
        var hrs = (s - mins) / 60;
        let radian = 'AM';
        if (hrs > 12) {
            radian = 'PM';
            hrs = hrs - 12;
        }

        return this.pad(hrs) + ':' + this.pad(mins) + ' ' + radian;
    }

    pad(n, z) {
        z = z || 2;
        return ('00' + n).slice(-z);
    }

    getFormattedDate(oldDate) {
        if (oldDate == '' || oldDate == null || typeof oldDate == 'undefined')
            return '';
        let newDate = new Date(oldDate);
        let month = newDate.getMonth()+1;
        let day = newDate.getDate();
        let year = newDate.getFullYear();
        return month + "/" + day + "/" + year;
    }
}