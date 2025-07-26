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
        // Resolve nested field value (e.g., Framework__r.Name)
        const value = cfg.fieldName.includes('.')
            ? cfg.fieldName.split('.').reduce((acc, part) => acc?.[part], this.project)
            : this.project?.[cfg.fieldName];

        // Get the lookup record ID (e.g., Framework__c)
        const lookupId = cfg.isLookup
            ? this.project?.[cfg.fieldName.split('.')[0].replace('__r', '__c')]
            : null;

        // Build link to record page
        const link = cfg.isLookup && lookupId
            ? `/lightning/r/${cfg.objectApiName}/${lookupId}/view`
            : null;

        return {
            label: cfg.label,
            value,
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
