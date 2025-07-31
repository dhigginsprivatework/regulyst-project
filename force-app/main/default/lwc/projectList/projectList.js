import { LightningElement, api, track, wire } from 'lwc';
import getProjectsByFramework from '@salesforce/apex/ProjectController.getProjectsByFramework';

export default class ProjectList extends LightningElement {
    @api frameworkId;
    @track projects = [];

    @wire(getProjectsByFramework, { frameworkId: '$frameworkId' })
    wiredProjects({ error, data }) {
        if (data) {
            this.projects = data.map(proj => ({
                ...proj,
                url: `/lightning/r/Project__c/${proj.Id}/view`
            }));
        } else if (error) {
            console.error('Error loading projects', error);
        }
    }
}
