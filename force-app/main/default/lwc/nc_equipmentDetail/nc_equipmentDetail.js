import { LightningElement, api } from 'lwc';

export default class Nc_equipmentDetail extends LightningElement {

    product;
    
    @api
    get productData() {
        return this.product;
    }

    set productData(value) {
        this.product = value;
        if(value) {
            this.title = value.Titl;
            this.productPictureUrl = value.ImageURL;
            this.annotations = value.Annotations;
            this.replaceCost = value.ReplaceCost;
            this.author = value.Author;
        }
    }

    title;
    productPictureUrl;
    annotations;
    replaceCost;
    author;
}