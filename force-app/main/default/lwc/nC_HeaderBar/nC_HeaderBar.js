import { LightningElement } from 'lwc';
//import NC_LOGOPNG from '@salesforce/resourceUrl/NC_LOGOPNG';
import NCDSDHHVendorHeader from '@salesforce/resourceUrl/NCDSDHHVendorHeader';

export default class NC_HeaderBar extends LightningElement {
  //nchdhs_logo_for_nav = NC_LOGOPNG;
  nchdhs_logo_for_nav = NCDSDHHVendorHeader;

}