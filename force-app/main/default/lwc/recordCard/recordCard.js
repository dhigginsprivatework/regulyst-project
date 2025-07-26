import { LightningElement, api } from 'lwc';

export default class RecordCard extends LightningElement {
  @api title;
  @api fields = [];
}
