import { LightningElement, track } from 'lwc';
import searchFrameworks from '@salesforce/apex/ProjectController.searchFrameworks';

export default class FrameworkAdminPage extends LightningElement {
    @track frameworks = [];
    @track selectedFrameworkId;

    async handleSearch(event) {
        const searchKey = event.target.value;
        if (searchKey.length > 1) {
            this.frameworks = await searchFrameworks({ searchKey });
        }
    }

    handleFrameworkSelect(event) {
        this.selectedFrameworkId = event.detail.frameworkId;
    }
}
