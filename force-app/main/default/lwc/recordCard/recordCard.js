import { LightningElement, api } from 'lwc';

export default class RecordCard extends LightningElement {
  @api title;
  @api fields = [];

  // Optional: You could add logic here to format fields if needed
}
