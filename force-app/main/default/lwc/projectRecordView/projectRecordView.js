import { LightningElement, api, wire, track } from 'lwc';
import getProjectWithFrameworks from '@salesforce/apex/RecordDataController.getProjectWithFrameworks';
import { fieldConfig } from 'c/fieldConfig';

export default class ProjectRecordView extends LightningElement {
  @api recordId;
  @track project;
  @track frameworkCards = [];

  @wire(getProjectWithFrameworks, { projectId: '$recordId' })
    wiredProject({ data, error }) {
        if (data) {
            console.log('Project data:', JSON.stringify(data, null, 2)); // 👈 Add this line
            this.project = data;
            this.prepareFrameworkCards(data.Project_Frameworks__r || []);
        } else if (error) {
        console.error('Error loading project:', error);
        }
    }


  get projectFields() {
  return fieldConfig.Project__c.map(cfg => {
    const value = this.project?.[cfg.fieldName];
    const displayValue = cfg.isLookup ? this.project?.[cfg.relatedNameField] : value;
    const link = cfg.isLookup ? `/lightning/r/${cfg.objectApiName}/${value}/view` : null;
    return {
      label: cfg.label,
      value,
      displayValue,
      isLookup: cfg.isLookup,
      link
    };
  });
}



  prepareFrameworkCards(frameworks) {
    this.frameworkCards = frameworks.map(framework => ({
      id: framework.Id,
      title: 'Project Framework',
      fields: fieldConfig.Project_Framework__c.map(cfg => ({
        label: cfg.label,
        value: framework[cfg.fieldName],
        displayValue: framework[cfg.fieldName],
        isLink: cfg.isLink
      }))
    }));
  }
}
