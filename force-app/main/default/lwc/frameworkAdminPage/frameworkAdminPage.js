import { LightningElement, track } from 'lwc';
import searchFrameworks from '@salesforce/apex/ProjectController.searchFrameworks';

export default class FrameworkAdminPage extends LightningElement {
    @track frameworks = [];
    @track selectedFrameworkId;

    connectedCallback() {
        this.loadFrameworks('');
    }

    async loadFrameworks(searchKey) {
        try {
            this.frameworks = await searchFrameworks({ searchKey });
        } catch (error) {
            console.error('Error loading frameworks', error);
        }
    }

    handleSearch(event) {
        const searchKey = event.target.value;
        this.loadFrameworks(searchKey);
    }

    handleFrameworkSelect(event) {
        this.selectedFrameworkId = event.detail.frameworkId;
    }
}
