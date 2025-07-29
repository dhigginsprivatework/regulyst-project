import { LightningElement, api, wire } from 'lwc';
import getAnalytics from '@salesforce/apex/ProjectAnalyticsController.getAnalytics';

export default class ProjectAnalytics extends LightningElement {
    @api recordId;
    analytics;

    @wire(getAnalytics, { projectId: '$recordId' })
    wiredAnalytics({ error, data }) {
        if (data) {
            this.analytics = data;
        } else {
            this.analytics = null;
            console.error(error);
        }
    }
}
