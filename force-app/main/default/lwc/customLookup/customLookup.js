import { LightningElement, api, track } from 'lwc';
import searchFrameworks from '@salesforce/apex/ProjectController.searchFrameworks';

export default class CustomLookup extends LightningElement {
    @api label = 'Search Framework';
    @track searchKey = '';
    @track results = [];

    handleSearch(event) {
        this.searchKey = event.target.value;
        if (this.searchKey.length > 2) {
            searchFrameworks({ searchKey: this.searchKey })
                .then(data => this.results = data)
                .catch(() => this.results = []);
        }
    }

    handleSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedName = event.currentTarget.dataset.name;
        this.dispatchEvent(new CustomEvent('frameworkselected', {
            detail: { id: selectedId, name: selectedName }
        }));
    }
}