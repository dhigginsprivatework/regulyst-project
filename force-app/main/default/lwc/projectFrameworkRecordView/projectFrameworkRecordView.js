import { LightningElement, api, wire } from 'lwc';
import getProjectFramework from '@salesforce/apex/RecordDataController.getProjectFramework';
import { fieldConfig } from 'c/fieldConfig';

export default class ProjectFrameworkRecordView extends LightningElement {
  @api recordId;
  projectFramework;

  @wire(getProjectFramework, { pfId: '$recordId' })
  wiredFramework({ data, error }) {
    if (data) this.projectFramework = data;
    else if (error) console.error(error);
  }

  get frameworkFields() {
    return fieldConfig.Project_Framework__c.map(cfg => ({
      label: cfg.label,
      value: this.projectFramework?.[cfg.fieldName]
    }));
  }
}
