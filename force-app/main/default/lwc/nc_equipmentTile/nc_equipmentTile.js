import { LightningElement, api, track } from 'lwc';

export default class nc_equipmentTile extends LightningElement {
    _product;
    isProductSelected = false;
    productQuantity = '1';

    @api
    get product() {
        return this._product;
    }
    set product(value) {
        this._product = value;
        this.pictureUrl = value.ImageURL;
        this.name = value.Titl;
        this.productUrl = value.URL;
    }

    pictureUrl;
    name;
    ariaLabel;
    productMainAriaLabel;
    imageAltLabel;
    productAriaLabel;
    productUrl;
    selectedQuantity = '1';
    @track
    quantityOptions = [
        {label: '1', value: '1'},
        {label: '2', value: '2'},
        {label: '3', value: '3'},
        {label: '4', value: '4'},
        {label: '5', value: '5'},
        {label: '6', value: '6'},
        {label: '7', value: '7'},
        {label: '8', value: '8'},
        {label: '9', value: '9'},
        {label: '10', value: '10'}
    ];

    renderedCallback() {
        var isSelected = this.product.isSelected;
        if(isSelected) {
            this.template.querySelector('[data-id="productCard"]').className = 'content contentActive';
            this.selectedQuantity = this.product.quantity;
            this.productAriaLabel = 'To deselect this equipment press Space or Enter.';
        } else {
            this.template.querySelector('[data-id="productCard"]').className = 'content';
            this.selectedQuantity = this.product.quantity;
            this.productAriaLabel = 'To select this equipment press Space or Enter.';
        }

        if(!this.isValidUrl(this.productUrl)) {
            this.template.querySelector('[data-id="productLink"]').className = 'contentDecoration';
        }

        this.ariaLabel = 'Select quantity for ' + this.name;
        this.productMainAriaLabel = 'Equipment picture ' + this.name;
        this.imageAltLabel = 'Equipment picture for ' + this.name;
        // let productLink = this.template.querySelector('[data-id="productLink"]');
        // if(productLink) {
        //     productLink.setAttribute('aria-describedby', 'productDescriptionId');
        // }
        // let productDescription = this.template.querySelector('[data-id="productDescription"]');
        // if(productDescription) {
        //     productDescription.id = 'productDescriptionId'
        // }
    }

    openProductURL(event) {
        if(this.isValidUrl(this.productUrl)) {
            window.open(this.productUrl);
        }
        event.stopPropagation();
    }

    handleQuantityChange(event) {
        this.productQuantity = event.detail.value;
        this.isProductSelected = this.product.isSelected;
        this.sendPrdouctDetails();
        event.stopPropagation();
    }

    isValidUrl(string) {
        let url;
        try {
          url = new URL(string);
        } catch (_) {
          return false;  
        }
        return url.protocol === "http:" || url.protocol === "https:";
      }

    handleClick() {
        var classDetails = this.template.querySelector('[data-id="productCard"]').className;
        if(classDetails.indexOf('contentActive') == -1) {
            this.template.querySelector('[data-id="productCard"]').className = 'content contentActive';
            this.productQuantity = this.productQuantity ? this.productQuantity : '1';
            this.isProductSelected = true;
        } else {
            this.template.querySelector('[data-id="productCard"]').className = 'content';
            this.productQuantity = null;
            this.isProductSelected = false;
        }
        this.sendPrdouctDetails();
    }

    sendPrdouctDetails() {
        var productDetail = {};
        productDetail.product = this.product;
        productDetail.isSelected = this.isProductSelected;
        productDetail.quantity = this.productQuantity;
        const selectedEvent = new CustomEvent('equipmentselected', {
            detail: productDetail
        });
        this.dispatchEvent(selectedEvent);
    }

    linkKeyUp(event) {
        if(event && event.target && event.target.dataset && event.target.dataset.id && event.target.dataset.id == 'productUrl') {
            if(event.code == 'Space' || event.code == 'Enter') {
                this.openProductURL(event);
            }
        }
        event.preventDefault();
        event.stopPropagation();
    }

    cardKeyUp(event) {
        if(event && event.target && event.target.dataset && event.target.dataset.id && event.target.dataset.id == 'productLink') {
            if(event.code == 'Space' || event.code == 'Enter') {
                this.handleClick();
            }
        }
        event.preventDefault();
        event.stopPropagation();
    }
}