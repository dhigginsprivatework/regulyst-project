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
      this.project = data;
      this.prepareFrameworkCards(data.Project_Frameworks__r || []);
    } else if (error) {
      console.error(error);
    }
  }

  get projectFields() {
  return fieldConfig.Project__c.map(cfg => {
    const value = this.project?.[cfg.fieldName];
    const isLookup = cfg.fieldName.endsWith('__c') && typeof value === 'string' && value.startsWith('a'); // heuristic
    return {
      label: cfg.label,
      value: value,
      isLookup: isLookup,
      link: isLookup ? '/' + value : null
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
